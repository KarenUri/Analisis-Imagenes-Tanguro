# Grafica promedio para todas las imagenes que hay en una carpeta.
library(dplyr)
library(ggplot2)
library(tools)

#Directorio
data_dir <- setwd("D:/Karen/Documents/GitHub/Analisis-Imagenes-Tanguro/raw_data/plot_profiles/March_22/Sac")

for (csv_path in list.files(pattern = "\\.csv$", full.names = TRUE)) {
  
  df <- read.csv(csv_path)
  
  df_mean <- df %>% 
    group_by(Position_um) %>% 
    summarise(Intensity_mean = mean(Intensity, na.rm = TRUE), .groups = "drop")
  
  mean_csv_path <- file.path(
    data_dir,
    paste0(file_path_sans_ext(basename(csv_path)), "_mean.csv")
  )
  write.csv(df_mean, mean_csv_path)
  
  p <- ggplot(df_mean, aes(x = Position_um, y = Intensity_mean)) +
    geom_line(color = "steelblue", linewidth = 1) +
    theme_minimal(base_size = 14) +
    labs(title = paste("Mean Intensity –", basename(csv_path)),
         x = "Position (µm)", y = "Mean Intensity")
  
  ggsave(
    filename = file.path(
      data_dir,
      paste0(file_path_sans_ext(basename(csv_path)), "_mean.png")
    ),
    plot = p, width = 7, height = 4, dpi = 300
  )
}
