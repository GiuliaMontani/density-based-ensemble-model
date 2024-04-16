visualizationResult <- function(Out,
                                name){
  
  cd <- getwd()
  path = paste0(cd,"/",name)
  dir.create(path)
  
  # Save the list to an RDS file
  resultPath = paste0(path,paste0("/result.rds"))
  saveRDS(Out, file = resultPath)
  
  # GT Single model and Equal weight indexes
  index1 <- c(1:(Out$NumberAnnotators+2))
  
  # GT and Ensemble model indexes
  index2 <- c(1,(Out$NumberAnnotators+2):(Out$NumberAnnotators+11))
  
  # Y limits
  ymaxACC = max(Out$Accuracy$AccuracyLDA,Out$Accuracy$AccuracyQDA ,Out$Accuracy$AccuracyEDDA, na.rm=TRUE)
  yminACC = floor(min(Out$Accuracy$AccuracyLDA,Out$Accuracy$AccuracyQDA ,Out$Accuracy$AccuracyEDDA, na.rm=TRUE)*10)/10
  ymaxMSE = max(Out$MeanError$MeanErrorLDA, Out$MeanError$MeanErrorQDA, Out$MeanError$MeanErrorEDDA, na.rm=TRUE)
  ymaxCSE = max(Out$SigmaError$SigmaErrorLDA, Out$SigmaError$SigmaErrorQDA, Out$SigmaError$SigmaErrorEDDA, na.rm= TRUE)
  
  
  # Model
  subpathM = paste0(path,"/BoxplotModels")
  dir.create(subpathM)
  
  imgPath = paste0(subpathM,"/AccuracyLDA.png")
  png(file = imgPath)
  boxplot(Out$Accuracy$AccuracyLDA[,index1],
          main = "Accuracy LDA",
          names = Out$ModelName[index1],
          col = rep("lightblue",length(index1)),
          outline=FALSE,
          ylim = c(yminACC,ymaxACC))
  abline(h=colMeans(Out$Accuracy$AccuracyLDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$Accuracy$AccuracyLDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/AccuracyLDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$Accuracy$AccuracyLDA[,index2],
          main = "Accuracy LDA",
          names = Out$ModelName[index2],
          col = rep("deepskyblue",length(index2)),
          outline=FALSE,
          ylim = c(yminACC,ymaxACC))
  abline(h=colMeans(Out$Accuracy$AccuracyLDA)[1], col = "red3",lwd=3)
  dev.off()

  
  imgPath = paste0(subpathM,"/AccuracyQDA.png")
  png(file = imgPath)
  boxplot(Out$Accuracy$AccuracyQDA[,index1],
          main = "Accuracy QDA",
          names = Out$ModelName[index1],
          col = rep("#CC99FF",length(index1)),
          outline=FALSE,
          ylim = c(yminACC,ymaxACC))
  abline(h=colMeans(Out$Accuracy$AccuracyQDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$Accuracy$AccuracyQDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/AccuracyQDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$Accuracy$AccuracyQDA[,index2],
          main = "Accuracy QDA",
          names = Out$ModelName[index2],
          col = rep("purple",length(index2)),
          outline=FALSE,
          ylim = c(yminACC,ymaxACC))
  abline(h=colMeans(Out$Accuracy$AccuracyQDA)[1], col = "red3",lwd=3)
  dev.off()
  

  imgPath = paste0(subpathM,"/AccuracyEDDA.png")
  png(file = imgPath)
  boxplot(Out$Accuracy$AccuracyEDDA[,index1],
          main = "Accuracy EDDA",
          names = Out$ModelName[index1],
          col = rep("#FFF592",length(index1)),
          outline=FALSE,
          ylim = c(yminACC,ymaxACC))
  abline(h=colMeans(Out$Accuracy$AccuracyEDDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$Accuracy$AccuracyEDDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/AccuracyEDDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$Accuracy$AccuracyEDDA[,index2],
          main = "Accuracy EDDA",
          names = Out$ModelName[index2],
          col = rep("#FFEB3B",length(index2)),
          outline=FALSE,
          ylim = c(yminACC,ymaxACC))
  abline(h=colMeans(Out$Accuracy$AccuracyEDDA)[1], col = "red3",lwd=3)
  dev.off()
  # ****
  imgPath = paste0(subpathM,"/MeanErrorLDA.png")
  png(file = imgPath)
  boxplot(Out$MeanError$MeanErrorLDA[,index1],
          main = "Mean Error LDA",
          names = Out$ModelName[index1],
          col = rep("lightblue",length(index1)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$MeanError$MeanErrorLDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$MeanError$MeanErrorLDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/MeanErrorLDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$MeanError$MeanErrorLDA[,index2],
          main = "Mean Error LDA",
          names = Out$ModelName[index2],
          col = rep("deepskyblue",length(index2)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$MeanError$MeanErrorLDA)[1], col = "red3",lwd=3)
  dev.off()
  
  
  imgPath = paste0(subpathM,"/MeanErrorQDA.png")
  png(file = imgPath)
  boxplot(Out$MeanError$MeanErrorQDA[,index1],
          main = "Mean Error QDA",
          names = Out$ModelName[index1],
          col = rep("#CC99FF",length(index1)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$MeanError$MeanErrorQDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$MeanError$MeanErrorQDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/MeanErrorQDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$MeanError$MeanErrorQDA[,index2],
          main = "Mean Error QDA",
          names = Out$ModelName[index2],
          col = rep("purple",length(index2)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$MeanError$MeanErrorQDA)[1], col = "red3",lwd=3)
  dev.off()
  
 
  imgPath = paste0(subpathM,"/MeanErrorEDDA.png")
  png(file = imgPath)
  boxplot(Out$MeanError$MeanErrorEDDA[,index1],
          main = "Mean Error EDDA",
          names = Out$ModelName[index1],
          col = rep("#FFF592",length(index1)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$MeanError$MeanErrorEDDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$MeanError$MeanErrorEDDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/MeanErrorEDDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$MeanError$MeanErrorEDDA[,index2],
          main = "Mean Error EDDA",
          names = Out$ModelName[index2],
          col = rep("#FFEB3B",length(index2)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$MeanError$MeanErrorEDDA)[1], col = "red3",lwd=3)
  dev.off()
  

  imgPath = paste0(subpathM,"/SigmaErrorLDA.png")
  png(file = imgPath)
  boxplot(Out$SigmaError$SigmaErrorLDA[,index1],
          main = "Sigma Error LDA",
          names = Out$ModelName[index1],
          col = rep("lightblue",length(index1)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$SigmaError$SigmaErrorLDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$SigmaError$SigmaErrorLDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/SigmaErrorLDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$SigmaError$SigmaErrorLDA[,index2],
          main = "Sigma Error LDA",
          names = Out$ModelName[index2],
          col = rep("deepskyblue",length(index2)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$SigmaError$SigmaErrorLDA)[1], col = "red3",lwd=3)
  dev.off()
  

  imgPath = paste0(subpathM,"/SigmaErrorQDA.png")
  png(file = imgPath)
  boxplot(Out$SigmaError$SigmaErrorQDA[,index1],
          main = "Sigma Error QDA",
          names = Out$ModelName[index1],
          col = rep("#CC99FF",length(index1)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$SigmaError$SigmaErrorQDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$SigmaError$SigmaErrorQDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/SigmaErrorQDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$SigmaError$SigmaErrorQDA[,index2],
          main = "Sigma Error QDA",
          names = Out$ModelName[index2],
          col = rep("purple",length(index2)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$SigmaError$SigmaErrorQDA)[1], col = "red3",lwd=3)
  dev.off()
  

  imgPath = paste0(subpathM,"/SigmaErrorEDDA.png")
  png(file = imgPath)
  boxplot(Out$SigmaError$SigmaErrorEDDA[,index1],
          main = "Sigma Error EDDA",
          names = Out$ModelName[index1],
          col = rep("#FFF592",length(index1)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$SigmaError$SigmaErrorEDDA)[1], col = "red3",lwd=3)
  abline(h=colMeans(Out$SigmaError$SigmaErrorEDDA)[Out$NumberAnnotators+2], col = "red3", lty = 2, lwd=3)
  dev.off()
  
  imgPath = paste0(subpathM,"/SigmaErrorEDDAensembleModel.png")
  png(file = imgPath)
  boxplot(Out$SigmaError$SigmaErrorEDDA[,index2],
          main = "Sigma Error EDDA",
          names = Out$ModelName[index2],
          col = rep("#FFEB3B",length(index2)),
          outline=FALSE,
          ylim = c(0.0,ymaxMSE))
  abline(h=colMeans(Out$SigmaError$SigmaErrorEDDA)[1], col = "red3",lwd=3)
  dev.off()
  
  # Table visualization
  subpathN = paste0(path,"/NumericalResult")
  dir.create(subpathN)
  
  filePath = paste0(subpathN,"/Accuracy.csv")
  accuracy <- rbind(formatC(colMeans(Out$Accuracy$AccuracyLDA, na.rm= TRUE),digits = 3,format="f"),
                     formatC(colMeans(Out$Accuracy$AccuracyQDA, na.rm= TRUE),digits=3, format = "f"),
                     formatC(colMeans(Out$Accuracy$AccuracyEDDA, na.rm= TRUE),digits=3,format = "f"))
  accuracy <- as.data.frame(accuracy, row.names = c("LDA","QDA","EDDA"))
  write.csv(accuracy,filePath, row.names = TRUE)
  
  filePath = paste0(subpathN,"/MSE.csv")
  meanEr <- rbind(formatC(colMeans(Out$MeanError$MeanErrorLDA, na.rm= TRUE),digits = 3,format="f"))
  meanEr <- as.data.frame(meanEr, row.names = c("LDA","QDA","EDDA"))
  write.csv(meanEr,filePath, row.names = FALSE)
  
  filePath = paste0(subpathN,"/CSE.csv")
  sigmaEr <- rbind(formatC(colMeans(Out$SigmaError$SigmaErrorLDA, na.rm= TRUE),digits = 3,format="f"),
                   formatC(colMeans(Out$SigmaError$SigmaErrorQDA, na.rm= TRUE),digits=3, format = "f"),
                   formatC(colMeans(Out$SigmaError$SigmaErrorEDDA, na.rm= TRUE),digits=3,format = "f"))
  sigmaEr <- as.data.frame(sigmaEr, row.names = c("LDA","QDA","EDDA"))
  write.csv(sigmaEr,filePath, row.names = TRUE)
  
  filePath = paste0(subpathN,"/SD.csv")
  standard_errorsAcc <- rbind(formatC(sqrt(apply(Out$Accuracy$AccuracyLDA, 2, var)),digits = 3,format="f"),
                           formatC(sqrt(apply(Out$Accuracy$AccuracyQDA, 2, var)),digits=3, format = "f"),
                           formatC(sqrt(apply(Out$Accuracy$AccuracyEDDA, 2, var)),digits=3,format = "f"))
  sd_acc <- as.data.frame(standard_errorsAcc, row.names = c("LDA","QDA","EDDA"))
  write.csv(sd_acc,filePath, row.names = TRUE)
  
}
