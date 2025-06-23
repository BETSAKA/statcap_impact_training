library(tidyverse)
library(tmap)
library(sf)
library(mapme.biodiversity)
library(geodata)
library(terra)
library(future)
library(tictoc)
library(progressr)

contour_mada <- gadm(country = "Madagascar", resolution = 1, level = 0,
                     path = "data") %>%
  st_as_sf() %>%
  st_transform("EPSG:29739") # On utilise la projecton officielle pour Mada

# Création d'un maillage du territoire émergé --------------------------------

# On crée un cadre autour des frontières nationales
cadre_autour_mada = st_as_sf(st_as_sfc(st_bbox(contour_mada))) %>%
  st_make_valid()

# Surface des hexagones en km2
taille_hex <- 5

# Cellules de 5km de rayon
surface_cellule <- taille_hex * (1e+6)
taille_cellule <- 2 * sqrt(surface_cellule / ((3 * sqrt(3) / 2))) * sqrt(3) / 2
grille_mada <- st_make_grid(x = cadre_autour_mada,
                            cellsize = taille_cellule,
                            square = FALSE) 
# On découpe la grille pour ne garder que les terres émergées
cellules_emergees <- contour_mada %>%
  st_intersects(grille_mada) %>%
  unlist()
grille_mada <- grille_mada[sort(cellules_emergees)] %>%
  st_sf()


my_s3 <- "/vsis3/fbedecarrats/diffusion/test"
my_local <- "test"


# En local ----------------------------------------------------------------

mapme_options(outdir = my_local)

plan(cluster, workers = 8)

tic()
# Acquisition des données satellitaires requises (rasters)
with_progress({
  grille_mada_local <-  get_resources(x = grille_mada, 
                                      get_nelson_et_al(ranges = "5k_110mio"),
                                      get_gfw_treecover(),
                                      get_gfw_lossyear(),
                                      get_nasa_srtm(),
                                      get_worldpop())
  toc()
})
# Calcul des indicateurs
tic()
with_progress({
  grille_mada_local <- calc_indicators(x = grille_mada_local,
                                       calc_traveltime(),
                                       calc_population_count(),
                                       calc_slope(),
                                       calc_elevation(),
                                       calc_treecover_area())
})
toc()
plan(sequential)

# With S3 storage ---------------------------------------------------------

mapme_options(outdir = my_s3)

plan(cluster, workers = 8)

tic()
with_progress({
  # Acquisition des données satellitaires requises (rasters)
  grille_mada_s3 <-  get_resources(x = grille_mada, 
                                   get_nelson_et_al(ranges = "5k_110mio"),
                                   get_gfw_treecover(),
                                   get_gfw_lossyear(),
                                   get_nasa_srtm(),
                                   get_worldpop())
  toc()
})
# Calcul des indicateurs
tic()
with_progress({
  grille_mada_s3 <- calc_indicators(x = grille_mada_s3,
                                    calc_traveltime(),
                                    calc_population_count(),
                                    calc_slope(),
                                    calc_elevation(),
                                    calc_treecover_area())
  toc()
})
plan(sequential)


