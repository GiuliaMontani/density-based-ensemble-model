select_observation <- function(Ytrain,
                               agree){
  Ytrain <- as.matrix(Ytrain)
  count <- matrix(0,1,dim(Ytrain)[2])
  label <- NULL
  
  for(i in 1:dim(Ytrain)[2]){
    # label assigned with majority voting
    label[i] = names(which.max(table(Ytrain[,i])))
    
    for (j in 1:dim(Ytrain)[1]){
      if(Ytrain[j,i] == label[i])
      {
        count[1,i] <- count[1,i] + 1
      }
    }
  }
  set <- count[1,] >= agree

  if(all(!set)){
    Ytrain_out <- NULL
    label_out <- NULL
  }
  else{
    label_out <-  label[set]
    Ytrain_out <- Ytrain[,set]
  }
  out <- list(Y = Ytrain_out,
              label = label_out)
  
  return(out)
}