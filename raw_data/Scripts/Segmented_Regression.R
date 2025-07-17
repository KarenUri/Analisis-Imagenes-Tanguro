setwd("D:/Karen/Documents/GitHub/Analisis-Imagenes-Tanguro/process_data/Mean_intensity_profiles/March_22/Dac")

library(strucchange)

# Leer el perfil
perfil <- read.csv("Dac_edge_75241_mar22_03_1_TodosPerfiles_mean.csv")

# Opcional: reducir puntos si tarda mucho
perfil_reducido <- perfil[seq(1, nrow(perfil), by = 5), ]

# Ajustar modelo con 3 rupturas (solo intercepto)
modelo <- breakpoints(Intensity_mean ~ 1, data = perfil_reducido, breaks = 2)

# Ver puntos de ruptura (índices)
modelo$breakpoints

# Convertir a posición en micrómetros
breaks_pos <- perfil_reducido$Position_um[modelo$breakpoints]
print(breaks_pos)

# Graficar
plot(perfil$Position_um, perfil$Intensity_mean, type = "l",
     main = "Profile with breakpoints", xlab = "Position (µm)", ylab = "Intensity")
abline(v = breaks_pos, col = "blue", lty = 2, lwd = 2)

# Índices de los puntos de ruptura
indices_breaks <- c(1, modelo$breakpoints, nrow(perfil_reducido))

pendientes <- c()

for (i in 1:(length(indices_breaks) - 1)) {
  inicio <- indices_breaks[i]
  fin <- indices_breaks[i + 1]
  
  # Subconjunto del tramo
  tramo <- perfil_reducido[inicio:fin, ]
  
  # Ajustar modelo lineal: Intensidad ~ Posición
  modelo_tramo <- lm(Intensity_mean ~ Position_um, data = tramo)
  
  # Extraer pendiente
  pendientes[i] <- coef(modelo_tramo)[2]
}

# Mostrar
print(pendientes)

# Opcional: guardar con nombre del archivo o ID de muestra
pendientes_df <- data.frame(
  tramo = paste0("Tramo_", seq_along(pendientes)),
  pendiente = pendientes
)

#########
library(strucchange)

# Ruta base
setwd("D:/Karen/Documents/GitHub/Analisis-Imagenes-Tanguro/process_data/Mean_intensity_profiles/Aug_22/Dac")
ruta <- getwd()

# Crear carpetas de salida
dir.create("graficas", showWarnings = FALSE)
dir.create("pendientes_por_archivo", showWarnings = FALSE)

# Lista de archivos CSV
archivos <- list.files(path = ruta, pattern = "\\.csv$", full.names = TRUE)

# Inicializar tabla para pendientes de todos los archivos
pendientes_totales <- data.frame()

# Iterar sobre todos los archivos
for (archivo in archivos) {
  
  nombre_archivo <- tools::file_path_sans_ext(basename(archivo))
  
  # Leer perfil
  perfil <- read.csv(archivo)
  
  # Reducir resolución si es necesario
  perfil_reducido <- perfil[seq(1, nrow(perfil), by = 5), ]
  
  # Modelo con 2 rupturas (3 tramos)
  modelo <- breakpoints(Intensity_mean ~ 1, data = perfil_reducido, breaks = 2)
  indices_breaks <- c(1, modelo$breakpoints, nrow(perfil_reducido))
  breaks_pos <- perfil_reducido$Position_um[modelo$breakpoints]
  
  # Calcular pendientes por tramo
  pendientes <- c()
  inicio_um <- c()
  fin_um <- c()
  
  for (i in 1:(length(indices_breaks) - 1)) {
    inicio <- indices_breaks[i]
    fin <- indices_breaks[i + 1]
    
    tramo <- perfil_reducido[inicio:fin, ]
    modelo_tramo <- lm(Intensity_mean ~ Position_um, data = tramo)
    pendientes[i] <- coef(modelo_tramo)[2]
    inicio_um[i] <- tramo$Position_um[1]
    fin_um[i] <- tramo$Position_um[nrow(tramo)]
  }
  
  # Guardar gráfico
  png(paste0("graficas/", nombre_archivo, ".png"), width = 800, height = 600)
  plot(perfil$Position_um, perfil$Intensity_mean, type = "l",
       main = nombre_archivo, xlab = "Position (µm)", ylab = "Intensity")
  abline(v = breaks_pos, col = "blue", lty = 2, lwd = 2)
  dev.off()
  
  # Guardar pendientes del archivo
  pendientes_df <- data.frame(
    archivo = nombre_archivo,
    tramo = paste0("Tramo_", seq_along(pendientes)),
    inicio_um = inicio_um,
    fin_um = fin_um,
    pendiente = pendientes
  )
  
  write.csv(pendientes_df, paste0("pendientes_por_archivo/", nombre_archivo, "_pendientes.csv"), row.names = FALSE)
  
  # Agregar a tabla general
  pendientes_totales <- rbind(pendientes_totales, pendientes_df)
}

