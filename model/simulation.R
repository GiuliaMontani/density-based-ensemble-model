simulation <- function(S = 50,
                       mu = rbind(c(2,2),c(-2,-2),c(0,0)),
                       p=2,
                       sigma = rbind(diag(2),diag(2),diag(2)),
                       N = 50,
                       Y = NULL,
                       alpha_beg = rbind(c(7,4,4),c(4,7,4),c(4,4,7)),
                       alpha_exp = rbind(c(12,4,4),c(4,12,4),c(4,4,12)),
                       Nannotators = 7,
                       N_exp = 4,
                       N_beg = 3,
                       N_class = 3,
                       weights = NULL){
  Y <- c(rep("G1",N),rep("G2",N),rep("G3",N))
  
  if(!is.null(Nannotators) && Nannotators != N_exp+N_beg){
    stop("Error : number of annotators must be equal to number of expert plus number of begginer")
  }
  
  if( N_class != nrow(alpha_exp) || N_class != nrow(alpha_beg) || N_class != ncol(alpha_exp) || N_class != ncol(alpha_beg)){
    stop("Error: alpha parameters for dirichlet distribution must be of the same size of numebr of class")
  }
  
  if(N_class != nrow(mu) || p != ncol(mu)){
    stop("Error : dimension of mean parameters must be nxp")
  }
  
  if(p*N_class != nrow(sigma) || p != ncol(sigma)){
    stop("Error : dimension of sigma must be [pxp ; pxp ; pxp] (nxp)xp")
  }
  
  z_beg <- NULL
  z_exp <- NULL
  for(n in 1:N_class){
    z_beg <- rbind(z_beg, rdirichlet(N,alpha=alpha_beg[n,]))
    z_exp <- rbind(z_exp, rdirichlet(N,alpha=alpha_exp[n,]))
  }
  
  # Initialize Accurac, Mean Error and Sigma Error matrix
  acc_LDA <- NULL
  acc_QDA <- NULL
  acc_EDDA <- NULL
  
  meanEr_LDA <- NULL
  meanEr_QDA <- NULL
  meanEr_EDDA <- NULL
  
  sigmaEr_LDA <- NULL
  sigmaEr_QDA <- NULL
  sigmaEr_EDDA <- NULL
  
  
  for(sim in 1:S){
    
    # Features
    X <- NULL
    for(n in 1:N_class){
      X <- rbind(X,rmvnorm(n=N ,mean=mu[n,],sigma=sigma[c(1:p) + (n-1)*p,]))
    }
    
    # Y noise experts
    Y_noise_exp <- matrix(NA,nrow(z_exp),N_exp)
    name_exp <- NULL
    for(j in 1:nrow(z_exp)){
      mult_jk <- rmultinom(N_exp,1,z_exp[c(j),])
      for (k in 1:N_exp){
        Y_noise_exp[j,k] <- which(mult_jk[,k]==1)
        
        if(j==1){
          name_exp <- cbind(name_exp, paste0("Expert",k)) 
        }
      }
    }
    
    # Y noise beginners
    Y_noise_beg <- matrix(NA,nrow(z_beg),N_beg)
    name_beg <- NULL
    for(j in 1:nrow(z_beg)){
      mult_jk <- rmultinom(N_beg,1,z_beg[c(j),])
      for (k in 1:N_beg){
        Y_noise_beg[j,k] <- which(mult_jk[,k]==1)
        
        if(j==1){
          name_beg <- cbind(name_beg, paste0("Beginner",k))
        }
      }
    }
    Y_noise <- cbind(Y_noise_exp,Y_noise_beg)
    colnames(Y_noise) <- cbind(name_exp,name_beg)
    
    for(n in 1:N_class){
      Y_noise[Y_noise==n] <- paste0("G",n)
      #Y_noise[Y_noise==n] <- n
    }
    
    # Train test set
    XY <- data.frame(X,
                     Y_noise,
                     label = Y)
    df_split <- initial_split(XY, prop = 2/3,strata = label)
    train_data <- training(df_split)
    test_data <- testing(df_split)
    X.train <- train_data[,c(1:p)]
    X.test <- test_data[,c(1:p)]
    truth.train <- train_data$label
    Y.test <- test_data$label
    Y.train <- train_data[,c((p+1):(Nannotators+p))]
    # setwd("C:/Users/giuli/Documents/GitHub/density-based-ensemble-model")
    # path = getwd()
    # path = paste0(path,"/",sim)
    # path_X_train = paste0(path,"X_train.csv")
    # path_X_test = paste0(path,"X_test.csv")
    # path_Y_train = paste0(path,"Y_train.csv")
    # path_y_test = paste0(path,"gt_test.csv")
    # path_y_train = paste0(path,"gt_train.csv")
    # 
    # write.table(X.train, path_X_train, sep =",", row.names = FALSE, col.names = FALSE)
    # write.table(X.test, path_X_test, sep =",", row.names = FALSE, col.names = FALSE)
    # write.table(Y.train, path_Y_train, sep =",", row.names = FALSE, col.names = FALSE)
    # write.table(as.data.frame(Y.test), path_y_test, sep =",", row.names = FALSE, col.names = FALSE)
    # write.table(as.data.frame(truth.train), path_y_train, sep =",", row.names = FALSE, col.names = FALSE)
    
    # Weights generation
    weights <- weights_generation(xtrain = X.train, ytrain_noise = Y.train, ytrain = truth.train,ytest = Y.test, 
                                    Nannotators = Nannotators, N_exp = N_exp, N_beg = N_beg)  


    # Model comparison
    parameters <- list()
    class_name <- unique(truth.train)
    num_class <- length(class_name)
    
    for(k in 1:num_class){
      class_k <- class_name[k]
      parameters$mu[[class_k]] <- mu[k,]
      parameters$sigma[[class_k]] <- sigma[((k - 1) * p+1):(k*p),]
    }
  
    mods <- model_comparison(X.train,X.test,Y.train,truth.train,Y.test,model_weights = weights,
                             parameters = parameters)

    
    # Accuracy, Mean Error and Sigma Error matrix
    if(sim==1){
      acc_LDA <- matrix(NA,S,length(mods$ModelNames))
      acc_QDA <- matrix(NA,S,length(mods$ModelNames))
      acc_EDDA <- matrix(NA,S,length(mods$ModelNames))
      
      meanEr_LDA <- matrix(NA,S,length(mods$ModelNames))
      meanEr_QDA <- matrix(NA,S,length(mods$ModelNames))
      meanEr_EDDA <- matrix(NA,S,length(mods$ModelNames))
      
      sigmaEr_LDA <- matrix(NA,S,length(mods$ModelNames))
      sigmaEr_QDA <- matrix(NA,S,length(mods$ModelNames))
      sigmaEr_EDDA <- matrix(NA,S,length(mods$ModelNames))
      
      colnames(acc_LDA) <- mods$ModelNames
      colnames(acc_QDA ) <- mods$ModelNames
      colnames(acc_EDDA ) <- mods$ModelNames 
      
      colnames(meanEr_LDA) <- mods$ModelNames
      colnames(meanEr_QDA ) <- mods$ModelNames
      colnames(meanEr_EDDA ) <- mods$ModelNames 
      
      colnames(sigmaEr_LDA) <- mods$ModelNames
      colnames(sigmaEr_QDA ) <- mods$ModelNames
      colnames(sigmaEr_EDDA ) <- mods$ModelNames 
      
      w <- setNames(lapply(replicate(length(mods$ModelNames), matrix(NaN, nrow = 50, ncol = 7), simplify = FALSE), as.data.frame), mods$ModelNames)
    }
    
    for(name in mods$ModelNames){
      acc_LDA[sim,name] <- mods[[name]]$LDA$accuracy
      acc_QDA[sim,name] <- mods[[name]]$QDA$accuracy
      acc_EDDA[sim,name] <- mods[[name]]$EDDA$accuracy
      
      meanEr_LDA[sim,name] <- mods[[name]]$LDA$meanError
      meanEr_QDA[sim,name] <- mods[[name]]$QDA$meanError
      meanEr_EDDA[sim,name] <- mods[[name]]$EDDA$meanError
      
      sigmaEr_LDA[sim,name] <- mods[[name]]$LDA$sigmaError
      sigmaEr_QDA[sim,name] <- mods[[name]]$QDA$sigmaError
      sigmaEr_EDDA[sim,name] <- mods[[name]]$EDDA$sigmaError
      
      w[[name]][sim,] <- weights[[name]]
    }
    
  }
  
  output <- list(Accuracy = list(AccuracyLDA = acc_LDA,
                                 AccuracyQDA = acc_QDA,
                                 AccuracyEDDA = acc_EDDA),
                 MeanError = list(MeanErrorLDA = meanEr_LDA,
                                  MeanErrorQDA = meanEr_QDA,
                                  MeanErrorEDDA = meanEr_EDDA),
                 SigmaError = list(SigmaErrorLDA = sigmaEr_LDA,
                                   SigmaErrorQDA = sigmaEr_QDA,
                                   SigmaErrorEDDA = sigmaEr_EDDA),
                 NumberAnnotators = Nannotators,
                 ModelName = mods$ModelNames,
                 weights = w,
                 Call = call("simulation",list(
                   S = S,
                   mu = mu,
                   p=p,
                   N = N,
                   alpha_beg = alpha_beg,
                   alpha_exp = alpha_exp,
                   Nannotators = Nannotators,
                   N_exp = N_exp,
                   N_beg = N_beg,
                   N_class = N_class)))
  
}
