# Function to calculate folder size recursively
get_folder_size <- function(path) {
  # Ensure the path exists
  if (!fs::dir_exists(path)) {
    stop("The specified folder does not exist.")
  }
  
  # Recursively list all files in the directory and get their sizes
  files <- fs::dir_ls(path, recurse = TRUE)
  total_size <- sum(fs::file_size(files))
  
  # Return the size in a readable format
  fs::fs_bytes(total_size)
}

get_folder_size("data")