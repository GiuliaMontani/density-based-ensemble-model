# Import packages
options(warn = -1)
source("model/prediction_ensemble_model.R")
source("model/ensemble_model.R")
source("model/select_observation.R")
source("model/score.R")
source("model/model_comparison.R")
source("model/weights_generation.R")
source("model/simulation.R")
source("utils/noise_analysis.R")
source("utils/save_result_for_paper.R")


cat("----- Load packages -----\n")
library(mclust)
library(caret)
library(rsample)
library(mvtnorm)
library(LaplacesDemon)

library(gtools)
library(DirichletReg)

library(grid)
library(gridExtra)

library(dplyr)

library(ggplot2)
library(GGally)
library(reshape2)  
library(readxl)
library(gridExtra)
library(patchwork)

cd <- getwd()
nameFolder <- "results"
path_results = file.path(cd, nameFolder)
if (!dir.exists(path_results)) {
  dir.create(path_results, recursive = TRUE)
}

cat("----- Import data -----\n")
data <- read.csv("data/data.txt")

ground_truth <- as.data.frame(read_excel("data/ground_truth.xlsx"))
colnames(ground_truth) <- ground_truth[2,]
ground_truth <- ground_truth[3:78,1:9]
ground_truth <- ground_truth[order(ground_truth$LESION),]

set <- c(114, 174, 476, 490, 604)
df <- t(data[set,seq(1,152,2)])

df <- df[order(rownames(df)),]

Y <- data.frame("Expert1" = ground_truth$`EXPERT 1`,
                "Expert2" = ground_truth$`EXPERT 2`,
                "Expert3" = ground_truth$`EXPERT 3`,
                "Expert4" = ground_truth$`EXPERT 4`,
                "Beginner1" = ground_truth$`BEGINNER 1`,
                "Beginner2" = ground_truth$`BEGINNER 2`,
                "Beginner3" = ground_truth$`BEGINNER 3`)

df_label <- data.frame(df,
                       "truth" = ground_truth$`GROUND TRUTH`,
                       Y)

N= 50

pair_data <- df_label[,1:6]
colnames(pair_data) <- c("V113", "V173", "V475", "V489","V603", "truth")
pair_plot <- ggpairs(data = pair_data, columns = 1:5, aes(color = truth, alpha = 0.5), 
                     upper = list(continuous = wrap('cor', size = 2)))+
  scale_fill_manual(values=c('red','green','blue')) +
  scale_colour_manual(values=c('red','green','blue'))
pair_plot_file <- file.path(path_results, "figure2b_appendix.png")
ggsave(filename = pair_plot_file, plot = pair_plot, width = 10, height = 8, dpi = 300)
cat("Figure2B pair plot of data saved to:", pair_plot_file, "\n")

cat("----- Evaluate noise in the labels -----\n")

noisy_label <- df_label[, 6:13]
colnames(noisy_label) <- c("truth", "E1","E2","E3","E4","N1","N2","N3")
noise_analysis(path_results, noisy_label)

cat("----- Run models -----\n")
set.seed(901)
output <- data.frame(row.names = 1:N)
acc_LDA <- NULL
acc_QDA <- NULL
acc_EDDA <- NULL

meanEr_LDA <- NULL
meanEr_QDA <- NULL
meanEr_EDDA <- NULL

sigmaEr_LDA <- NULL
sigmaEr_QDA <- NULL
sigmaEr_EDDA <- NULL


