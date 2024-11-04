# Import packages
options(warn = -1)
source("model/simulation.R")
source("model/ensemble_model.R")
source("model/select_observation.R")
source("model/score.R")
source("model/model_comparison.R")
source("model/weights_generation.R")
source("model/prediction_ensemble_model.R")
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

library(ggplot2)
library(reshape2)
library(patchwork)

library(MASS)
library(clusterGeneration)
library(yaml)

cat("----- Set config -----\n")
# Simulation

args <- commandArgs(trailingOnly = TRUE)

cd <- getwd()
nameFolder <- "results"
path_results = file.path(cd, nameFolder)
if (!dir.exists(path_results)) {
  dir.create(path_results, recursive = TRUE)
}

# Check simulation type
if (args[1] == 1) {
  cat("----- Start simulation type 1 -----\n")
  simulation_type <- 1
  real_data = FALSE
  
  # Simulation Scenario 1
  x1 <- rmvnorm(n=50, mean=c(2,2))
  x2 <- rmvnorm(n=50, mean=c(-2,-2))
  x3 <- rmvnorm(n=50, mean=c(0,0))
  X <- rbind(x1, x2, x3)
  colors <- c(rep('green', 50), rep('red', 50), rep('blue', 50))
  
  # Plot for Scenario 1
  imgPath = file.path(path_results, "figure2a.png")
  png(file = imgPath)
  plot(X, col = colors, pch = 16, xlab = "Feature 1", ylab = "Feature 2", main = "Scenario 1")
  legend("topright", legend = c("Group 1", "Group 2", "Group 3"), fill = c("green", "red", "blue"))
  dev.off()
  cat("Figure2a saved to:", imgPath, "\n")
  
  p = 2
  mu <- rbind(rep(2,p),rep(-2,p),rep(0,p))
  Nobs = c(50)
  
  set.seed(43)
  
  # Run the simulation, the "result_simulation1.rds" are saved
  cat("----- Run models -----\n")
  result <- simulation(S = 50, mu = mu, N= Nobs)
  cat("----- End -----\n")
  
  cat("----- Save results -----\n")
  # Save the result to an RDS file
  resultPath = file.path(path_results, "result_simulation1.rds")
  saveRDS(result, file = resultPath)
  cat("----- End simulation type 1 -----\n")
  
} else if (args[1] == 2) {
  cat("----- Start simulation type 2 -----\n")
  simulation_type <- 2
  real_data = TRUE
  
  set.seed(11)
  # Simulation Scenario 2
  Sigma1 <- genPositiveDefMat(2)
  Sigma2 <- genPositiveDefMat(2)
  Sigma3 <- genPositiveDefMat(2) #798 386
  x1 <- rmvnorm(n=50, mean=c(2,2),sigma=Sigma1$Sigma/4)
  x2 <- rmvnorm(n=50, mean=c(-2,-2),sigma=Sigma2$Sigma/4)
  x3 <- rmvnorm(n=50, mean=c(0,0),sigma=Sigma3$Sigma/4)
  X <- rbind(x1, x2, x3)
  colors <- c(rep('green', 50), rep('red', 50), rep('blue', 50))
  
  # Plot for Scenario 2
  imgPath = file.path(path_results, "figure2b.png")
  png(file = imgPath)
  plot(X, col = colors, pch = 16, xlab = "Feature 1", ylab = "Feature 2", main = "Scenario 2")
  legend("topright", legend = c("Group 1", "Group 2", "Group 3"), fill = c("green", "red", "blue"))
  dev.off()
  cat("Figure2b saved to:", imgPath, "\n")
  
  p = 2
  mu <- rbind(rep(2,p),rep(-2,p),rep(0,p))
  Nobs = c(50)
  set.seed(43)
  
  # Run the simulation, the "result_simulation2.rds" are saved
  cat("----- Run models -----\n")
  result <- simulation(S = 50, mu = mu, sigma = rbind(Sigma1$Sigma/4,Sigma2$Sigma/4,Sigma3$Sigma/4), N= Nobs)
  cat("----- End -----\n")
  
  cat("----- Save results -----\n")
  # Save the result to an RDS file
  resultPath = file.path(path_results, "result_simulation2.rds")
  saveRDS(result, file = resultPath)
  cat("----- End simulation type 2 -----\n")
  
}

# Save png to produce figure4, figure 5 and figure 6 in the paper
# Save all csv files to produce table 4 in the paper
cat("----- Save results for paper -----\n")
save_result_for_paper(result, path_results, simulation_type, real_data = real_data)
cat("----- End of simulation -----\n")
cat("----- Thanks -----\n")


