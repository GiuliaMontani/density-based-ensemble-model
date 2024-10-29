save_result_for_paper <- function(result,
                                  path,
                                  simulation_type = NA,
                                  real_data = FALSE){
  if (real_data == TRUE){
    path_csv <- file.path(path, "table6.csv")
    simulation_type <- 1
  } else {
    path_csv <- file.path(path, paste0(simulation_type, "table4.csv"))
  }
  
  models_name <- c("GT","E2","N3","PGT","EN","E","MV","ItAlg1","ItAlg2")
  indexLDA <- c(1,3,8,15,11,9,13,16,17)
  indexQDA <- c(1,3,8,15,11,9,13,18,18)
  indexEDDA <- c(1,3,7,15,11,9,13,19,20)
  
  ACC_LDA <- result$Accuracy$AccuracyLDA
  ACC_LDA <- ACC_LDA[,indexLDA]
  colnames(ACC_LDA) <- models_name
  acc_dataLDA <- data.frame(ACC = c(ACC_LDA), Model= rep(models_name, each = nrow(ACC_LDA)))
  
  ACC_QDA <- result$Accuracy$AccuracyQDA
  ACC_QDA <- ACC_QDA[,indexQDA]
  colnames(ACC_QDA) <- models_name
  acc_dataQDA <- data.frame(ACC = c(ACC_QDA), Model = rep(models_name, each = nrow(ACC_QDA)))
  
  ACC_EDDA <- result$Accuracy$AccuracyEDDA
  ACC_EDDA <- ACC_EDDA[,indexEDDA]
  colnames(ACC_EDDA) <- models_name
  acc_dataEDDA <- data.frame(ACC = c(ACC_EDDA), Model = rep(models_name, each = nrow(ACC_EDDA)))

  MSE <- result$MeanError$MeanErrorLDA
  MSE <- MSE[,indexLDA]
  colnames(MSE) <- models_name
  mse_data <- data.frame(MSE = c(MSE), Model = rep(models_name, each = nrow(MSE)))
  
  CSE_LDA <- result$SigmaError$SigmaErrorLDA
  CSE_LDA <- CSE_LDA[,indexLDA]
  colnames(CSE_LDA) <- models_name
  cse_dataLDA <- data.frame(CSE = c(CSE_LDA), Model = rep(models_name, each = nrow(MSE)))
  
  CSE_QDA <- result$SigmaError$SigmaErrorQDA
  CSE_QDA <- CSE_QDA[,indexQDA]
  colnames(CSE_QDA) <- models_name
  cse_dataQDA <- data.frame(CSE = c(CSE_QDA), Model = rep(models_name, each = nrow(MSE)))
  
  CSE_EDDA <- result$SigmaError$SigmaErrorEDDA
  CSE_EDDA <- CSE_EDDA[,indexEDDA]
  colnames(CSE_EDDA) <- models_name
  cse_dataEDDA <- data.frame(CSE = c(CSE_EDDA), Model = rep(models_name, each = nrow(MSE)))
  
  result_df  <- data.frame(ACC_LDA = colMeans(ACC_LDA),
                       ACC_LDA_sd = apply(ACC_LDA, 2, sd),
                       ACC_QDA = colMeans(ACC_QDA),
                       ACC_QDA_sd = apply(ACC_QDA, 2, sd),
                       ACC_EDDA = colMeans(ACC_EDDA),
                       ACC_EDDA_sd = apply(ACC_EDDA, 2, sd),
                       MSE = colMeans(MSE),
                       CSE_LDA = colMeans(CSE_LDA),
                       CSE_QDA = colMeans(CSE_QDA),
                       CSE_EDDA = colMeans(CSE_EDDA))
  
  write.csv(result_df, file = path_csv, row.names = FALSE)
  cat("Numeric results saved to:", path_csv, "\n") 
  
  weightsPGT1 <- result$weights$someGT
  
  weightsMV1 <- result$weights$MV1
  
  weightsMV2 <- result$weights$MV2
  
  weightsItAlg1LDA1 <- result$weights$IterAlg1LDA
  
  weightsItAlg2LDA1 <- result$weights$IterAlg2LDA
  
  weightsItAlg1QDA1 <- result$weights$IterAlg1QDA
  
  weightsItAlg2QDA1 <- result$weights$IterAlg2QDA
  
  weightsItAlg1EDDA1 <- result$weights$IterAlg1EDDA
  
  weightsItAlg2EDDA1 <- result$weights$IterAlg2EDDA
  
  if (simulation_type == 1){
    if (real_data == FALSE){
      mse_plot <- ggplot(mse_data, aes(x = Model, y = MSE, fill = Model)) +
        geom_boxplot(fill=c("lightgray","lightgray","lightgray"  ,"#999999","#999999" ,"#999999" ,"#999999","#999999" ,"#999999"  ), color="black") +
        scale_x_discrete(limits=models_name)+
        geom_hline(yintercept=median(MSE[,1]), color = "red")+
        geom_hline(yintercept=median(MSE[,5]), linetype="dashed", color = "red")
      mse_plot_file <- file.path(path, "figure4_mse.png")
      ggsave(filename = mse_plot_file, plot = mse_plot, width = 10, height = 6, dpi = 300)
      cat("Figure4 MSE plot saved to:", mse_plot_file, "\n")
      
      cseLDA_plot <- ggplot(cse_dataLDA, aes(x = Model, y = CSE, fill = Model)) +
        geom_boxplot(fill = c("lightblue","lightblue","lightblue","deepskyblue","deepskyblue","deepskyblue","deepskyblue","deepskyblue","deepskyblue"), color = "black") +
        labs(title = "LDA") +
        scale_x_discrete(limits=models_name)+
        geom_hline(yintercept=median(CSE_LDA[,1]), color = "red")+
        geom_hline(yintercept=median(CSE_LDA[,5]), linetype="dashed", color = "red")+
        ylim(0,7)
      
      cseQDA_plot <- ggplot(cse_dataQDA, aes(x = Model, y = CSE, fill = Model)) +
        geom_boxplot(fill = c("#CC99FF","#CC99FF","#CC99FF","purple","purple","purple","purple","purple","purple"), color = "black") +
        labs(title = "QDA") +
        scale_x_discrete(limits=models_name)+
        geom_hline(yintercept=median(CSE_QDA[,1]), color = "red")+
        geom_hline(yintercept=median(CSE_QDA[,5]), linetype="dashed", color = "red")+
        ylim(0,7)
      
      cseEDDA_plot <- ggplot(cse_dataEDDA, aes(x = Model, y = CSE, fill = Model)) +
        geom_boxplot(fill = c("#FFF592","#FFF592","#FFF592","#FFEB3B","#FFEB3B","#FFEB3B","#FFEB3B","#FFEB3B","#FFEB3B"), color = "black") +
        labs(title = "EDDA") +
        scale_x_discrete(limits=models_name)+
        geom_hline(yintercept=median(CSE_EDDA[,1]), color = "red")+
        geom_hline(yintercept=median(CSE_EDDA[,5]), linetype="dashed", color = "red")+
        ylim(0,7)
      
      grid_plot <- grid.arrange(
        cseLDA_plot, cseQDA_plot, cseEDDA_plot,
        ncol = 3, nrow = 1
      )
      CSE_file <- file.path(path, "figure5_CSE.png")
      ggsave(filename = CSE_file, plot = grid_plot, width = 10, height = 10, dpi = 300)
      cat("Figure5 CSE saved to:", CSE_file, "\n")
    }
    
    annotator_name <- c("E1","E2","E3","E4","N1","N2","N3")
    annotator_class <- c("E","E","E","E","N","N","N")
    
    weights_data_PGT <- data.frame(
      weights = c(as.matrix(weightsPGT1)/rowSums(as.matrix(weightsPGT1))),
      annotator = rep(annotator_name, each = nrow(weightsPGT1)),
      annotatorClass = rep(annotator_class, each = nrow(weightsPGT1))
    )
    
    weights_data_MV2 <- data.frame(
      weights = c(as.matrix(weightsMV2)/rowSums(as.matrix(weightsMV2))),
      annotator = rep(annotator_name, each = nrow(weightsMV2)),
      annotatorClass = rep(annotator_class, each = nrow(weightsMV2))
    )
    
    weights_data_italg1LDA <- data.frame(
      weights = c(as.matrix(weightsItAlg1LDA1)/rowSums(as.matrix(weightsItAlg1LDA1))),
      annotator = rep(annotator_name, each = nrow(weightsItAlg1LDA1)),
      annotatorClass = rep(annotator_class, each = nrow(weightsItAlg1LDA1))
    )
    
    weights_data_italg2LDA <- data.frame(
      weights = c(as.matrix(weightsItAlg2LDA1)/rowSums(as.matrix(weightsItAlg2LDA1))),
      annotator = rep(annotator_name, each = nrow(weightsItAlg2LDA1)),
      annotatorClass = rep(annotator_class, each = nrow(weightsItAlg2LDA1))
    )
    
    boxPGT <- ggplot(weights_data_PGT, aes(x = annotator, y = weights, fill = annotatorClass)) +
      geom_boxplot(fill = c("#4393C3","#4393C3","#4393C3","#4393C3","#92C5DE","#92C5DE","#92C5DE"), color = "black") +
      ylim(0.08,0.2)+
      labs(x = "Annotator", y = "Weights", title = "PGT") +
      theme(axis.text.x = element_text(size = 16),  # Adjust the x-axis label size (change 12 to your desired size)
            axis.text.y = element_text(size = 16),  # Adjust the y-axis label size (change 12 to your desired size)
            axis.title.x = element_text(size = 20), # Adjust the x-axis title size (change 14 to your desired size)
            axis.title.y = element_text(size = 20),
            plot.title = element_text(size = 22))
    
    
    boxMV <- ggplot(weights_data_MV2, aes(x = annotator, y = weights, fill = annotatorClass)) +
      geom_boxplot(fill = c("#4393C3","#4393C3","#4393C3","#4393C3","#92C5DE","#92C5DE","#92C5DE"), color = "black") +
      ylim(0.08,0.2) +
      labs(x = "Annotator", y = "Weights", title = "MV") +
      theme(axis.text.x = element_text(size = 16),  # Adjust the x-axis label size (change 12 to your desired size)
            axis.text.y = element_text(size = 16),  # Adjust the y-axis label size (change 12 to your desired size)
            axis.title.x = element_text(size = 20), # Adjust the x-axis title size (change 14 to your desired size)
            axis.title.y = element_text(size = 20),
            plot.title = element_text(size = 22)) 
    
    boxItAlg1 <- ggplot(weights_data_italg1LDA, aes(x = annotator, y = weights, fill = annotatorClass)) +
      geom_boxplot(fill = c("#4393C3","#4393C3","#4393C3","#4393C3","#92C5DE","#92C5DE","#92C5DE"), color = "black") +
      ylim(0.08,0.2)+
      labs(x = "Annotator", y = "Weights", title = "ItAlg1") +
      theme(axis.text.x = element_text(size = 16),  # Adjust the x-axis label size (change 12 to your desired size)
            axis.text.y = element_text(size = 16),  # Adjust the y-axis label size (change 12 to your desired size)
            axis.title.x = element_text(size = 20), # Adjust the x-axis title size (change 14 to your desired size)
            axis.title.y = element_text(size = 20),
            plot.title = element_text(size = 22)) 
    
    boxItAlg2 <- ggplot(weights_data_italg2LDA, aes(x = annotator, y = weights, fill = annotatorClass)) +
      geom_boxplot(fill = c("#4393C3","#4393C3","#4393C3","#4393C3","#92C5DE","#92C5DE","#92C5DE"), color = "black") +
      ylim(0.08,0.2)+
      labs(x = "Annotator", y = "Weights", title = "ItAlg2") +
      theme(axis.text.x = element_text(size = 16),  
            axis.text.y = element_text(size = 16),  
            axis.title.x = element_text(size = 20), 
            axis.title.y = element_text(size = 20),
            plot.title = element_text(size = 22)) 
    
    grid_plot <- grid.arrange(
      boxPGT, boxMV, boxItAlg1, boxItAlg2,
      ncol = 2, nrow = 2
    )
    if (real_data == FALSE){
      boxplot_file <- file.path(path, "figure6_boxplot.png")
      ggsave(filename = boxplot_file, plot = grid_plot, width = 10, height = 10, dpi = 300)
      cat("Figure6 boxplot saved to:", boxplot_file, "\n")
    } else if (real_data == TRUE){
      boxplot_file <- file.path(path, "figure7_boxplot.png")
      ggsave(filename = boxplot_file, plot = grid_plot, width = 10, height = 10, dpi = 300)
      cat("Figure6 boxplot saved to:", boxplot_file, "\n")
    }
    
  }
}
