model_comparison <- function(xtrain = NULL,
                             xtest = NULL,
                             ytrain_noise = NULL,
                             ytrain = NULL,
                             ytest = NULL,
                             default_simulation = FALSE,
                             model_weights = NULL,
                             parameters = list(mu = NULL,
                                                sigma= NULL),
                             mclust_model_name = c("LDA","QDA","")){

  options(warn=-1)
  
  # Default setting
  if(default_simulation == TRUE){
    mu = 2 
    n= 30 
    p= 2
    
    parameters$mu[['Class1']] <- rep(mu,p)
    parameters$mu[['Class2']] <- rep(-mu,p)
    parameters$mu[['Class3']] <- rep(0,p)
    parameters$sigma[['Class1']] <- diag(p)
    parameters$sigma[['Class2']] <- diag(p)
    parameters$sigma[['Class3']] <- diag(p)
    
    x1 <- rmvnorm(n=n ,mean=parameters$mu$Class1,sigma=parameters$sigma$Class1)
    x2 <- rmvnorm(n=n ,mean=parameters$mu$Class2,sigma=parameters$sigma$Class2)
    x3 <- rmvnorm(n=n ,mean=parameters$mu$Class3,sigma=parameters$sigma$Class3)
    X <- rbind(x1,x2,x3)

    Y <- c(rep('Class1',n),rep('Class2',n),rep('Class3',n))
    
    Ynoise <- data.frame(Annotator1 = Y[sample(1:length(Y))],
                         Annotator2 = Y[sample(1:length(Y))])
    
    XY <- data.frame(X,
                     Ynoise,
                     label = Y)
    df_split <- initial_split(XY, prop = 2/3,strata = label)
    train_data <- training(df_split)
    test_data <- testing(df_split)
    xtrain <- train_data[,c(1,2)]
    xtest <- test_data[,c(1,2)]
    ytrain <- train_data[,c(5)]
    ytest <- test_data[,c(5)]
    ytrain_noise <- train_data[,c(3,4)]
    
  }
  
  # Y noise as data frame
  if(!is.data.frame(ytrain_noise)){
    ytrain_noise <- as.data.frame(ytrain_noise)
    column_name <- NULL
    for(w in 1:ncol(ytrain_noise)){
      column_name <- cbind(column_name,paste("Annotator",w))
    }
    colnames(ytrain_noise) <- column_name
  }
  
  # weights of the model as list
  if(!is.null(model_weights) && !is.list(model_weights)){
    if(is.data.frame(model_weights)){
      model_weights <- as.list(model_weights)
    }
    if(is.matrix(model_weights)){
      model_weights <- as.data.frame(model_weights)
      column_name <- NULL
      for(w in 1:ncol(model_weights)){
        column_name <- cbind(column_name,paste("Model",w))
      }
      colnames(model_weights) <- column_name
      model_weights <- as.list(model_weights)
    }
  }
  
  # Mu and sigma within each group (if it isn't given)
  if(is.null(parameters$mu) || is.null(parameters$sigma)){
    class_name <- levels(as.factor(unique(ytrain)))
    num_class <- length(class_name)
    for(k in 1:num_class){
      class_k <- class_name[k]
      parameters$mu[[class_k]] <- colMeans(xtrain[ytrain== class_k,])
      parameters$sigma[[class_k]] <- cov(xtrain[ytrain== class_k,])
    }
  }
  
  
  # GT, single model and equal model weights (if weights aren't given)
  if(is.null(model_weights)){
    # Ground truth
    model_weights <- list(GT = FALSE)
    
    # Single model
    for(n in 1:ncol(ytrain_noise)){
      annotator_n <- colnames(ytrain_noise)[n]
      model_weights[[annotator_n]] <- rep(FALSE,ncol(ytrain_noise))
      model_weights[[annotator_n]][n] <- TRUE
    }
    
    # Equal weight
    model_weights[['Equal weight']] <- rep(1,ncol(ytrain_noise))
    
  }
  
  # Models
  output_component <- list(accuracy = NA,meanError = NA,sigmaError = NA, 
                          sigmaEstimated = list())
  output <- list()
  class_name <- unique(ytrain)
  num_class <- length(class_name)

  model_name <- names(model_weights)

  for(m in 1:length(model_weights)){
    model_m <- as.character(model_name[m])
    
    if(is.logical(model_weights[[model_m]])){
      # GT
      if(all(!model_weights[[model_m]])){
        for(mm in 1:length(mclust_model_name)){
          model_mm <- mclust_model_name[mm]
          
          if(model_mm ==""){
            model_mm = "EDDA"
            name_mm = NULL
          }
          if(model_mm == "LDA"){
            name_mm = "EII"
          }
          if(model_mm == "QDA"){
            name_mm = "VVV"
          }
          output[[model_m]][[model_mm]] <- output_component
          
          mod <- MclustDA(xtrain,ytrain,modelNames = name_mm, modelType = "EDDA", verbose = FALSE)
          
          if(!is.null(mod)){
            pred <- predict.MclustDA(mod, newdata = xtest, newclass = ytest) 
        
            # Accuracy
            cm <- confusionMatrix(data = as.factor(pred$classification), reference = as.factor(ytest))
            output[[model_m]][[model_mm]]$accuracy <- cm$overall[1]
            
            meanerr <- 0
            sigmaerr <- 0
            
            
            # Mean and Sigma error
            for(k in 1:num_class){
              class_k <- class_name[k]
              
              # Estimated parameters
              estimated_mu <- mod$models[[class_k]]$parameters$mean
              estimated_sigma <- mod$models[[class_k]]$parameters$variance$sigma[,,1]
              output[[model_m]]$meanEstimated[[class_k]] <- estimated_mu
              output[[model_m]][[model_mm]]$sigmaEstimated[[class_k]] <- estimated_sigma
              
              # True parameters
              mu <- parameters$mu[[class_k]]
              sigma <- parameters$sigma[[class_k]]
              
              meanerrk <- norm(mu-estimated_mu,type="2")
              sigmaerrk <- norm(sigma-estimated_sigma,type="F")

              meanerr <- meanerr + meanerrk
              sigmaerr <- sigmaerr + sigmaerrk
              

            }

            output[[model_m]][[model_mm]]$meanError <- meanerr/num_class
            output[[model_m]][[model_mm]]$sigmaError <- sigmaerr/num_class
          }
          
        }      
      }
    }
      
    # Single model
    if(is.logical(model_weights[[model_m]]) && !all(model_weights[[model_m]]) && any(model_weights[[model_m]])){
      for(mm in 1:length(mclust_model_name)){
        model_mm <- mclust_model_name[mm]
       
        if(model_mm ==""){
          model_mm = "EDDA"
          name_mm = NULL
        }
        if(model_mm == "LDA"){
          name_mm = "EII"
        }
        if(model_mm == "QDA"){
          name_mm = "VVV"
        }
        output[[model_m]][[model_mm]] <- output_component
        
        Y.train_single_model <- ytrain_noise[,which(model_weights[[model_m]])]
        mod <- MclustDA(xtrain, Y.train_single_model,modelNames = name_mm, modelType = "EDDA", verbose = FALSE)
        
        if(!is.null(mod)){
          pred <- predict.MclustDA(mod, newdata = xtest, newclass = ytest)
          
          # Accuracy
          cm <- confusionMatrix(data = as.factor(pred$classification), reference = as.factor(ytest))
          output[[model_m]][[model_mm]]$accuracy <- cm$overall[1]
          
          meanerr <- 0
          sigmaerr <- 0
          
          # Mean and Sigma error
          for(k in 1:num_class){
            class_k <- class_name[k]
            
            # Estimated parameters
            estimated_mu <- mod$models[[class_k]]$parameters$mean
            estimated_sigma <- mod$models[[class_k]]$parameters$variance$sigma[,,1]
            output[[model_m]]$meanEstimated[[class_k]] <- estimated_mu
            output[[model_m]][[model_mm]]$sigmaEstimated[[class_k]] <- estimated_sigma
            
            if(model_mm == "EDDA"){
              output[[model_m]][["modelNames"]][[class_k]] <- mod$models[[class_k]]$modelName
            }
            
            # True parameters
            mu <- parameters$mu[[class_k]]
            sigma <- parameters$sigma[[class_k]]
            
            meanerrk <- norm(mu-estimated_mu,type="2")
            sigmaerrk <- norm(sigma-estimated_sigma,type="F")
            
            meanerr <- meanerr + meanerrk
            sigmaerr <- sigmaerr + sigmaerrk
            
          }
          
          output[[model_m]][[model_mm]]$meanError <- meanerr/num_class
          output[[model_m]][[model_mm]]$sigmaError <- sigmaerr/num_class

        }
      }
    }
    
    # Ensemble model
    if(is.numeric(model_weights[[model_m]])){
      
      weights <- model_weights[[model_m]]
      for(mm in 1:length(mclust_model_name)){
        model_mm <- mclust_model_name[mm]
        
        if(model_mm ==""){
          model_mm = "EDDA"
        }
        output[[model_m]][[model_mm]] <- output_component
        
        mod <- ensemble_model(xtrain,ytrain_noise, modelName = mclust_model_name[mm], w= weights)

        if(!is.null(mod)){
          pred <- prediction_ensemble_model(xtest, mod, Ytest = ytest)

          # Accuracy
          cm <- confusionMatrix(data = as.factor(pred$classification), reference = as.factor(ytest))
          output[[model_m]][[model_mm]]$accuracy <- cm$overall[1]
          output[[model_m]][["weights"]] <- weights
          
          # if (model_name[m] == "ExpertBeginner2" && model_mm =="LDA"){
          #   conf_matrix_df <- cm$table
          #   class_accuracies <- diag(conf_matrix_df) / rowSums(conf_matrix_df)
          # 
          #   ref <- as.factor(ytest)
          #   ref <- recode(ref, "adenoma" = "malignant", "serrated" = "malignant")
          #   pred_binary <- pred$classification
          #   pred_binary <- recode(pred_binary, "adenoma" = "malignant", "serrated" = "malignant")
          # 
          #   sen <- sensitivity(pred_binary,ref)
          #   prec <- posPredValue(pred_binary,ref)
          #   spec <- specificity(pred_binary,ref)
          #   NPV <- negPredValue(pred_binary,ref)
          # 
          #   extra_out <- c(class_accuracies,sen,prec,spec,NPV)
          # }
          
          meanerr <- 0
          sigmaerr <- 0
          
          # Mean and Sigma error
          for(k in 1:num_class){
            class_k <- class_name[k]
            
           
            estimated_mu <- mod$models[[class_k]]$mean
            estimated_sigma <- mod$models[[class_k]]$variance$sigma[,,1]
            output[[model_m]]$meanEstimated[[class_k]] <- estimated_mu
            output[[model_m]][[model_mm]]$sigmaEstimated[[class_k]] <- estimated_sigma
            
            # True parameters
            mu <- parameters$mu[[class_k]]
            sigma <- parameters$sigma[[class_k]]
            
            meanerrk <- norm(mu-estimated_mu,type="2")
            sigmaerrk <- norm(sigma-estimated_sigma,type="F")

            meanerr <- meanerr + meanerrk
            sigmaerr <- sigmaerr + sigmaerrk
            
          }

          output[[model_m]][[model_mm]]$meanError <- meanerr/num_class
          output[[model_m]][[model_mm]]$sigmaError <- sigmaerr/num_class
        }
      }
      
    }
  }
  
  
  output[["ModelNames"]] <- model_name
  #output[["Acc_single"]] <- extra_out
  return(output)
}