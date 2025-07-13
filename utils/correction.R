







# Section: Introduction au langage R - La lisibilité du code
# Exercice : améliorer la lisibilité
resultat <- 5 * (3 + 2) - 1  # Calcul du résultat avec des espaces pour plus de lisibilité
resultat


# Section: Introduction au langage R - L'assignation (création d'objets)
# Exercice : créer et réassigner des objets
age <- 25
age

age <- 30  # Nouvelle valeur
age

rm(age)  # Suppression de l'objet
age

# Section: Introduction au langage R - Les différents types d'objets en R
# Exercice : manipuler des vecteurs
poids_kg <- c(55, 60, 72, 49, 65)
poids_kg

poids_g <- poids_kg * 1000
poids_g

# Section: Introduction au langage R - Les tableaux de données (data.frame)
# Exercice : créer un data.frame et afficher une colonne
noms <- c("Alice", "Bob", "Charlie")
ages <- c(25, 30, 35)
tailles <- c(160, 170, 180)

tableau <- data.frame(noms, ages, tailles)
tableau 

tableau$tailles

# Section: Introduction au langage R - Les noms d'objets
# Exercice : nommer des objets
temperature_celsius <- 22.5
pression_hpa <- 1013

# Section: Introduction au langage R - Les fonctions
# Exercice : créer une fonction
carre <- function(x) { x^2 }
carre(3)
carre(10)

# Section: Introduction au langage R - Structures de contrôle
# Exercice : boucle for pour les carrés de 1 à 10
for (i in 1:10) {
  print(i^2)
}

# Section: Introduction au langage R - Les valeurs manquantes
# Pas d'exercice demandé explicitement ici, mais exemple de calcul avec na.rm
ages <- c(20, 30, NA, 40)
mean(ages, na.rm = TRUE)

# Section: Librairies R - tidyverse et dplyr
# Exercice : manipulation avec ventes_magasin
library(tidyverse)
library(lubridate)
ventes_magasin <- data.frame(
  produit = c("Produit A", "Produit B", "Produit A", "Produit C", "Produit B",
              "Produit A", "Produit C", "Produit B", "Produit A"),
  quantite = c(8, 4, 12, 6, 7, 9, 3, 11, 5),
  prix_unitaire = c(10, 15, 8, 12, 20, 10, 18, 14, 9),
  date_vente = ymd(c("2023-01-05", "2023-01-08", "2023-01-09", "2023-01-10",
                     "2023-01-15", "2023-01-20", "2023-01-25", "2023-01-30", "2023-02-02"))
)

ventes_magasin

ventes_par_produit <- ventes_magasin %>%
  filter(quantite > 5) %>%
  mutate(montant = quantite * prix_unitaire) %>%
  group_by(produit) %>%
  summarise(qte_totale = sum(quantite),
            montant_total = sum(montant),
            nb_ventes = n())

ventes_par_produit

# Section: Jointures
# Exercice : enrichir base individuelle avec caractéristiques communales
individus <- data.frame(ID = 1:4, commune = c("A", "B", "A", "C"), revenu = c(200, 250, 180, 220))
individus

communes <- data.frame(commune = c("A", "B", "C"), deforestation = c(0.2, 0.1, 0.3))
individus <- left_join(individus, communes, by = "commune")
individus

# Section: Import de données
# Exercice : importer CSV, Excel, texte
library(readr)
library(readxl)

AP_Vahatra_csv <- read_csv("data/AP_Vahatra.csv")
AP_Vahatra_xlsx <- read_xlsx("data/AP_Vahatra.xlsx")
AP_Vahatra_txt <- read_delim("data/AP_Vahatra.txt", delim = "\t")

head(AP_Vahatra_csv)
head(AP_Vahatra_xlsx)
head(AP_Vahatra_txt)

# Section: Exploration de données - AP_Vahatra
# Exercice supplémentaire
AP_Vahatra <- AP_Vahatra_csv %>% 
  mutate(superficie_km2 = hectares / 100)

AP_Vahatra %>% filter(cat_iucn == "II") %>% select(nom)

AP_Vahatra <- AP_Vahatra %>% mutate(superficie_km2 = hectares / 100)

AP_Vahatra %>% arrange(desc(superficie_km2)) %>% select(nom) %>% head(3)

AP_Vahatra %>% summarise(total = sum(superficie_km2, na.rm = TRUE))

summary(AP_Vahatra$superficie_km2)

q3 <- quantile(AP_Vahatra$superficie_km2, 0.75, na.rm = TRUE)

AP_Vahatra %>% filter(superficie_km2 >= q3) %>% count()



# Section: Production de tableaux avec gt
# Exercice : tableau synthétique des superficies cumulées par année de création
library(gt)

AP_superficie_annees %>%
  gt() %>%
  cols_label(an_creation = "Année",
             superficie_annuelle = "Superficie annuelle (km²)",
             superficie_cumulee = "Superficie cumulée (km²)") %>%
  tab_header(title = "Superficie cumulée des aires protégées par année de création") %>%
  tab_source_note("Source : données Vahatra") %>%
  fmt_number(columns = 2:3, decimals = 2)



# Section: Production de graphiques avec ggplot2
# Exercice : graphique de superficie annuelle
library(ggplot2)

ggplot(AP_superficie_annees, aes(x = an_creation, y = superficie_annuelle)) +
  geom_point() +
  geom_smooth() +
  labs(title = "Superficie annuelle des aires protégées par an", x = "Année", y = "Superficie annuelle (km²)") +
  theme_minimal()