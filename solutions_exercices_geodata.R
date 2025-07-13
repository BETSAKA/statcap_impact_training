
# EXERCICES DONNEES GADM

# -   Visualisez les données `gadm_mada0` téléchargées avec tmap. De quel niveau administratif s'agit-il ?
# -   En utilisant les autres niveaux administratifs disponibles (1, 2, 3, 4), déduisez à quoi correspond
# chaque niveau dans la hiérarchie administrative de Madagascar.


#Charger les données GADM pour les 4 niveaux administratifs de Madagascar
mada1 <- gadm("Madagascar", level = 1, path = "data", resolution = 2) %>% 
  st_as_sf()
mada2 <- gadm("Madagascar", level = 2, path = "data", resolution = 2) %>% 
  st_as_sf()
mada3 <- gadm("Madagascar", level = 3, path = "data", resolution = 2) %>% 
  st_as_sf()
mada4 <- gadm("Madagascar", level = 4, path = "data", resolution = 2) %>% 
  st_as_sf()

#Visualiser les 4 niveaux avec tmap
tmap_mode("view")
tm_shape(mada1) + 
  tm_borders(lwd = 2) +
  tm_shape(mada2) + 
  tm_borders(lwd = 1.5) +
  tm_shape(mada3) + 
  tm_borders(lwd = 1) +
  tm_shape(mada4) + 
  tm_borders(lwd = 0.5)


# EXERCICES PRATIQUES RASTERS


#1.  **Exploration Manuelle** : Rendez-vous sur le site [Global Forest Change 2023]
# (https://storage.googleapis.com/earthenginepartners-hansen/GFC-2023-v1.11/download.html), 
# et téléchargez une tuile de votre choix. Essayez de comprendre la structure des fichiers téléchargés et leur signification.

#2.  **Chargement avec R** : Utilisez la fonction `rast()` du package `terra` pour charger la tuile 
#que vous avez téléchargée, puis affichez-la avec `plot()`. Quels types d'informations pouvez-vous en déduire ?

#3.  **Décrire les Différents Formats** : En fonction de ce que vous avez appris, décrivez les différents 
#formats de données raster que vous avez rencontrés, et discutez des avantages de chaque format en termes de stockage,
#de compatibilité, et d'utilisation dans R.


# Télécharger les données
url <- "https://storage.googleapis.com/earthenginepartners-hansen/GFC-2023-v1.11/Hansen_GFC-2023-v1.11_lossyear_10S_050E.tif"
download.file(url, "data/Hansen_GFC-2023-v1.11_lossyear_10S_050E.tif")

#Charger le raster
ma_tuile <- rast("data/Hansen_GFC-2023-v1.11_lossyear_10S_050E.tif")


#Sélectionner la partie du raster à visualiser et générer une première carte
ma_tuile %>% 
  crop(intersection) %>%
  mask(intersection) %>%
  plot()


# EXERCICES PRATIQUES AVEC SF

#1.  **Intersection** : Utilisez `st_intersection()` pour trouver les zones communes entre les réserves naturelles et une région administrative spécifique.
#2.  **Union** : Combinez toutes les aires protégées en une seule entité et calculez sa surface totale.
#3.  **Buffer** : Créez une zone tampon de 5 km autour des Aires protégées de type II seulement.
#4.  **Surface** : Calculez la surface totale des zones tampons créées et comparez-la avec la surface totale des aires protégées.



# 1. Intersection

## Sélectionner une région

ma_region <- mada2 %>% 
  filter(NAME_2 == "Analamanga") 

## Intersection avec les aires protégées

### approche 1
intersect_region_ap <- AP_Vahatra %>%
  filter(lengths(st_intersects(., ma_region)) > 0)

### approche 2
intersect_region_ap <- AP_Vahatra %>%
  st_filter(ma_region, .predicate = st_intersects)


## Si on souhaite filtrer les aires entièrement contenues dans la région

### approche 1
within_region_ap <- AP_Vahatra %>%
  filter(lengths(st_within(., ma_region)) > 0)

### approche 2
within_region_ap <- AP_Vahatra %>%
  st_filter(ma_region, .predicate = st_within)


## Visualisation
tm_shape(intersect_region_ap) +
  tm_fill("green") +
  tm_shape(ma_region) +
  tm_borders(col = "red", lwd = 2) 


# 2. Union

## Union des aires protégées de la région Analamanga

union_ap_region <- st_union(intersect_region_ap)

## Surface totale des aires protégées de la région Analamanga

intersect_region_ap %>%
  summarise(area = sum(surface_km2))

union_ap_region %>%
  st_area() %>% 
  set_units(km2)


# 3. Buffer

## Filter les AP de catégorie 2

AP_II <- AP_Vahatra %>% 
  filter(cat_iucn == "II")

## Créer un buffer de 5 km autour des AP de catégorie II

AP_II_buffer <- AP_II %>% 
  st_buffer(dist = 5000) 

## Visualiser les buffers et les AP de catégorie II

tm_shape(AP_II_buffer) +
  tm_polygons(fill = "orange", fill_alpha = 0.5,
              fill.legend = tm_legend(title = "Buffer de 5 km autour des Aires Protégées de type II")) +
  tm_shape(AP_II) +
  tm_fill("green")


# 4. Surface des buffers

## Surface zones tampons

AP_II_buffer %>%
  st_union() %>%
  st_area() %>% 
  set_units(km2)

## Surface des aires protégées de catégorie II

AP_II %>%
  summarise(area = sum(surface_km2))

