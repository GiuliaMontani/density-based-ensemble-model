ensemble_model <- function(Xtrain,
                           Ytrain,
                           mclustModel = "EDDA",
                           modelName = "",
                           w = 1,
                           seed = NA)
{
  if(!is.na(seed)){
    set.seed(seed)
  }
  Xtrain <- as.matrix(Xtrain)
  Ytrain <- as.matrix(Ytrain)
  num_var <- dim(Xtrain)[2]
  class_name <- levels(as.factor(unique(Ytrain)))
  num_class <- length(class_name)

  models <- list()
  modType <- list()
  modName <- list()
  mean <- list()
  variance <- list()
  prop <- matrix(0,1,num_class)
  colnames(prop) <- class_name
  for(k in 1:num_class){
    class_k <- class_name[k]
    mean[[class_k]] <- matrix(0,num_var,1)
    variance[[class_k]]$sigma <- array(0,dim = c(num_var,num_var,1))
    modName[[class_k]] <- list()
    models[[class_k]] <- list()
  }
  
  w <- matrix(as.matrix(w), nrow = 1 , ncol = dim(Ytrain)[2])  
  

  for (i in 1:dim(Ytrain)[2]) { 
    Ytrain_doct_i <- Ytrain[,i]
    
    if(modelName == ""){
      mod <- MclustDA(Xtrain, Ytrain_doct_i, modelType = mclustModel, verbose = FALSE)
    } else if(modelName == "QDA"){
      mod <- MclustDA(Xtrain, Ytrain_doct_i, modelType = mclustModel, modelNames = "VVV", verbose = FALSE)
    } else if(modelName == "LDA")
    {
      mod <- MclustDA(Xtrain, Ytrain_doct_i, modelType = mclustModel, modelNames = "EEE", verbose = FALSE)

    }
    
    if(!is.null(mod) && sum(w)!=0){
      for(k in 1:num_class){
        class_k <- class_name[k]
        model_k <- mod$models[[k]]
        mean[[class_k]] <- mean[[class_k]] + w[i]*model_k$parameters$mean
        variance[[class_k]]$sigma <- variance[[class_k]]$sigma + w[i]*model_k$parameters$variance$sigma #[,,1]
        modName[[class_k]][[colnames(Ytrain)[i]]] <- model_k$modelName
        
      }
      
      modType[[colnames(Ytrain)[i]]] <- mod$type
      prop <- prop + w[i]*mod$prop
    }
    else{
      return(NULL)
    }
  }
  
  prop <- prop/sum(w)
  for(k in 1:num_class){
    class_k <- class_name[k]
    mean[[class_k]] <- mean[[class_k]]/sum(w)
    variance[[class_k]]$sigma <- variance[[class_k]]$sigma/sum(w)
    models[[class_k]]$mean <- mean[[class_k]] 
    models[[class_k]]$variance$sigma <- variance[[class_k]]$sigma
  }


  output <- list(models = models,
                 prop = prop,
                 modelType = modType,
                 modelName = modName)
  
  
  return(output)
}
