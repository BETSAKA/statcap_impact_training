library(dplyr)
library(stringr)
library(aws.s3)
library(purrr)

# #
# aws.s3::put_object(
#   file = "data/grille_matched.rds",
#   object = "diffusion/mapme_impact_training/data/grille_matched.rds",
#   bucket = "fbedecarrats",
#   region = "",
#   multipart = TRUE)

# A function to put data from local machine to S3
put_to_s3 <- function(from, to) {
  aws.s3::put_object(
    file = from,
    object = to,
    bucket = "fbedecarrats",
    region = "",
    multipart = TRUE)
}

# A function to iterate/vectorize copy
get_from_s3 <- function(from, to) {
  aws.s3::save_object(
    object = from,
    bucket = "fbedecarrats",
    file = to,
    overwrite = FALSE,
    region = "")
}

# To put files
my_files_local <- list.files("data/gadm", full.names = TRUE, recursive = TRUE)
my_files_local
my_files_dest <- paste0("diffusion/mapme_impact_training/", my_files_local)

map2(my_files_local, my_files_dest, put_to_s3)

# to get files
# Listing files in bucket
my_files_s3 <- get_bucket_df(bucket = "fbedecarrats",
                             prefix = "diffusion/mapme_impact_training/data",
                             region = "") %>%
  pluck("Key")

my_files_dest <- str_remove(my_files_s3, "diffusion/mapme_impact_training/")

setdiff(my_files_dest, my_files_s3)
map2(my_files_s3, my_files_dest, get_from_s3)
