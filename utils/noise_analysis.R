noise_analysis <- function(path,
                           noisy_label){
  misclassification <- noisy_label %>%
    group_by(truth) %>%
    summarize(across(starts_with("E") | starts_with("N"), ~ mean(. != truth) * 100))
  
  misclassification_total <- noisy_label %>%
    summarize(across(starts_with("E") | starts_with("N"), ~ mean(. != truth) * 100))%>%
    mutate(truth = "total", .before = 1)
  
  # Calculate agreement percentages
  agreement_counts <- misclassification %>%
    mutate(across(starts_with("E") | starts_with("N"), ~ 100 - .))
  
  # Add a "Total" row
  total_agreement <- misclassification_total %>%
    mutate(across(starts_with("E") | starts_with("N"), ~ 100 - .))
  
  
  # Combine the "Total" row with the agreement_counts data
  agreement_counts_with_total <- bind_rows(agreement_counts, total_agreement)
  
  # Melt the data for plotting
  melted_agreement <- melt(agreement_counts_with_total, id.vars = "truth", variable.name = "Annotator")
  melted_agreement_single <- melt(agreement_counts, id.vars= "truth", variable.name = "Annotator")
  melted_agreement_total <- melt(total_agreement, id.vars = "truth", variable.name = "Annotator")
  # Create the heatmap
  
  custom_blue_palette <- c("#EFF3FF", "#BDD7E7", "#6BAED6", "#3182BD", "#08519C")
  custom_yellow_blue_palette <- c("#FFFFD9", "#EDF8B1", "#C7E9B4", "#7FCDBB", "#41B6C4", "#1D91C0", "#225EA8", "#253494", "#081D58")
  custom_pubu_palette <- c("#F1EEF6", "#D0D1E6", "#A6BDDB", "#74A9CF", "#3690C0", "#0570B0", "#045A8D", "#023858")
  
  selected_palette <- custom_pubu_palette
  plot_single <- ggplot(data = melted_agreement_single, aes(x = Annotator, y = truth)) +
    geom_tile(aes(fill = value, height = 1,width = 1), color = "white") +
    scale_fill_gradient(low = selected_palette[1], high =selected_palette[length(selected_palette)-1], limits = c(20, 100))+
    labs(x = "", y = "", title = "Annotators Agreement with Truth Labels") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    #theme(axis.text.x = element_blank()) +  
    scale_y_discrete(position = "left")
  
  plot_total <- ggplot(data = melted_agreement_total, aes(x = Annotator, y = truth)) +
    geom_tile(aes(fill = value, height = 1,width = 1), color = "white") +
    geom_text(aes(label = round(value, 1)), vjust = 1) +
    scale_fill_gradient(low = selected_palette[1], high = selected_palette[length(selected_palette)-1], limits = c(45, 70)) +
    labs(x = "Annotator", y = "", title = "") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_y_discrete(position = "left") +
    guides(fill = FALSE)
  
  # Combine the two plots using grid.arrange
  grid_plot <- grid.arrange(
    plot_single, plot_total,
    ncol = 1, nrow = 2,
    heights = c(2, 1)#, widths = c(1, 0.8)
  )
  heatmap_file <- file.path(path, "figure8_heatmap_noise.png")
  ggsave(filename = heatmap_file, plot = grid_plot, width = 10, height = 10, dpi = 300)
  cat("Figure8 heatmap noise saved to:", heatmap_file, "\n")
}