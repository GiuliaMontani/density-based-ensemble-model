weights_generation <- function(modelName = c("GT","SingleModel","EqualWeight","ExpertBeginner1","ExpertBeginner2","ExpertBeginner3",
                                             "MV1","MV2","someGT","IterAlg1LDA","IterAlg2LDA","IterAlg1QDA","IterAlg2QDA",
                                             "IterAlg1EDDA","IterAlg2EDDA"), #"GT","SingleModel"
                               xtrain = NULL,
                               ytrain_noise = NULL,
                               ytrain = NULL,
                               ytest = NULL,
                               Nannotators = NULL,
                               N_exp = NULL,
                               N_beg = NULL,
                               positionExpert = NULL,
                               positionBeginner = NULL){
  
  defaultModelName <- c("GT","SingleModel","EqualWeight","ExpertBeginner1","ExpertBeginner2","ExpertBeginner3",
                        "MV1","MV2","someGT","IterAlg1LDA","IterAlg2LDA","IterAlg1QDA","IterAlg2QDA",
                        "IterAlg1EDDA","IterAlg2EDDA")
  
  if(!is.null(Nannotators) && Nannotators != N_exp+N_beg){
    stop("Error : number of annotators must be equal to number of expert plus number of begginer")
  }
  
  if(!is.null(Nannotators) && (is.null(positionExpert) || is.null(positionBeginner))){
    positionExpert = c(rep(1,N_exp),rep(0,N_beg))
    positionBeginner = c(rep(0,N_exp),rep(1,N_beg))
  }
  
  if(sum(modelName == defaultModelName) != length(modelName)){
    print(sum(modelName == defaultModelName))
    stop("Error : invalid model name")
  }
  
  if(is.null(Nannotators) && !is.null(ytrain_noise)){
    Nannotators = ncol(ytrain_noise)
  }
  
  if(!is.numeric(positionExpert) || !is.numeric(positionBeginner)){
    stop("Error : Vector specifying expert and beginner must be numeric of the form c(1,1,0,1,...)")
  }
  
  if(!is.null(Nannotators) && Nannotators != sum(sum(positionExpert),sum(positionBeginner))){
    stop("Error : Number of expert plus number of beginners is different from total number of annotators")
  }
  
  if((any(modelName=="SingleModel") || any(modelName=="EqualWeight")) && is.null(Nannotators)){
    
    stop("Error : Number of annotators or y noise are needed for single models") 
    
  }
  
  if((any(modelName == "ExpertBeginner1") || any(modelName == "ExpertBeginner2") || any(modelName == "ExpertBeginner3")) && 
     (is.null(N_exp) || is.null(N_beg))){
    stop("Error : Number of experts and beginners is needed for the models ExpertBeginner")
  }
  
  if((any(modelName=="MV1") || any(modelName=="MV2")) && (is.null(ytrain_noise))){
    stop("Error : y noise is needed for the models Majority Voting 1 and 2")
  }
  
  if(any(modelName == "someGT") && any(is.null(ytrain_noise),is.null(ytrain))){
    stop("Error : y and y noise are needed for the model some Ground Truth")
  }
  
  if((any(modelName=="IterAlg1") || any(modelName=="IterAlg2")) && 
     (any(is.null(ytrain_noise),is.null(xtrain),is.null(ytrain),is.null(ytest)))){
    stop("Error : y, y noise and x are needed for the models with iterative algorithm 1 and 2")
  }
  
  if(length(modelName)==0){
    stop("Error : no model selected")
  }
  
  weights <- matrix(NA, nrow = Nannotators, ncol = 0)
  weights <- as.data.frame(weights)
  

  for(mn in modelName){
    
    # Ground Truth
    if(mn == "GT"){
      weights <- cbind(weights, GT = FALSE)
    }
    
    # Single Model
    if(mn == "SingleModel"){
      single_weights <- matrix(FALSE, nrow = Nannotators, ncol = Nannotators)
      if(!is.null(colnames(ytrain_noise))){
        colnames(single_weights) <- colnames(ytrain_noise)
      }
      for(n_ann in 1:Nannotators){
        single_weights[n_ann,n_ann] <- TRUE
      }
      weights <- cbind(weights, single_weights)
    }
    
    # Equal Weights
    if(mn == "EqualWeight"){
      weights <- cbind( weights, EqualWeight = rep(1,Nannotators))
    }
    
    # Expert 0.7 Beginner 0.3
    if(mn == "ExpertBeginner1"){
      w_exp <- rep(0.7/N_exp,Nannotators)*positionExpert
      w_beg <- rep(0.3/N_beg,Nannotators)*positionBeginner
      weights <- cbind(weights, ExpertBeginner1 = w_exp+w_beg)
    }
    
    # Expert 0.8 Beginner 0.2
    if(mn == "ExpertBeginner2"){
      w_exp <- rep(0.8/N_exp,Nannotators)*positionExpert
      w_beg <- rep(0.2/N_beg,Nannotators)*positionBeginner
      weights <- cbind(weights, ExpertBeginner2 = w_exp+w_beg)
    }
    
    # Expert 0.9 Beginner 0.1
    if(mn == "ExpertBeginner3"){
      w_exp <- rep(0.9/N_exp,Nannotators)*positionExpert
      w_beg <- rep(0.1/N_beg,Nannotators)*positionBeginner
      weights <- cbind(weights, ExpertBeginner3 = w_exp+w_beg)
    }
    
    # Majority Voting for observation where 90% of annotators agree
    if(mn == "MV1"){
      agreement <- floor(Nannotators*0.9)
      score_obs <- select_observation(t(ytrain_noise),agreement)
      if(!is.null(score_obs$Y)){
        score_w <- score(t(score_obs$Y),score_obs$label)
        weights <- cbind(weights, MV1 = t(score_w)) 
      }
      else{
        weights <- cbind(weights , MV1 = 0) 
      }
    }
    
    # Majority Voting for observation where 80%
    if(mn == "MV2"){
      agreement <- floor(Nannotators*0.8)
      score_obs <- select_observation(t(ytrain_noise),agreement)
      if(!is.null(score_obs$Y)){
        score_w <- score(t(score_obs$Y),score_obs$label)
        weights <- cbind(weights, MV2 = t(score_w)) 
      }
      else{
        weights <- cbind(weights , MV2 = 0) 
      }
    }
    
    
    # Ground truth of 10% of observations is known
    if(mn == "someGT"){
      index_truth <- sample(1:nrow(xtrain), size = round(nrow(xtrain)*0.1), replace = FALSE)
      label_truth <- ytrain[index_truth]
      Y_truth <- ytrain_noise[index_truth,]
      
      score_w <- score(Y_truth, label_truth)
      weights <- cbind(weights, someGT = t(score_w))
    }
    
    # Iterative Algorithm with score method LDA
    if(mn == "IterAlg1LDA"){
      z <- matrix(0,nrow(ytrain_noise),length(unique(ytest)))
      max_it <- 50
      it <- 0
      
      # Initialize label as MV
      score_obs <- select_observation(t(ytrain_noise),0)
      label_it <- score_obs$label
      
      # Algorithm 
      while(it < max_it){
        score_w <- score(ytrain_noise,label_it)
        mod <- ensemble_model(xtrain,ytrain_noise, w = score_w, modelName = "LDA")
        pred <- prediction_ensemble_model(xtrain, mod, Ytest= ytest)
        z_new <- pred$z
        label_new <- pred$classification
        
        if(identical(z,z_new) == TRUE){
          it <- max_it
        }
        else{
          it <- it+1
          z <- z_new
          label_it <- label_new
        }
      }
      weights <- cbind(weights, IterAlg1LDA = t(score_w))
    }
    
    # Iterative Algorithm with z method LDA
    if(mn == "IterAlg2LDA"){
      
      # Initialize label as MV
      score_obs <- select_observation(t(ytrain_noise),0)
      label_it <- score_obs$label
      
      
      score_w <- matrix(NA,1,ncol(ytrain_noise))
      class_name <- levels(as.factor(unique(as.matrix(ytrain_noise))))
      num_class <- length(class_name)
      z <- list()
      
      # Initialize weights based on z computed on single model
      for(i in 1:ncol(ytrain_noise)){
        Y.train_single_model <- ytrain_noise[,i]
        
        mod <- MclustDA(xtrain, Y.train_single_model, modelType = "EDDA", verbose = FALSE, modelNames = "EEE")
        
        pred <- predict.MclustDA(mod, newdata = xtrain)
        z[[colnames(ytrain_noise)[i]]] <- pred$z
        for(n in 1:num_class){
          class_k <- class_name[n]
          score_w[i] <- sum(z[[colnames(ytrain_noise)[i]]][which(label_it==class_k),class_k])
        }
      }
      
      max_it <- 50
      it <- 0
      z_old <- NULL
      
      while(it < max_it){
        mod <- ensemble_model(xtrain,ytrain_noise, w = score_w, modelName = "LDA")
        pred <- prediction_ensemble_model(xtrain, mod, Ytest= ytest)
        z_new <- pred$z
        label_new <- pred$classification
        
        # Update score
        score_w <- matrix(0,1,ncol(ytrain_noise))
        for(i in 1:ncol(ytrain_noise)){
          for(n in 1:num_class){
            class_k <- class_name[n]
            score_w[i] <- score_w[i] + sum(z[[colnames(ytrain_noise)[i]]][which(label_new==class_k),class_k])
          }
        }
        
        if(identical(z_old,z_new) == TRUE && it > 1){
          it <- max_it
        }
        else{
          it <- it+1
          z_old <- z_new
          label_it <- label_new
        }
      }
      
      weights <- cbind(weights, IterAlg2LDA = t(score_w))
    }
    
    # Iterative Algorithm with score method QDA
    if(mn == "IterAlg1QDA"){
      z <- matrix(0,nrow(ytrain_noise),length(unique(ytest)))
      max_it <- 50
      it <- 0
      
      # Initialize label as MV
      score_obs <- select_observation(t(ytrain_noise),0)
      label_it <- score_obs$label

      # Algorithm 
      while(it < max_it){
        score_w <- score(ytrain_noise,label_it)
        mod <- ensemble_model(xtrain,ytrain_noise, w = score_w, modelName = "QDA")
        if(!is.null(mod)){
          pred <- prediction_ensemble_model(xtrain, mod, Ytest= ytest)
          z_new <- pred$z
          label_new <- pred$classification
          
          if(identical(z,z_new) == TRUE){
            it <- max_it
          }
          else{
            it <- it+1
            z <- z_new
            label_it <- label_new
          }
        }
        else{
          it = max_it
        }
      }
      weights <- cbind(weights, IterAlg1QDA = t(score_w))
    }
    
    # Iterative Algorithm with z method QDA
    # if(mn == "IterAlg2QDA"){
    # 
    #   # Initialize label as MV
    #   score_obs <- select_observation(t(ytrain_noise),0)
    #   label_it <- score_obs$label
    # 
    # 
    #   score_w <- matrix(NA,1,ncol(ytrain_noise))
    #   class_name <- levels(as.factor(unique(as.matrix(ytrain_noise))))
    #   num_class <- length(class_name)
    #   z <- list()

      # Initialize weights based on z computed on single model
    #   for(i in 1:ncol(ytrain_noise)){
    #     Y.train_single_model <- ytrain_noise[,i]
    # 
    #     mod <- MclustDA(xtrain, Y.train_single_model, modelType = "EDDA", verbose = FALSE, modelNames = "VVV")
    # 
    # 
    #     pred <- predict.MclustDA(mod, newdata = xtrain)
    #     z[[colnames(ytrain_noise)[i]]] <- pred$z
    #     for(n in 1:num_class){
    #       class_k <- class_name[n]
    #       score_w[i] <- sum(z[[colnames(ytrain_noise)[i]]][which(label_it==class_k),class_k])
    #     }
    # 
    #   }
    # 
    #   max_it <- 50
    #   it <- 0
    #   z_old <- NULL
    # 
    #   while(it < max_it){
    #     mod <- ensemble_model(xtrain,ytrain_noise, w = score_w, modelName = "QDA")
    #     if(!is.null(mod)){
    #       pred <- prediction_ensemble_model(xtrain, mod, Ytest= ytest)
    #       z_new <- pred$z
    #       label_new <- pred$classification
    # 
    #       # Update score
    #       score_w <- matrix(0,1,ncol(ytrain_noise))
    #       for(i in 1:ncol(ytrain_noise)){
    #         for(n in 1:num_class){
    #           class_k <- class_name[n]
    #           score_w[i] <- score_w[i] + sum(z[[colnames(ytrain_noise)[i]]][which(label_new==class_k),class_k])
    #         }
    #       }
    # 
    #       if(identical(z_old,z_new) == TRUE && it > 1){
    #         it <- max_it
    #       }
    #       else{
    #         it <- it+1
    #         z_old <- z_new
    #         label_it <- label_new
    #       }
    #     }
    #     else{
    #       it = max_it
    #     }
    # 
    #   }
    # 
    #   weights <- cbind(weights, IterAlg2QDA = t(score_w))
    # }
    
    # Iterative Algorithm with score method EDDA
    if(mn == "IterAlg1EDDA"){
      z <- matrix(0,nrow(ytrain_noise),length(unique(ytest)))
      max_it <- 50
      it <- 0
      
      # Initialize label as MV
      score_obs <- select_observation(t(ytrain_noise),0)
      label_it <- score_obs$label
      
      # Algorithm 
      while(it < max_it){
        score_w <- score(ytrain_noise,label_it)
        mod <- ensemble_model(xtrain,ytrain_noise, w = score_w)
        
        if(!is.null(mod)){
          pred <- prediction_ensemble_model(xtrain, mod, Ytest= ytest)
          z_new <- pred$z
          label_new <- pred$classification
          
          if(identical(z,z_new) == TRUE){
            it <- max_it
          }
          else{
            it <- it+1
            z <- z_new
            label_it <- label_new
          }}
        else{
          it = max_it
        }
      }
      weights <- cbind(weights, IterAlg1EDDA = t(score_w))
    }
    
    # Iterative Algorithm with z method EDDA
    if(mn == "IterAlg2EDDA"){
      
      # Initialize label as MV
      score_obs <- select_observation(t(ytrain_noise),0)
      label_it <- score_obs$label
      
      
      score_w <- matrix(NA,1,ncol(ytrain_noise))
      class_name <- levels(as.factor(unique(as.matrix(ytrain_noise))))
      num_class <- length(class_name)
      z <- list()
      
      # Initialize weights based on z computed on single model
      for(i in 1:ncol(ytrain_noise)){
        Y.train_single_model <- ytrain_noise[,i]
        
        mod <- MclustDA(xtrain, Y.train_single_model, modelType = "EDDA", verbose = FALSE)
        
        pred <- predict.MclustDA(mod, newdata = xtrain)
        z[[colnames(ytrain_noise)[i]]] <- pred$z
        for(n in 1:num_class){
          class_k <- class_name[n]
          score_w[i] <- sum(z[[colnames(ytrain_noise)[i]]][which(label_it==class_k),class_k])
        }
      }
      
      max_it <- 50
      it <- 0
      z_old <- NULL
      
      while(it < max_it){
        mod <- ensemble_model(xtrain,ytrain_noise, w = score_w)
        pred <- prediction_ensemble_model(xtrain, mod, Ytest= ytest)
        z_new <- pred$z
        label_new <- pred$classification
        
        # Update score
        score_w <- matrix(0,1,ncol(ytrain_noise))
        for(i in 1:ncol(ytrain_noise)){
          for(n in 1:num_class){
            class_k <- class_name[n]
            score_w[i] <- score_w[i] + sum(z[[colnames(ytrain_noise)[i]]][which(label_new==class_k),class_k])
          }
        }
        
        if(identical(z_old,z_new) == TRUE && it > 1){
          it <- max_it
        }
        else{
          it <- it+1
          z_old <- z_new
          label_it <- label_new
        }
      }
      
      weights <- cbind(weights, IterAlg2EDDA = t(score_w))
    }
    
  }
  
  return(weights)
}