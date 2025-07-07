AP_Vahatra <- st_read("data/AP_Vahatra.geojson")

AP_gest <- AP_Vahatra %>%
  st_drop_geometry() %>%
  select(ref_AP = nom, gest_1) %>%
  mutate(gest_1 = str_remove(gest_1, "\\n"))


# Avec MNP en excluant autres gestionnaires -------------------------------

grille_matched_MNP <- grille_matched2 %>%
  filter(is.na(gest_1) | gest_1 == "Madagascar National Parks")

grille_matched_MNP %>%
  group_by(ref_AP) %>%
  summarise(n = n())

# Calculer le DID en utilisant la fonction `att_gt`
did_result_MNP <- att_gt(yname = "tx_defor", # variable de résultat
                     tname = "years", # Variable de temps
                     idname = "assetid", # ID des unités
                     gname = "time_treated", # Temps de traitement 
                     weightsname = "weights", # Poids issus du matching
                     data = grille_matched_MNP,
                     panel = TRUE) # panel veut dire qu'on suit les mêmes unités

# Aggregate the ATT results
agg_att_mailles_MNP <- aggte(did_result_MNP, type = "dynamic")

# Display the aggregated results
summary(agg_att_mailles_MNP)

# Visualisation du résultat
ggdid(agg_att_mailles_MNP) 


# Avec MNP en gardant autres gestionnaires avant traitement ---------------


grille_matched_MNP2 <- grille_matched2 %>%
  filter(years < time_treated | time_treated == 0 | 
           gest_1 == "Madagascar National Parks")


# Calculer le DID en utilisant la fonction `att_gt`
did_result_MNP2 <- att_gt(yname = "tx_defor", # variable de résultat
                         tname = "years", # Variable de temps
                         idname = "assetid", # ID des unités
                         gname = "time_treated", # Temps de traitement 
                         weightsname = "weights", # Poids issus du matching
                         data = grille_matched_MNP2,
                         allow_unbalanced_panel = TRUE, # pour garder les autres AP avant traitement
                         panel = TRUE) # panel veut dire qu'on suit les mêmes unités

# Aggregate the ATT results
agg_att_mailles_MNP2 <- aggte(did_result_MNP2, type = "dynamic", na.rm = TRUE)

# Display the aggregated results
summary(agg_att_mailles_MNP2)

# Visualisation du résultat
ggdid(agg_att_mailles_MNP2) 


# Autres AP que MNP sans Ministère --------------------------------------


grille_matched_Others <- grille_matched2 %>%
  filter(years < time_treated | time_treated == 0 | 
           (gest_1 != "Madagascar National Parks" & 
              gest_1 != "Ministère de l'Environnement, de l'Ecologie et des Forêts"))


# Calculer le DID en utilisant la fonction `att_gt`
did_result_Others <- att_gt(yname = "tx_defor", # variable de résultat
                          tname = "years", # Variable de temps
                          idname = "assetid", # ID des unités
                          gname = "time_treated", # Temps de traitement 
                          weightsname = "weights", # Poids issus du matching
                          data = grille_matched_Others,
                          allow_unbalanced_panel = TRUE, # pour garder les autres AP avant traitement
                          panel = TRUE) # panel veut dire qu'on suit les mêmes unités

# Aggregate the ATT results
agg_att_mailles_Others <- aggte(did_result_Others, type = "dynamic", na.rm = TRUE)

# Display the aggregated results
summary(agg_att_mailles_Others)

# Visualisation du résultat
ggdid(agg_att_mailles_Others) 
