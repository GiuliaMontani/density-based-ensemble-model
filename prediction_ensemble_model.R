prediction_ensemble_model <- function(Xtest,
               Ytest,
               model)
{
  Xtest <- as.matrix(Xtest)
  Ytest <- as.matrix(Ytest)
  
  class_name <- levels(as.factor(unique(Ytest)))
  num_class <- length(class_name)
  
  z <- matrix(as.double(NA), nrow = nrow(Xtest), ncol= num_class)
  
  if(!is.null(model)){
    for (i in 1:dim(Xtest)[1]){
      for(k in 1:num_class){
        class_k <- class_name[k]
        model_k <- model$models[[k]]
        z[i,k] <- model$prop[k]*exp(-0.5*t(Xtest[i,]- model_k$mean)%*%solve(model_k$variance$sigma[,,1])%*%(Xtest[i,]- model_k$mean))/(2*pi^5*det(model_k$variance$sigma[,,1]))
      }
    }
    z <- z/rowSums(z)
    colnames(z) <- class_name
    cl <- apply(z,1,which.max)
    class <- factor(class_name[cl], levels = class_name)
    output <- list(classification = class, z = z)
    return(output)
  }
  else{
    output <- list(classification =NULL, z=z)
  }
  
}

      
  