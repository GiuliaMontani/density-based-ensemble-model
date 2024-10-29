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
config <- jsonlite::fromJSON(args[1])

cd <- getwd()
nameFolder <- "results"
path_results = file.path(cd, nameFolder)
if (!dir.exists(path_results)) {
  dir.create(path_results, recursive = TRUE)
}
print(config)
set.seed(config$set_seed)
p <- config$p
mu <- config$mu
Nobs <- config$Nobs

# Check simulation type
if (config$simulation_type == 1) {
  cat("----- Start simulation type 1 -----\n")
  
  # Simulation Scenario 1
  x1 <- mvrnorm(n = 50, mu = mu[1,], Sigma = diag(p))
  x2 <- mvrnorm(n = 50, mu = mu[2,], Sigma = diag(p))
  x3 <- mvrnorm(n = 50, mu = mu[3,], Sigma = diag(p))
  X <- rbind(x1, x2, x3)
  colors <- c(rep('green', 50), rep('red', 50), rep('blue', 50))
  
  # Plot for Scenario 1
  imgPath = file.path(path_results, "figure2a.png")
  png(file = imgPath)
  plot(X, col = colors, pch = 16, xlab = "Feature 1", ylab = "Feature 2", main = "Scenario 1")
  legend("topright", legend = c("Group 1", "Group 2", "Group 3"), fill = c("green", "red", "blue"))
  dev.off()
  cat("Figure2a saved to:", imgPath, "\n")
  
  # Run the simulation, the "result_simulation1.rds" are saved
  cat("----- Run models -----\n")
  result <- simulation(S = 50, mu = mu, N= Nobs)
  cat("----- End -----\n")
  
  cat("----- Save results -----\n")
  # Save the result to an RDS file
  resultPath = file.path(path_results, "result_simulation1.rds")
  saveRDS(result, file = resultPath)
  cat("----- End simulation type 1 -----\n")
  
} else if (config$simulation_type == 2) {
  cat("----- Start simulation type 2 -----\n")
  # Simulation Scenario 2
  Sigma1 <- genPositiveDefMat(p)$Sigma / config$Sigma1_divisor
  Sigma2 <- genPositiveDefMat(p)$Sigma / config$Sigma2_divisor
  Sigma3 <- genPositiveDefMat(p)$Sigma / config$Sigma3_divisor
  
  x1 <- mvrnorm(n = 50, mu = mu[1,], Sigma = Sigma1)
  x2 <- mvrnorm(n = 50, mu = mu[2,], Sigma = Sigma2)
  x3 <- mvrnorm(n = 50, mu = mu[3,], Sigma = Sigma3)
  X <- rbind(x1, x2, x3)
  colors <- c(rep('green', 50), rep('red', 50), rep('blue', 50))
  
  # Plot for Scenario 2
  imgPath = file.path(path_results, "figure2b.png")
  png(file = imgPath)
  plot(X, col = colors, pch = 16, xlab = "Feature 1", ylab = "Feature 2", main = "Scenario 2")
  legend("topright", legend = c("Group 1", "Group 2", "Group 3"), fill = c("green", "red", "blue"))
  dev.off()
  cat("Figure2b saved to:", imgPath, "\n")
  
  # Run the simulation, the "result_simulation2.rds" are saved
  result <- simulation(S = 50, mu = mu, sigma = rbind(Sigma1, Sigma2, Sigma3), N= Nobs)
  
  # Save the result to an RDS file
  resultPath = file.path(path_results, "result_simulation2.rds")
  saveRDS(result, file = resultPath)
  cat("----- End simulation type 1 -----\n")
  
}

# Save png to produce figure4, figure 5 and figure 6 in the paper
# Save all csv files to produce table 4 in the paper
cat("----- Save results for paper -----\n")
save_result_for_paper(result, path_results, config$simulation_type)
cat("----- End of simulation -----\n")
cat("----- Thanks -----\n")


