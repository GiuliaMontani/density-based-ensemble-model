score <- function(Y,
                  label,
                  class = FALSE){
  score <- matrix(0,1,ncol(Y))
  
  for (i in 1:length(label)){
    for (j in 1:ncol(Y)[1]){
      
      if(Y[i,j] == label[i]){
          score[1,j] <- score[1,j] +1
       
        }
      }
    }
  
  return(score)
}