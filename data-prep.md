Source data preparation for the England school admissions dashboard
================
Clare Gibson

-   [Introduction](#introduction)
    -   [Source data](#source-data)
    -   [Required packages](#required-packages)
    -   [Custom functions](#custom-functions)
-   [Read data](#read-data)
    -   [Offers](#offers)

# Introduction

This notebook serves as the documented code to read and prepare data for
the England School Admissions Dashboard project
([github](https://github.com/clarelgibson/england-school-admissions) \|
[tableau](https://public.tableau.com/views/Schools_16505251102060/Home?:language=en-GB&:display_count=n&:origin=viz_share_link)).

I will begin by reading in the source data required for the dashboards.
I will then explain my intended approach to convert the source data into
a “star-schema” [dimensional
model](https://en.wikipedia.org/wiki/Dimensional_modeling), using
conformed dimensions to serve multiple fact tables. Finally I will work
through the data wrangling steps necessary to prepare the dimensional
model.

## Source data

The full list of data sources, download links and retrieval steps can be
found in the [project
wiki](https://github.com/clarelgibson/england-school-admissions/wiki/Source-data).

## Required packages

``` r
# Packages
library(tidyverse)      # for general wrangling
library(data.table)     # for transposing dataframes
library(janitor)        # for cleaning column headers
library(lubridate)      # for working with dates
```

## Custom functions

I have created several custom functions to assist with data prep. Load
these functions by sourcing the `utils.R` script in the working
directory.

``` r
# Custom functions
source("utils.R")
```

# Read data

## Offers

This file contains data relating to the number of offers made to
applicants for secondary and primary school places since 2014, and the
proportion which received preferred offers. Data is aggregated at the
school level. Further details including an explanation of the
terminology used in this dataset can be found
[here](https://drive.google.com/drive/u/1/folders/1bbnbd9d4HDn3yXIIhaRSigZV46KpCyKy).

The source data is stored in a CSV file on [Google
Drive](https://drive.google.com/drive/u/1/folders/1lFZhobbGoCKKEtaZ5CDiphTbOxcbvJzW).
We can read the CSV file directly from the source location using the
custom function `read_csv_gdrive()`. When reading in source data, I
usually assign it to a variable with the prefix `src_` to indicate that
this is source data. Once I start to modify the data, I remove the
prefix. That way, I always have a copy of the original source data in
its unaltered form to refer back to.

``` r
# Read in the source data for offers
src_offers_path <- "https://drive.google.com/file/d/1bG0a0WRg-LEnASl6M3J0qyHJA_cMY1CQ/view?usp=sharing"
src_offers <- read_csv_gdrive(src_offers_path)
```

    ## Rows: 171385 Columns: 35
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (21): time_identifier, geographic_level, country_code, country_name, reg...
    ## dbl (14): time_period, old_la_code, school_laestab_as_used, total_number_pla...
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

``` r
# List the columns and data types in the dataframe
spec(src_offers)
```

    ## cols(
    ##   time_period = col_double(),
    ##   time_identifier = col_character(),
    ##   geographic_level = col_character(),
    ##   country_code = col_character(),
    ##   country_name = col_character(),
    ##   region_code = col_character(),
    ##   region_name = col_character(),
    ##   old_la_code = col_double(),
    ##   new_la_code = col_character(),
    ##   la_name = col_character(),
    ##   school_phase = col_character(),
    ##   school_laestab_as_used = col_double(),
    ##   number_preferences_la = col_character(),
    ##   school_name = col_character(),
    ##   total_number_places_offered = col_double(),
    ##   number_preferred_offers = col_double(),
    ##   number_1st_preference_offers = col_double(),
    ##   number_2nd_preference_offers = col_double(),
    ##   number_3rd_preference_offers = col_double(),
    ##   times_put_as_any_preferred_school = col_double(),
    ##   times_put_as_1st_preference = col_double(),
    ##   times_put_as_2nd_preference = col_double(),
    ##   times_put_as_3rd_preference = col_double(),
    ##   proportion_1stprefs_v_1stprefoffers = col_character(),
    ##   proportion_1stprefs_v_totaloffers = col_character(),
    ##   all_applications_from_another_LA = col_double(),
    ##   offers_to_applicants_from_another_LA = col_double(),
    ##   establishment_type = col_character(),
    ##   denomination = col_character(),
    ##   FSM_eligible_percent = col_character(),
    ##   admissions_policy = col_character(),
    ##   urban_rural = col_character(),
    ##   allthrough_school = col_character(),
    ##   school_urn = col_character(),
    ##   entry_year = col_character()
    ## )

From the code outputs above, we can see that this dataframe has 171385
rows and 35 columns (a mix of character and numeric data types). The
columns include some identifiers for time, geography and school, some
descriptive dimensions for the number of preferences and type of school
and some measures relating to the number of applications and offers
made. The grain of the data is that each row represents a single school
for a single academic year.