for (k in 1:N) {
  df_split <- initial_split(df_label, prop = 2 / 3, strata = truth)
  train_data <- training(df_split)
  test_data <- testing(df_split)
  
  
  X.train <- train_data[, c(1, 2, 3, 4, 5)]
  X.test <- test_data[, c(1, 2, 3, 4, 5)]
  Y.test <- test_data$truth
  Y.train <- train_data[, c(7, 8, 9, 10, 11, 12, 13)]
  truth.train <- train_data$truth
  
  # weights generation
  weights <- weights_generation(
    xtrain = X.train,
    ytrain_noise = Y.train,
    ytrain = truth.train,
    ytest = Y.test,
    Nannotators = 7,
    N_exp = 4,
    N_beg = 3,
    positionExpert = c(1, 1, 1, 1, 0, 0, 0),
    positionBeginner = c(0, 0, 0, 0, 1, 1, 1)
  )
  
  out <-
    model_comparison(X.train, X.test, Y.train, truth.train, Y.test, model_weights = weights)
  
  if (k == 1) {
    acc_LDA <- matrix(NA, N, length(out$ModelNames))
    acc_QDA <- matrix(NA, N, length(out$ModelNames))
    acc_EDDA <- matrix(NA, N, length(out$ModelNames))
    
    meanEr_LDA <- matrix(NA, N, length(out$ModelNames))
    meanEr_QDA <- matrix(NA, N, length(out$ModelNames))
    meanEr_EDDA <- matrix(NA, N, length(out$ModelNames))
    
    sigmaEr_LDA <- matrix(NA, N, length(out$ModelNames))
    sigmaEr_QDA <- matrix(NA, N, length(out$ModelNames))
    sigmaEr_EDDA <- matrix(NA, N, length(out$ModelNames))
    
    colnames(acc_LDA) <- out$ModelNames
    colnames(acc_QDA) <- out$ModelNames
    colnames(acc_EDDA) <- out$ModelNames
    
    colnames(meanEr_LDA) <- out$ModelNames
    colnames(meanEr_QDA) <- out$ModelNames
    colnames(meanEr_EDDA) <- out$ModelNames
    
    colnames(sigmaEr_LDA) <- out$ModelNames
    colnames(sigmaEr_QDA) <- out$ModelNames
    colnames(sigmaEr_EDDA) <- out$ModelNames
    
    w <-
      setNames(lapply(
        replicate(
          length(out$ModelNames),
          matrix(NaN, nrow = 50, ncol = 7),
          simplify = FALSE
        ),
        as.data.frame
      ), out$ModelNames)
  }
  
  for (name in out$ModelNames) {
    acc_LDA[k, name] <- out[[name]]$LDA$accuracy
    acc_QDA[k, name] <- out[[name]]$QDA$accuracy
    acc_EDDA[k, name] <- out[[name]]$LDA$accuracy
    
    meanEr_LDA[k, name] <- out[[name]]$LDA$meanError
    meanEr_QDA[k, name] <- out[[name]]$QDA$meanError
    meanEr_EDDA[k, name] <- out[[name]]$EDDA$meanError
    
    sigmaEr_LDA[k, name] <- out[[name]]$LDA$sigmaError
    sigmaEr_QDA[k, name] <- out[[name]]$QDA$sigmaError
    sigmaEr_EDDA[k, name] <- out[[name]]$EDDA$sigmaError
    
    w[[name]][k, ] <- weights[[name]]
    
  }
  
}
cat("----- End -----\n")

cat("----- Save results -----\n")
output <- list(
  Accuracy = list(
    AccuracyLDA = acc_LDA,
    AccuracyQDA = acc_QDA,
    AccuracyEDDA = acc_EDDA
  ),
  MeanError = list(
    MeanErrorLDA = meanEr_LDA,
    MeanErrorQDA = meanEr_QDA,
    MeanErrorEDDA = meanEr_EDDA
  ),
  SigmaError = list(
    SigmaErrorLDA = sigmaEr_LDA,
    SigmaErrorQDA = sigmaEr_QDA,
    SigmaErrorEDDA = sigmaEr_EDDA
  ),
  weights = w,
  NumberAnnotators = 7,
  ModelName = out$ModelNames
)
resultPath = file.path(path_results, "result_real_data.rds")
saveRDS(output, file = resultPath)

cat("----- Save results for paper -----\n")
save_result_for_paper(output,
                      path_results,
                      real_data = TRUE)



cat("----- Run LDA model for EN -----\n")

set.seed(901)
output <- data.frame(row.names = 1:N)
acc_LDA <- matrix(NA, N, 1)

sensitivity_LDA <- matrix(NA, N, 1)

NPV_LDA <- matrix(NA, N, 1)

specificity_LDA <- matrix(NA, N, 1)

precision_LDA <- matrix(NA, N, 1)

name = "ExpertBeginner2"

colnames(acc_LDA) <- name

colnames(sensitivity_LDA) <- name

