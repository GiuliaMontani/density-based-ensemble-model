library(tidyverse)


# Simulation 1 ------------------------------------------------------------

# accuracy_simulation_1_raw <- read_csv("model_competitors/Simulation1_results/accuracy_Simulation1.csv")
# 
# 
# accuracy_simulation_1 <- accuracy_simulation_1_raw |> 
#   select(Accuracy_dawidskene) |> 
#   separate(col = Accuracy_dawidskene,sep = "\\),\\(\\:",into = colnames(accuracy_simulation_1_raw)[-1]) |> 
#   mutate(Accuracy_rodrigues=str_remove(Accuracy_rodrigues,"Accuracy_rodrigues,"),Accuracy_dawidskene=str_remove(Accuracy_dawidskene,"Accuracy_dawidskene,")) |> 
#   mutate(across(everything(),parse_number))
# 
# 
# accuracy_simulation_1 |> 
#   summarise(across(everything(),.fns=mean))
# 
# accuracy_simulation_1 |> 
#   summarise(across(everything(),.fns=sd))
# 
# accuracy_simulation_1 |> 
#   summarise(across(everything(),.fns=list(mean = mean, sd = sd)))
# 
# 
# # Simulation 2 ------------------------------------------------------------
# 
# accuracy_simulation_2_raw <- read_csv("model_competitors/Simulation2_results/accuracy_Simulation2.csv")
# 
# 
# accuracy_simulation_2 <- accuracy_simulation_2_raw |> 
#   select(Accuracy_dawidskene) |> 
#   separate(col = Accuracy_dawidskene,sep = "\\),\\(\\:",into = colnames(accuracy_simulation_2_raw)[-1]) |> 
#   mutate(Accuracy_rodrigues=str_remove(Accuracy_rodrigues,"Accuracy_rodrigues,"),Accuracy_dawidskene=str_remove(Accuracy_dawidskene,"Accuracy_dawidskene,")) |> 
#   mutate(across(everything(),parse_number))
# 
# 
# accuracy_simulation_2 |> 
#   summarise(across(everything(),.fns=mean))
# 
# accuracy_simulation_2 |> 
#   summarise(across(everything(),.fns=sd))
# 
# 
# accuracy_simulation_2 |> 
#   summarise(across(everything(),.fns=list(mean = mean, sd = sd)))


# Real data ------------------------------------------------------------

accuracy_REALDATA_raw <- read_csv("results/pred_real_data_julia.csv")

accuracy_REALDATA <- accuracy_REALDATA_raw |> 
  select(Accuracy_dawidskene) |> 
  separate(col = Accuracy_dawidskene,sep = "\\),\\(\\:",into = colnames(accuracy_REALDATA_raw)[-1]) |> 
  mutate(Accuracy_rodrigues=str_remove(Accuracy_rodrigues,"Accuracy_rodrigues,"),Accuracy_dawidskene=str_remove(Accuracy_dawidskene,"Accuracy_dawidskene,")) |> 
  mutate(across(everything(),parse_number)) |> 
  relocate(Accuracy_dawidskene)
  

table6_julia_competitors <- accuracy_REALDATA |> 
  summarise(across(everything(),.fns=list(mean = mean, sd = sd)))

write_csv(x = table6_julia_competitors, file = "results/table6_julia_competitors.csv")
