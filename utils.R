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
  
  df <- read_csv(download_url,
                 col_types = cols(.default = col_character())) %>% 
    type_convert() %>% 
    clean_names()
  return(df)
}

# DESCRIBE DF ##################################################################
describe_df <- function(df) {
  # This function takes a df as input and returns a new df
  # containing the original df name, original df column names
  # and an example of one of the values stored within each column
  require(data.table)
  
  #df_name <- deparse(substitute(df))
  df <- na.omit(df)
  t_df <- transpose(head(df, 1))
  rownames(t_df) <- colnames(df)
  t_df <- 
    t_df %>% 
    rownames_to_column() %>% 
    #mutate(source_table = df_name) %>% 
    rename(source_field = rowname,
           source_value_example = V1) %>% 
    mutate(source_value_example = as.character(source_value_example)) %>% 
    select(#source_table,
           source_field,
           source_value_example)
  return(t_df)
}