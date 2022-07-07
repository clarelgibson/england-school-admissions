################################################################################
# Project:          England School Admissions
# Script purpose:   User-defined functions for data prep
################################################################################

# READ DATA ####################################################################
read_csv_gdrive <- function(link) {
  # Takes a path to a csv file stored on Google Drive as input, reads the csv
  # file into a dataframe and cleans the column headings into an R-friendly
  # format (no spaces or capitalization)
  require(readr)
  require(janitor)
  
  doc_id <- str_extract(link, "[-\\w]{25,}")
  download_str <- "https://docs.google.com/uc?id=%s&export=download"
  download_url <- sprintf(download_str, doc_id)
  
  df <- read_csv(download_url) %>% 
    clean_names
  return(df)
}