# Guardar archivo resumen general
write.csv(pendientes_totales, "pendientes_totales.csv", row.names = FALSE)

############ Script para Breakpoints apartir de cambios en la pendiente ####################
library(segmented)

setwd("D:/Karen/Documents/GitHub/Analisis-Imagenes-Tanguro/process_data/Mean_intensity_profiles/Aug_22/Sac")

# Leer el perfil
perfil <- read.csv("Dmic_edge_75252_aug2022_03_1_TodosPerfiles_mean.csv")

# Opcional: reducir puntos si tarda mucho
perfil_reducido <- perfil[seq(1, nrow(perfil), by = 5), ]

# Paso 1: modelo lineal base
modelo_lm <- lm(Intensity_mean ~ Position_um, data = perfil_reducido)

# Paso 2: regresión segmentada (con psi inicial ~500 µm, puedes ajustar)
modelo_seg <- segmented(modelo_lm, seg.Z = ~Position_um, psi = c(400, 900))

# Ver resultados
summary(modelo_seg)

# Graficar con segmentos
plot(perfil_reducido$Position_um, perfil_reducido$Intensity_mean, type = "l", main = "Segmented Regression")
plot(modelo_seg, add = TRUE, col = "red", lwd = 2)
abline(v = modelo_seg$psi[, "Est."], col = "blue", lty = 2)

###### Script para Breakpoints apartir de cambios en la pendiente - Para todos los csv en una carpeta #########
library(segmented)
library(ggplot2)
library(cowplot)

# Ruta base
setwd("D:/Karen/Documents/GitHub/Analisis-Imagenes-Tanguro/process_data/Mean_intensity_profiles/March_22/Dac")

# Crear carpetas de salida
dir.create("graficas_segmented", showWarnings = FALSE)
dir.create("pendientes_segmented", showWarnings = FALSE)

# Lista de archivos CSV
archivos <- list.files(pattern = "\\.csv$", full.names = TRUE)

# DataFrame para consolidar resultados
pendientes_totales <- data.frame()

for (archivo in archivos) {
  
  nombre_archivo <- tools::file_path_sans_ext(basename(archivo))
  
  # Leer perfil
  perfil <- read.csv(archivo)
  perfil_reducido <- perfil[seq(1, nrow(perfil), by = 5), ]
  
  # Ajustar modelo base
  modelo_lm <- lm(Intensity_mean ~ Position_um, data = perfil_reducido)
  
  # Modelo segmentado con 2 psi iniciales (ajustables)
  modelo_seg <- tryCatch({
    segmented(modelo_lm, seg.Z = ~Position_um, psi = c(400, 900))
  }, error = function(e) {
    message(paste("❌ Error en", nombre_archivo, "-", e$message))
    return(NULL)
  })
  
  if (is.null(modelo_seg)) next
  
  # Obtener breakpoints estimados
  breakpoints_um <- modelo_seg$psi[, "Est."]
  puntos <- c(min(perfil_reducido$Position_um), breakpoints_um, max(perfil_reducido$Position_um))
  
  # Extraer pendientes por tramo
  slopes <- slope(modelo_seg)$Position_um[, "Est."]
  
  # Preparar tabla con pendientes por tramo
  pendientes_df <- data.frame(
    archivo = nombre_archivo,
    tramo = paste0("Tramo_", seq_along(slopes)),
    inicio_um = puntos[1:(length(puntos)-1)],
    fin_um = puntos[2:length(puntos)],
    pendiente = slopes
  )
  
  # Guardar CSV individual
  write.csv(pendientes_df, file = paste0("pendientes_segmented/", nombre_archivo, "_pendientes_segmented.csv"), row.names = FALSE)
  
  # Agregar al total
  pendientes_totales <- rbind(pendientes_totales, pendientes_df)
  
  # ---- GRAFICAR
  png(paste0("graficas_segmented/", nombre_archivo, "_segmented.png"), width = 800, height = 600)
  plot(perfil_reducido$Position_um, perfil_reducido$Intensity_mean, type = "l",
       main = paste("Segmented –", nombre_archivo), xlab = "Position (µm)", ylab = "Intensity")
  plot(modelo_seg, add = TRUE, col = "red", lwd = 2)
  abline(v = breakpoints_um, col = "blue", lty = 2, lwd = 2)
  dev.off()
}

# Guardar archivo consolidado
write.csv(pendientes_totales, "pendientes_segmented_totales.csv", row.names = FALSE)