colnames(NPV_LDA) <- name

colnames(specificity_LDA) <- name

colnames(precision_LDA) <- name

for (k in 1:N) {
  df_split <- initial_split(df_label, prop = 2 / 3, strata = truth)
  train_data <- training(df_split)
  test_data <- testing(df_split)
  
  
  X.train <- train_data[, c(1, 2, 3, 4, 5)]
  X.test <- test_data[, c(1, 2, 3, 4, 5)]
  Y.test <- test_data$truth
  Y.train <- train_data[, c(7, 8, 9, 10, 11, 12, 13)]
  truth.train <- train_data$truth
  
  # weights generation
  weights <- weights_generation(
    modelName = c("ExpertBeginner2"),
    xtrain = X.train,
    ytrain_noise = Y.train,
    ytrain = truth.train,
    ytest = Y.test,
    Nannotators = 7,
    N_exp = 5,
    N_beg = 2,
    positionExpert = c(1, 1, 1, 1, 0, 1, 0),
    positionBeginner = c(0, 0, 0, 0, 1, 0, 1)
  )
  
  ensemble_model_LDA <- ensemble_model(X.train,Y.train, modelName = "LDA", w = weights$ExpertBeginner2)
  prediction_ensemble_model_LDA <- prediction_ensemble_model(X.test, ensemble_model_LDA, Ytest = Y.test)
  cm <- confusionMatrix(data = as.factor(prediction_ensemble_model_LDA$classification), reference = as.factor(Y.test))
  
  binary_predictions <- prediction_ensemble_model_LDA$classification
  binary_predictions[binary_predictions == "serrated"] <- "adenoma"
  binary_predictions <- factor(binary_predictions, levels = c("adenoma", "hyperplasic"))
  Ytest_binary <- Y.test
  Ytest_binary[Ytest_binary == "serrated"] <- "adenoma"
  Ytest_binary <- factor(Ytest_binary, levels = c("adenoma", "hyperplasic"))
  cm_binary <- confusionMatrix(data = as.factor(binary_predictions), reference = as.factor(Ytest_binary))
  
    
  acc_LDA[k, name] <- as.numeric(cm$overall["Accuracy"])
  
  sensitivity_LDA[k, name] <- as.numeric(cm_binary$byClass["Sensitivity"])
    
  NPV_LDA[k, name] <- as.numeric(cm_binary$byClass["Neg Pred Value"])
    
  specificity_LDA[k, name] <- as.numeric(cm_binary$byClass["Specificity"])
    
  precision_LDA[k, name] <- as.numeric(cm_binary$byClass["Precision"])
}

output <- list(
  AccuracyLDA = acc_LDA,
  sensitivityLDA = sensitivity_LDA,
  NPVLDA = NPV_LDA,
  specificityLDA = specificity_LDA,
  precisionLDA = precision_LDA,
  NumberAnnotators = 7,
  ModelName = name
)

cat("----- End -----\n")

cat("----- Save results -----\n")
resultPath = file.path(path_results, "result_real_data_EN.rds")
saveRDS(output, file = resultPath)

cat("----- Save results for paper -----\n")
path_csv <- file.path(path_results, "table7.csv")
  
models_name <- "EN"

accuracy <- output$AccuracyLDA
colnames(accuracy) <- models_name

sensitivity <- output$sensitivityLDA
colnames(sensitivity) <- models_name

NPV <- output$NPVLDA
colnames(NPV) <- models_name

specificity <- output$specificityLDA
colnames(specificity) <- models_name

precision <- output$precisionLDA
colnames(precision) <- models_name

result_df  <- data.frame(ACC = colMeans(accuracy),
                         sensitivity = colMeans(sensitivity),
                         sd_sen = apply(sensitivity, 2, sd),
                         NPV = colMeans(NPV),
                         sd_NPV = apply(NPV, 2, sd),
                         specificity = colMeans(specificity),
                         sd_spec = apply(specificity, 2, sd),
                         precision = colMeans(precision),
                         sd_prec = apply(precision, 2, sd))
write.csv(result_df, file = path_csv, row.names = FALSE)
cat("Numeric results saved to:", path_csv, "\n") 
