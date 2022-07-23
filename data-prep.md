Source data preparation for the England school admissions dashboard
================
Clare Gibson

-   [Introduction](#introduction)
    -   [Source data](#source-data)
    -   [Required packages](#required-packages)
    -   [Custom functions](#custom-functions)
-   [Read data](#read-data)
    -   [Info](#info)
    -   [Offers](#offers)
    -   [Performance](#performance)
    -   [Intake](#intake)
    -   [Calendar](#calendar)
-   [Clean data](#clean-data)
    -   [Info](#info-1)
    -   [Offers](#offers-1)
    -   [Performance](#performance-1)
    -   [Intake](#intake-1)
    -   [Calendar](#calendar-1)
-   [Model data](#model-data)
    -   [Dimensions](#dimensions)
        -   [Local Authority](#local-authority)

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
library(data.table)     # for transposing data frames
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

## Info

This file contains descriptive fields relating to primary and secondary
schools across all local authorities in England. It excludes nurseries,
special schools, children’s centers, pupil referral units and post-16
education. We can consider this largely to be the dimensional data for
the dashboard, while the other datasets for Offers and Performance can
be considered to be the measures.

The source data is stored in a CSV file on [Google
Drive](https://drive.google.com/drive/u/1/folders/1lFZhobbGoCKKEtaZ5CDiphTbOxcbvJzW).
We can read the CSV file directly from the source location using the
custom function `read_csv_gdrive()`. When reading in source data, I
usually assign it to a variable with the prefix `src_` to indicate that
this is source data. Once I start to modify the data, I remove the
prefix. That way, I always have a copy of the original source data in
its unaltered form to refer back to.

``` r
# Read in the source data for info
src_info_path <- "https://drive.google.com/file/d/1kUqKvphHnh4M-NfP4gXLAr9MxdxoWgMT/view?usp=sharing"
src_info <- read_csv_gdrive(src_info_path)
```

``` r
# List the columns and data types in the data frame
glimpse(src_info)
```

    ## Rows: 36,704
    ## Columns: 122
    ## $ urn                              <dbl> 100000, 100008, 100009, 100010, 10001…
    ## $ la_code                          <dbl> 201, 202, 202, 202, 202, 202, 202, 20…
    ## $ la_name                          <chr> "City of London", "Camden", "Camden",…
    ## $ establishment_number             <dbl> 3614, 2019, 2036, 2065, 2078, 2095, 2…
    ## $ establishment_name               <chr> "The Aldgate School", "Argyle Primary…
    ## $ type_of_establishment_name       <chr> "Voluntary aided school", "Community …
    ## $ establishment_type_group_name    <chr> "Local authority maintained schools",…
    ## $ establishment_status_name        <chr> "Open", "Open", "Open", "Open", "Open…
    ## $ reason_establishment_opened_name <chr> "Not applicable", "Not applicable", "…
    ## $ open_date                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ reason_establishment_closed_name <chr> "Not applicable", "Not applicable", "…
    ## $ close_date                       <chr> NA, NA, NA, NA, NA, "31-08-2021", NA,…
    ## $ phase_of_education_name          <chr> "Primary", "Primary", "Primary", "Pri…
    ## $ statutory_low_age                <dbl> 3, 3, 3, 2, 2, 3, 3, 3, 3, 7, 3, 2, 3…
    ## $ statutory_high_age               <dbl> 11, 11, 11, 11, 11, 11, 11, 11, 11, 1…
    ## $ boarders_name                    <chr> "No boarders", "No boarders", "No boa…
    ## $ nursery_provision_name           <chr> "Has Nursery Classes", "Has Nursery C…
    ## $ official_sixth_form_name         <chr> "Does not have a sixth form", "Does n…
    ## $ gender_name                      <chr> "Mixed", "Mixed", "Mixed", "Mixed", "…
    ## $ religious_character_name         <chr> "Church of England", "Does not apply"…
    ## $ religious_ethos_name             <chr> "Does not apply", "Does not apply", "…
    ## $ diocese_name                     <chr> "Diocese of London", "Not applicable"…
    ## $ admissions_policy_name           <chr> "Not applicable", "Not applicable", "…
    ## $ school_capacity                  <dbl> 276, 432, 446, 583, 459, 436, 232, 21…
    ## $ special_classes_name             <chr> "No Special Classes", "No Special Cla…
    ## $ census_date                      <chr> "21-01-2021", "21-01-2021", "21-01-20…
    ## $ number_of_pupils                 <dbl> 270, 335, 418, 367, 407, 211, 191, 23…
    ## $ number_of_boys                   <dbl> 133, 156, 231, 200, 212, 109, 88, 113…
    ## $ number_of_girls                  <dbl> 137, 179, 187, 167, 195, 102, 103, 11…
    ## $ percentage_fsm                   <dbl> 13.7, 51.9, 38.5, 49.1, 21.2, 57.8, 4…
    ## $ trust_school_flag_name           <chr> "Not applicable", "Not applicable", "…
    ## $ trusts_name                      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ school_sponsor_flag_name         <chr> "Not applicable", "Not applicable", "…
    ## $ school_sponsors_name             <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ federation_flag_name             <chr> "Not under a federation", "Not under …
    ## $ federations_name                 <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ ukprn                            <dbl> 10079319, 10078065, 10077183, 1007385…
    ## $ fehe_identifier                  <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ further_education_type_name      <chr> "Not applicable", "Not applicable", "…
    ## $ ofsted_last_insp                 <chr> "19-04-2013", "30-01-2019", "23-03-20…
    ## $ last_changed_date                <chr> "26-04-2022", "18-05-2022", "16-06-20…
    ## $ street                           <chr> "St James's Passage", "Tonbridge Stre…
    ## $ locality                         <chr> "Duke's Place", NA, "West Hampstead",…
    ## $ address3                         <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ town                             <chr> "London", "London", "London", "London…
    ## $ county_name                      <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ postcode                         <chr> "EC3A 5DE", "WC1H 9EG", "NW6 1QL", "N…
    ## $ school_website                   <chr> "www.thealdgateschool.org", "http://w…
    ## $ telephone_num                    <dbl> 2072831147, 2078374590, 2074358646, 2…
    ## $ head_title_name                  <chr> "Miss", "Ms", "Mr", "Ms", "Mrs", "Ms"…
    ## $ head_first_name                  <chr> "Alexandra", "Jemima", "Samuel", "Hel…
    ## $ head_last_name                   <chr> "Allan", "Wade", "Drake", "Bruckdorfe…
    ## $ head_preferred_job_title         <chr> "Headteacher", "Headteacher", "Headte…
    ## $ bso_inspectorate_name_name       <chr> "Not applicable", "Not applicable", "…
    ## $ inspectorate_report              <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ date_of_last_inspection_visit    <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ next_inspection_visit            <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ teen_moth_name                   <chr> "Not applicable", "Not applicable", "…
    ## $ teen_moth_places                 <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ ccf_name                         <chr> "Not applicable", "Not applicable", "…
    ## $ senpru_name                      <chr> "Not applicable", "Not applicable", "…
    ## $ ebd_name                         <chr> "Not applicable", "Not applicable", "…
    ## $ places_pru                       <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ ft_prov_name                     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ ed_by_other_name                 <chr> "Not applicable", "Not applicable", "…
    ## $ section41approved_name           <chr> "Not applicable", "Not applicable", "…
    ## $ sen1_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen2_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen3_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen4_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen5_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen6_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen7_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen8_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen9_name                        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen10_name                       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen11_name                       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen12_name                       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen13_name                       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ type_of_resourced_provision_name <chr> NA, NA, NA, NA, NA, "Not applicable",…
    ## $ resourced_provision_on_roll      <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ resourced_provision_capacity     <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen_unit_on_roll                 <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen_unit_capacity                <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ gor_name                         <chr> "London", "London", "London", "London…
    ## $ district_administrative_name     <chr> "City of London", "Camden", "Camden",…
    ## $ administrative_ward_name         <chr> "Portsoken", "King's Cross", "Fortune…
    ## $ parliamentary_constituency_name  <chr> "Cities of London and Westminster", "…
    ## $ urban_rural_name                 <chr> "(England/Wales) Urban major conurbat…
    ## $ gssla_code_name                  <chr> "E09000001", "E09000007", "E09000007"…
    ## $ easting                          <dbl> 533498, 530238, 524888, 529912, 52870…
    ## $ northing                         <dbl> 181201, 182761, 185067, 184835, 18659…
    ## $ msoa_name                        <chr> "City of London 001", "Camden 025", "…
    ## $ lsoa_name                        <chr> "City of London 001F", "Camden 025C",…
    ## $ inspectorate_name_name           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen_stat                         <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ sen_no_stat                      <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ props_name                       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ ofsted_rating_name               <chr> "Outstanding", "Good", "Good", "Good"…
    ## $ rsc_region_name                  <chr> "North-West London and South-Central …
    ## $ country_name                     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ uprn                             <dbl> 200000071925, 5090707, 5090655, 50906…
    ## $ site_name                        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ qab_name_name                    <chr> "Not applicable", "Not applicable", "…
    ## $ establishment_accredited_name    <chr> "Not applicable", "Not applicable", "…
    ## $ qab_report                       <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ ch_number                        <lgl> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ msoa_code                        <chr> "E02000001", "E02000190", "E02000170"…
    ## $ lsoa_code                        <chr> "E01032739", "E01000941", "E01000873"…
    ## $ fsm                              <dbl> 37, 174, 161, 164, 84, 122, 92, 90, 6…
    ## $ link_1                           <chr> "Does not have links", "Does not have…
    ## $ link_2                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_3                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_4                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_5                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_6                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_7                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_8                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_9                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_10                          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_11                          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    ## $ link_12                          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, N…

This data frame has 36704 rows and 122 columns. The columns are a mix of
character, numeric and logical[^1] data types. The columns include some
identifiers for time, geography and school, some descriptive dimensions
about each school and some measures relating to the number of pupils of
different types. Each row represents a single school and the data
represents the latest available.

## Offers

This file contains data relating to the number of offers made to
applicants for secondary and primary school places since 2014, and the
proportion which received preferred offers. Data is aggregated at the
school level. Further details including an explanation of the
terminology used in this dataset can be found
[here](https://drive.google.com/drive/u/1/folders/1bbnbd9d4HDn3yXIIhaRSigZV46KpCyKy).
Once again, we can connect to it through Google Drive.

``` r
# Read in the source data for offers
src_offers_path <- "https://drive.google.com/file/d/1bG0a0WRg-LEnASl6M3J0qyHJA_cMY1CQ/view?usp=sharing"
src_offers <- read_csv_gdrive(src_offers_path)
```

``` r
# List the columns and data types in the data frame
glimpse(src_offers)
```

    ## Rows: 171,385
    ## Columns: 35
    ## $ time_period                          <dbl> 202223, 202223, 202223, 202223, 2…
    ## $ time_identifier                      <chr> "Academic year", "Academic year",…
    ## $ geographic_level                     <chr> "School", "School", "School", "Sc…
    ## $ country_code                         <chr> "E92000001", "E92000001", "E92000…
    ## $ country_name                         <chr> "England", "England", "England", …
    ## $ region_code                          <chr> "E13000001", "E13000001", "E13000…
    ## $ region_name                          <chr> "Inner London", "Inner London", "…
    ## $ old_la_code                          <dbl> 201, 202, 202, 202, 202, 202, 202…
    ## $ new_la_code                          <chr> "E09000001", "E09000007", "E09000…
    ## $ la_name                              <chr> "City of London", "Camden", "Camd…
    ## $ school_phase                         <chr> "Primary", "Primary", "Primary", …
    ## $ school_laestab_as_used               <dbl> 2013614, 2022000, 2022001, 202200…
    ## $ number_preferences_la                <chr> "6", "6", "6", "6", "6", "6", "6"…
    ## $ school_name                          <chr> "The Aldgate School", "St Luke's …
    ## $ total_number_places_offered          <dbl> 30, 15, 30, 60, 43, 60, 37, 48, 3…
    ## $ number_preferred_offers              <dbl> 30, 15, 30, 60, 38, 60, 35, 48, 3…
    ## $ number_1st_preference_offers         <dbl> 30, 11, 23, 51, 34, 43, 28, 31, 2…
    ## $ number_2nd_preference_offers         <dbl> 0, 3, 3, 6, 3, 10, 4, 9, 0, 5, 3,…
    ## $ number_3rd_preference_offers         <dbl> 0, 1, 3, 3, 1, 2, 2, 2, 2, 1, 0, …
    ## $ times_put_as_any_preferred_school    <dbl> 81, 94, 129, 163, 72, 150, 98, 12…
    ## $ times_put_as_1st_preference          <dbl> 42, 21, 34, 56, 34, 44, 28, 31, 2…
    ## $ times_put_as_2nd_preference          <dbl> 16, 26, 34, 41, 14, 37, 20, 27, 1…
    ## $ times_put_as_3rd_preference          <dbl> 6, 24, 23, 25, 11, 23, 15, 13, 16…
    ## $ proportion_1stprefs_v_1stprefoffers  <chr> "1.4", "1.909090909", "1.47826087…
    ## $ proportion_1stprefs_v_totaloffers    <chr> "1.4", "1.4", "1.133333333", "0.9…
    ## $ all_applications_from_another_la     <dbl> 62, 19, 8, 54, 5, 34, 46, 35, 0, …
    ## $ offers_to_applicants_from_another_la <chr> "16", "3", "1", "20", "2", "11", …
    ## $ establishment_type                   <chr> "Voluntary aided school", "Free s…
    ## $ denomination                         <chr> "Faith", "Faith", "No religious c…
    ## $ fsm_eligible_percent                 <chr> "13.7", "22.4", "12.8", "34.2", "…
    ## $ admissions_policy                    <chr> "n/a", "n/a", "n/a", "n/a", "n/a"…
    ## $ urban_rural                          <chr> "Urban major conurbation", "Urban…
    ## $ allthrough_school                    <chr> "No", "No", "No", "No", "No", "No…
    ## $ school_urn                           <chr> "100000", "136807", "139837", "14…
    ## $ entry_year                           <chr> "R", "R", "R", "R", "R", "R", "R"…

From the code outputs above, we can see that this data frame has 171385
rows and 35 columns (a mix of character and numeric data types). The
columns include some identifiers for time, geography and school, some
descriptive dimensions for the number of preferences and type of school
and some measures relating to the number of applications and offers
made. Each row represents a single school for a single academic year.

## Performance

These files contain key stage 2 (KS2) performance data for primary
schools and key stage 4 (KS4) performance data for secondary schools in
England for academic years from 2014 onwards. Note that due to the
COVID-19 pandemic, the UK Government cancelled all statutory national
curriculum assessments due to be held in summer 2020 and 2021 at all Key
Stages. Therefore, no data is available for the 2019/20 or 2020/21
academic years. Further details including an explanation of the
terminology used in this dataset can be found
[here](https://drive.google.com/drive/folders/1vai66CUaYhPI0RXQI-BlC5kufZZyf3JU?usp=sharing).

The source data for performance is stored in several CSV files on the
Google Drive. Having read through the guidance notes for these files, it
seems that it is a difficult challenge to do a year-over-year comparison
of performance, due to the changes that are frequently made to the way
the tests are conducted and results reported. For the dashboard, I have
decided to use only the performance figures from the most recent year.
However, the data for previous years going back to 2014 is available in
the Google Drive.

``` r
# Read in the most recent performance data files
# 2018-19 KS2
src_perf_1819ks2_path <- "https://drive.google.com/file/d/1CmXvDtDOmIlXXUzZ9SPW4Yoti-rTzi75/view?usp=sharing"
src_perf_1819ks2 <- read_csv_gdrive(src_perf_1819ks2_path)

# 2018-19 KS4
src_perf_1819ks4_path <- "https://drive.google.com/file/d/1uBhU0yeuV97d66PRR60pq8UaRWvdGIaA/view?usp=sharing"
src_perf_1819ks4 <- read_csv_gdrive(src_perf_1819ks4_path)
```

These files contain a large number of columns. We will need to pick out
only the most relevant for reporting, which can be standardised across
all schools.

## Intake

This dataset includes details about the year groups that schools are
divided into in England. The data is aggregated by year group.

``` r
# Read in the source data for intake
src_intake_path <- "https://drive.google.com/file/d/1ASiYEbIbXg7VVNnkz3N1Cg1lHNqDxMiQ/view?usp=sharing"
src_intake <- read_csv_gdrive(src_intake_path)
```

``` r
# List the columns and data types in the data frame
glimpse(src_intake)
```

    ## Rows: 14
    ## Columns: 8
    ## $ nc_key              <dbl> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14
    ## $ nc_year             <chr> "R", "1", "2", "3", "4", "5", "6", "7", "8", "9", …
    ## $ nc_year_description <chr> "Reception", "Year 1", "Year 2", "Year 3", "Year 4…
    ## $ education_phase     <chr> "Primary", "Primary", "Primary", "Primary", "Prima…
    ## $ education_subphase  <chr> "Infant", "Infant", "Infant", "Junior", "Junior", …
    ## $ key_stage           <chr> "EYFS", "KS1", "KS1", "KS2", "KS2", "KS2", "KS2", …
    ## $ statutory_age_min   <dbl> 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17
    ## $ statutory_age_max   <dbl> 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18

This dataset has 14 rows and 8 columns and contains largely descriptive
information about the academic year groups in England.

## Calendar

This dataset includes details about the academic years covered by the
data.

``` r
# Read in the source data for calendar
src_calendar_path <- "https://drive.google.com/file/d/1el2cL02nQidzN1pMcZ7AUb3h6wXuzN_E/view?usp=sharing"
src_calendar <- read_csv_gdrive(src_calendar_path)
```

``` r
# List the columns and data types in the data frame
glimpse(src_calendar)
```

    ## Rows: 100
    ## Columns: 6
    ## $ year_key            <dbl> 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 20…
    ## $ academic_year_start <dbl> 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 20…
    ## $ academic_year_end   <dbl> 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 20…
    ## $ academic_year_full  <chr> "2000-2001", "2001-2002", "2002-2003", "2003-2004"…
    ## $ academic_year_short <chr> "00-01", "01-02", "02-03", "03-04", "04-05", "05-0…
    ## $ covid_indicator     <chr> "Pre-Pandemic", "Pre-Pandemic", "Pre-Pandemic", "P…

This will be our date table. Since the lowest unit of time in the data
is year, this is the level of detail of the calendar table. This table
has 100 rows and 6 columns.

# Clean data

## Info

One key piece of cleaning we need to do with this dataset is to provide
a mechanism to group entities that describe the same establishment
(i.e. where there has been a change in URN over time due to conversion
to academy). We can do this using the `links` columns at the end of this
data frame, along with the `urn`, to create a bridge table, which we’ll
call `brg_school`.

``` r
# Set up the bridge table
brg_school_unfiltered <- src_info %>%
  # select required columns
  select(master_urn = urn,
         status = establishment_status_name,
         starts_with("link_")) %>% 
  # pivot the links
  pivot_longer(!c(master_urn, status),
               values_drop_na = TRUE) %>% 
  # drop the name column
  select(-name) %>% 
  # split the description column into useful data
  mutate(linked_urn = as.numeric(str_extract(value,"\\d+")),
         link_type = str_trim(str_extract(value,"\\D+"))) %>% 
  # drop the value column
  select(-value)
```

At this point, we can stop and check what are the unique values of the
`link_type` column?

``` r
# What are the unique values of link_type
unique(brg_school_unfiltered$link_type)
```

    ##  [1] "Does not have links"                                           
    ##  [2] "Successor - merged"                                            
    ##  [3] "Successor"                                                     
    ##  [4] "Predecessor - merged"                                          
    ##  [5] "Predecessor"                                                   
    ##  [6] "Sixth Form Centre Link"                                        
    ##  [7] "Predecessor - amalgamated"                                     
    ##  [8] "Successor - amalgamated"                                       
    ##  [9] "Result of Amalgamation"                                        
    ## [10] "Merged - expansion in school capacity and changer in age range"
    ## [11] "Merged - change in age range"                                  
    ## [12] "Other"                                                         
    ## [13] "Successor - Split School"                                      
    ## [14] "Merged - expansion of school capacity"                         
    ## [15] "Predecessor - Split School"

The links I am interested in are the predecessor-successor links so that
I can keep schools grouped over time. I want the successor school to be
retained as the master school and all predecessors to be linked to the
master. If a school has no links then we simply list the master and
linked URNs as the same number. Therefore, I need to keep all of the
open schools as the master list and any predecessors need to be linked
to those master URNs.

``` r
# Filter the table
brg_school <- brg_school_unfiltered %>% 
  # add self-urn
  mutate(self_urn = master_urn) %>% 
  pivot_longer(cols = c(linked_urn, self_urn),
               names_to = "urn_type",
               values_to = "linked_urn",
               values_drop_na = TRUE) %>% 
  # keep only currently open schools
  filter(grepl("^Open.*",
               status,
               ignore.case = TRUE)) %>% 
  # select required columns
  select(master_urn,
         linked_urn)
```

Now that the bridge table is set up I can filter the `src_info` table to
include only the currently open schools. The number of distinct URNs in
this table should then match the number of distinct master URNs in
`brg_school`.

``` r
# Keep only the currently open schools in info
info <- src_info %>% 
  filter(grepl("^Open.*",
               establishment_status_name))
```

``` r
# Check if the number of distinct URNs in info matches the number of
# distinct master URNs in brg_school
n_distinct(info$urn) == n_distinct(brg_school$master_urn)
```

    ## [1] TRUE

The numbers match. Success!

Next, let’s keep only the columns we need from `src_info`.

``` r
# Keep only the required columns from src_info
info <- info %>% 
  select(urn:establishment_status_name,
         open_date,
         close_date,
         phase_of_education_name:statutory_high_age,
         gender_name,
         religious_character_name,
         admissions_policy_name,
         school_capacity,
         number_of_pupils:percentage_fsm,
         ofsted_last_insp:head_preferred_job_title,
         gor_name:lsoa_name,
         ofsted_rating_name,
         msoa_code:fsm)
```

Let’s now review the selected column headings in this dataset and the
number of unique values in each column

``` r
# Print a list of the column headings in the info df
info %>% 
  summarise_all(n_distinct) %>% 
  transpose(keep.names = "field") %>% 
  rename(unique_values = V1)
```

    ##                              field unique_values
    ## 1                              urn         20188
    ## 2                          la_code           152
    ## 3                          la_name           152
    ## 4             establishment_number          2531
    ## 5               establishment_name         18522
    ## 6       type_of_establishment_name             9
    ## 7    establishment_type_group_name             3
    ## 8        establishment_status_name             2
    ## 9                        open_date           311
    ## 10                      close_date             8
    ## 11         phase_of_education_name             5
    ## 12               statutory_low_age            14
    ## 13              statutory_high_age            13
    ## 14                     gender_name             4
    ## 15        religious_character_name            29
    ## 16          admissions_policy_name             4
    ## 17                 school_capacity          1488
    ## 18                number_of_pupils          1735
    ## 19                  number_of_boys          1050
    ## 20                 number_of_girls          1065
    ## 21                  percentage_fsm           708
    ## 22                ofsted_last_insp          1487
    ## 23               last_changed_date           294
    ## 24                          street         13495
    ## 25                        locality          6591
    ## 26                        address3           991
    ## 27                            town          1427
    ## 28                     county_name            58
    ## 29                        postcode         19440
    ## 30                  school_website         19603
    ## 31                   telephone_num         20035
    ## 32                 head_title_name            19
    ## 33                 head_first_name          2252
    ## 34                  head_last_name          8079
    ## 35        head_preferred_job_title           152
    ## 36                        gor_name             9
    ## 37    district_administrative_name           309
    ## 38        administrative_ward_name          6249
    ## 39 parliamentary_constituency_name           533
    ## 40                urban_rural_name            10
    ## 41                 gssla_code_name           153
    ## 42                         easting         19149
    ## 43                        northing         19321
    ## 44                       msoa_name          6579
    ## 45                       lsoa_name         15565
    ## 46              ofsted_rating_name             6
    ## 47                       msoa_code          6579
    ## 48                       lsoa_code         15565
    ## 49                             fsm           525

Some columns have relatively few unique values, making these columns
clearly categorical. I’d like to review the values to ensure they are
consistent and well labelled.

``` r
# Review the unique values in establishment type
unique(info$type_of_establishment_name)
```

    ## [1] "Voluntary aided school"       "Community school"            
    ## [3] "Foundation school"            "Voluntary controlled school" 
    ## [5] "Academy sponsor led"          "Academy converter"           
    ## [7] "Free schools"                 "Studio schools"              
    ## [9] "University technical college"

These values all look ok. [This
page](https://www.leicester.gov.uk/schools-and-learning/school-and-colleges/school-admissions/understanding-the-different-types-of-school/)
has some useful definitions of the different types of school.

``` r
# Review the unique values in establishment group
unique(info$establishment_type_group_name)
```

    ## [1] "Local authority maintained schools" "Academies"                         
    ## [3] "Free Schools"

All ok.

``` r
# Review the unique values in establishment status
unique(info$establishment_status_name)
```

    ## [1] "Open"                        "Open, but proposed to close"

All ok.

``` r
# Review the unique values in phase of education
unique(info$phase_of_education_name)
```

    ## [1] "Primary"                 "Secondary"              
    ## [3] "All-through"             "Middle deemed secondary"
    ## [5] "Middle deemed primary"

All ok.

``` r
# Review the unique values in gender
unique(info$gender_name)
```

    ## [1] "Mixed" "Girls" "Boys"  NA

Some missing values here. Let’s replace those with ‘Not reported’.

``` r
# Convert missing values in gender
info$gender_name[is.na(info$gender_name)] <- "Not reported"

# Check the results
unique(info$gender_name)
```

    ## [1] "Mixed"        "Girls"        "Boys"         "Not reported"

All ok.

``` r
# Review the unique values in religious character
unique(info$religious_character_name)
```

    ##  [1] "Church of England"                                       
    ##  [2] "Does not apply"                                          
    ##  [3] "Roman Catholic"                                          
    ##  [4] "Catholic"                                                
    ##  [5] "None"                                                    
    ##  [6] "Jewish"                                                  
    ##  [7] "Muslim"                                                  
    ##  [8] "Church of England/Christian"                             
    ##  [9] "Church of England/Methodist"                             
    ## [10] "Church of England/Free Church"                           
    ## [11] "Methodist"                                               
    ## [12] "Multi-faith"                                             
    ## [13] "Church of England/Roman Catholic"                        
    ## [14] "Christian/non-denominational"                            
    ## [15] "Roman Catholic/Church of England"                        
    ## [16] "Christian"                                               
    ## [17] NA                                                        
    ## [18] "United Reformed Church"                                  
    ## [19] "Quaker"                                                  
    ## [20] "Church of England/United Reformed Church"                
    ## [21] "Sikh"                                                    
    ## [22] "Seventh Day Adventist"                                   
    ## [23] "Hindu"                                                   
    ## [24] "Greek Orthodox"                                          
    ## [25] "Orthodox Jewish"                                         
    ## [26] "Anglican"                                                
    ## [27] "Anglican/Church of England"                              
    ## [28] "Methodist/Church of England"                             
    ## [29] "Church of England/Methodist/United Reform Church/Baptist"

Again, let’s fix the missing values.

``` r
# Convert missing values in religious character
info$religious_character_name[is.na(info$religious_character_name)] <- 
  "Not reported"

# Check the results
unique(info$religious_character_name)
```

    ##  [1] "Church of England"                                       
    ##  [2] "Does not apply"                                          
    ##  [3] "Roman Catholic"                                          
    ##  [4] "Catholic"                                                
    ##  [5] "None"                                                    
    ##  [6] "Jewish"                                                  
    ##  [7] "Muslim"                                                  
    ##  [8] "Church of England/Christian"                             
    ##  [9] "Church of England/Methodist"                             
    ## [10] "Church of England/Free Church"                           
    ## [11] "Methodist"                                               
    ## [12] "Multi-faith"                                             
    ## [13] "Church of England/Roman Catholic"                        
    ## [14] "Christian/non-denominational"                            
    ## [15] "Roman Catholic/Church of England"                        
    ## [16] "Christian"                                               
    ## [17] "Not reported"                                            
    ## [18] "United Reformed Church"                                  
    ## [19] "Quaker"                                                  
    ## [20] "Church of England/United Reformed Church"                
    ## [21] "Sikh"                                                    
    ## [22] "Seventh Day Adventist"                                   
    ## [23] "Hindu"                                                   
    ## [24] "Greek Orthodox"                                          
    ## [25] "Orthodox Jewish"                                         
    ## [26] "Anglican"                                                
    ## [27] "Anglican/Church of England"                              
    ## [28] "Methodist/Church of England"                             
    ## [29] "Church of England/Methodist/United Reform Church/Baptist"

All ok.

``` r
# Review the unique values in admissions policy
unique(info$admissions_policy_name)
```

    ## [1] "Not applicable" "Non-selective"  "Selective"      NA

Again let’s fix the missing values.

``` r
# Convert missing values in admissions policy
info$admissions_policy_name[is.na(info$admissions_policy_name)] <- 
  "Not reported"

# Check the results
unique(info$admissions_policy_name)
```

    ## [1] "Not applicable" "Non-selective"  "Selective"      "Not reported"

All ok.

``` r
# Review the unique values in ofsted rating
unique(info$ofsted_rating_name)
```

    ## [1] "Outstanding"          "Good"                 "Requires improvement"
    ## [4] "Special Measures"     "Serious Weaknesses"   NA

Some recoding is necessary here. According to
[Ofsted](https://www.gov.uk/government/publications/education-inspection-framework/education-inspection-framework),
school inspections use a 4-point grading scale:

-   grade 1 - outstanding
-   grade 2 - good
-   grade 3 - requires improvement
-   grade 4 - inadequate

In our dataset, I see some other values of `Serious Weaknesses` and
`Special Measures`, which are not on the ratings list provided by
Ofsted. In fact, both of these ratings are a
[subset](https://www.gov.uk/government/publications/school-inspections-a-guide-for-parents/school-inspections-a-guide-for-parents)
of the “inadequate” (grade 4) rating. Therefore, I can recode both of
these values as `inadequate`. I can also add in the grade points to the
ratings dimension table to provide a quantitative and aggregatable
measure.

``` r
# Fix values for ofsted rating
info <- info %>% 
    mutate(ofsted_rating_name = case_when(
      grepl("Weakness", ofsted_rating_name) ~ "Inadequate",
      grepl("Measures", ofsted_rating_name) ~ "Inadequate",
      is.na(ofsted_rating_name) ~ "Not reported",
      TRUE ~ ofsted_rating_name
    ),
    ofsted_rating_score = case_when(
    grepl("Outstanding", ofsted_rating_name) ~ 1,
    grepl("Good", ofsted_rating_name) ~ 2,
    grepl("improvement", ofsted_rating_name) ~ 3,
    grepl("Inadequate", ofsted_rating_name) ~ 4
  ))

# Check results
unique(info$ofsted_rating_name)
```

    ## [1] "Outstanding"          "Good"                 "Requires improvement"
    ## [4] "Inadequate"           "Not reported"

``` r
unique(info$ofsted_rating_score)
```

    ## [1]  1  2  3  4 NA

## Offers

Let’s keep only the columns we need from `src_offers`. Some of the
columns are duplicates of columns already in the `info` table, and some
are just not required.

``` r
# Select required columns from offers
offers <- src_offers %>% 
  select(time_period,
         region_code,
         region_name,
         old_la_code,
         school_laestab_as_used,
         la_name,
         number_preferences_la,
         total_number_places_offered:offers_to_applicants_from_another_la,
         denomination,
         school_urn,
         entry_year)
```

Next we can filter out any records where the `school_urn` is `n/a`.

``` r
# Remove entries with null URN
offers <- offers %>% 
  filter(school_urn != "n/a")
```

Let’s now review the selected column headings in this dataset and the
number of unique values in each column

``` r
# Print a list of the column headings in the offers df
offers %>% 
  summarise_all(n_distinct) %>% 
  transpose(keep.names = "field") %>% 
  rename(unique_values = V1)
```

    ##                                   field unique_values
    ## 1                           time_period             9
    ## 2                           region_code            10
    ## 3                           region_name            10
    ## 4                           old_la_code           155
    ## 5                school_laestab_as_used         21371
    ## 6                               la_name           157
    ## 7                 number_preferences_la             5
    ## 8           total_number_places_offered           425
    ## 9               number_preferred_offers           425
    ## 10         number_1st_preference_offers           403
    ## 11         number_2nd_preference_offers           108
    ## 12         number_3rd_preference_offers            61
    ## 13    times_put_as_any_preferred_school          1599
    ## 14          times_put_as_1st_preference           593
    ## 15          times_put_as_2nd_preference           539
    ## 16          times_put_as_3rd_preference           438
    ## 17  proportion_1stprefs_v_1stprefoffers          9830
    ## 18    proportion_1stprefs_v_totaloffers         15432
    ## 19     all_applications_from_another_la           760
    ## 20 offers_to_applicants_from_another_la           197
    ## 21                         denomination             3
    ## 22                           school_urn         24404
    ## 23                           entry_year             3

Let’s review the categorical values to ensure they are consistent and
well labelled.

``` r
# Review the unique values in denomination
unique(offers$denomination)
```

    ## [1] "Faith"                  "No religious character" "n/a"

There are some values of `n/a` here. Let’s see what those are.

``` r
# Review the n/a values in denomination
offers %>% 
  filter(denomination == "n/a") %>% 
  head()
```

    ## # A tibble: 6 × 23
    ##   time_period region_code region_name   old_la_code school_laestab_as_u… la_name
    ##         <dbl> <chr>       <chr>               <dbl>                <dbl> <chr>  
    ## 1      202223 E12000009   South West            803              8032016 South …
    ## 2      202223 E12000004   East Midlands         830              8302064 Derbys…
    ## 3      202223 E12000009   South West            865              8652044 Wiltsh…
    ## 4      202223 E12000009   South West            865              8652054 Wiltsh…
    ## 5      202223 E12000009   South West            866              8662022 Swindon
    ## 6      202223 E12000008   South East            867              8672002 Brackn…
    ## # … with 17 more variables: number_preferences_la <chr>,
    ## #   total_number_places_offered <dbl>, number_preferred_offers <dbl>,
    ## #   number_1st_preference_offers <dbl>, number_2nd_preference_offers <dbl>,
    ## #   number_3rd_preference_offers <dbl>,
    ## #   times_put_as_any_preferred_school <dbl>, times_put_as_1st_preference <dbl>,
    ## #   times_put_as_2nd_preference <dbl>, times_put_as_3rd_preference <dbl>,
    ## #   proportion_1stprefs_v_1stprefoffers <chr>, …

I guess this must be for schools who did not report their denomination.
Let’s replace `n/a` with `Not reported`.

``` r
# Replace n/a
offers$denomination[offers$denomination == "n/a"] <- "Not reported"

# Check the results
unique(offers$denomination)
```

    ## [1] "Faith"                  "No religious character" "Not reported"

All ok.

``` r
# Review the unique values in entry year
unique(offers$entry_year)
```

    ## [1] "R" "7" "9"

All ok.

## Performance

From this dataset we really need to select one or two good measures of
performance for KS2 and KS4, along with the URN so that we can join back
to school.

-   For KS2 we’ll used the progress measures `readprog`, `writprog` and
    `matprog`. [This
    article](https://www.theschoolrun.com/understanding-primary-school-league-tables)
    has a good explanation of the KS2 progress scores, and [this
    article](https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/851788/KS2_progress_banding_calculations_bandings_2019.pdf)
    explains how the bandings can be calculated.
-   For KS4 we’ll use the progress 8 and attainment 8 measures `p8mea`
    and `att8scr`. [This
    article](https://www.goodschoolsguide.co.uk/curricula-and-exams/progress-8-attainment-8)
    has a good explanation of these measures.

We will further need to filter both the KS2 and KS4 data to include only
rows that are aggregated at the mainstream school level (`RECTYPE = 1`).

``` r
# Clean the KS2 data
perf_ks2 <- src_perf_1819ks2 %>% 
  # Filter to rectype == 1
  filter(rectype == 1) %>% 
  # Select the required columns
  select(urn,
         readprog,
         writprog,
         matprog) %>% 
  # Pivot data
  pivot_longer(-urn,
               names_to = "progress_measure",
               values_to = "progress_value") %>% 
  # Convert progress value to numeric
  mutate(progress_value = as.numeric(progress_value))

# View the head
head(perf_ks2)
```

    ## # A tibble: 6 × 3
    ##      urn progress_measure progress_value
    ##    <dbl> <chr>                     <dbl>
    ## 1 141279 readprog                    2.6
    ## 2 141279 writprog                    2.3
    ## 3 141279 matprog                     2  
    ## 4 119910 readprog                    2.4
    ## 5 119910 writprog                    3.8
    ## 6 119910 matprog                    -1

``` r
# Clean the KS4 data
perf_ks4 <- src_perf_1819ks4 %>% 
  # Filter to rectype == 1
  filter(rectype == 1) %>% 
  # Select the required columns
  select(urn,
         p8mea,
         att8scr) %>% 
  # Pivot data
  pivot_longer(-urn,
               names_to = "progress_measure",
               values_to = "progress_value") %>% 
  # Convert progress value to numeric
  mutate(progress_value = as.numeric(progress_value))

# View the head
head(perf_ks4)
```

    ## # A tibble: 6 × 3
    ##      urn progress_measure progress_value
    ##    <dbl> <chr>                     <dbl>
    ## 1 100001 p8mea                     NA   
    ## 2 100001 att8scr                   57.9 
    ## 3 100003 p8mea                     NA   
    ## 4 100003 att8scr                   20   
    ## 5 100049 p8mea                     -0.11
    ## 6 100049 att8scr                   42.4

Now we can join the KS2 and KS4 data together and recode the progress
measure names.

``` r
# Combine two data frames
performance <- perf_ks2 %>% 
  bind_rows(perf_ks4) %>% 
  # Recode the progress measure names
  mutate(progress_measure = case_when(
    grepl("read.+", progress_measure) ~ "Reading progress score",
    grepl("writ.+", progress_measure) ~ "Writing progress score",
    grepl("mat.+", progress_measure) ~ "Maths progress score",
    grepl("p8.+", progress_measure) ~ "Progress 8 score",
    grepl("att8.+", progress_measure) ~ "Attainment 8 score"
  ))

# View the head
head(performance)
```

    ## # A tibble: 6 × 3
    ##      urn progress_measure       progress_value
    ##    <dbl> <chr>                           <dbl>
    ## 1 141279 Reading progress score            2.6
    ## 2 141279 Writing progress score            2.3
    ## 3 141279 Maths progress score              2  
    ## 4 119910 Reading progress score            2.4
    ## 5 119910 Writing progress score            3.8
    ## 6 119910 Maths progress score             -1

## Intake

No cleaning required. We can simply rename without the `src_` prefix.

``` r
# Rename the variable
intake <- src_intake
```

## Calendar

No cleaning required. We can simply rename without the `src_` prefix.

``` r
# Rename the variable
calendar <- src_calendar
```

# Model data

The matrix below shows the fact and dimension tables that I intend to
create for this model and the relationships between them.
![bus-matrix-for-school-admissions-dashboard](images/bus-matrix.png)

To build out the dimensional model for this data, we need to review all
of the columns we intend to use, so that we can determine where they fit
in the model. The custom function `describe_df()` contained in the
`utils.R` file can help us with this.

``` r
# Create a vector of dfs to describe
data <- list("info" = info,
             "offers" = offers,
             "performance" = performance)

# Run describe_df() over each df
t_data <- lapply(data, describe_df)

# Bind each df into a single df
t_data <- bind_rows(t_data, .id = "source_table")
```

After exporting the new `t_data` dataframe to a spreadsheet, I created a
file named [star-schema](ref/star-schema.csv) which maps the raw source
data to the corresponding dimension and fact tables for the star schema
model.

``` r
# Read in star schema planning document
star_schema_path <- "https://drive.google.com/file/d/1wyopZkDzEQzPVMUrZBoiMNMGSdWxyk0i/view?usp=sharing"
star_schema <- read_csv_gdrive(star_schema_path)
```

## Dimensions

### Local Authority

The following columns are required for the local authority dimension
table:

``` r
# Which columns are needed for the local authority dimension?
star_schema %>% 
  filter(model_table == "dim_la") %>% 
  kable(caption = "Columns required for the local authority dimension")
```

| source_table | source_field | source_value_example | model_table |
|:-------------|:-------------|:---------------------|:------------|
| info         | la_code      | 201                  | dim_la      |
| info         | la_name      | City of London       | dim_la      |
| offers       | region_code  | E13000001            | dim_la      |
| offers       | region_name  | Inner London         | dim_la      |
| offers       | old_la_code  | 201                  | dim_la      |

Columns required for the local authority dimension

These columns can all come from the `offers` data frame.

``` r
# Build out the local authority dimension table
dim_la <- offers %>% 
  select(la_code = old_la_code,
         la_name,
         region_code,
         region_name) %>% 
  distinct()

# Check the result
head(dim_la)
```

    ## # A tibble: 6 × 4
    ##   la_code la_name                region_code region_name 
    ##     <dbl> <chr>                  <chr>       <chr>       
    ## 1     201 City of London         E13000001   Inner London
    ## 2     202 Camden                 E13000001   Inner London
    ## 3     203 Greenwich              E13000002   Outer London
    ## 4     204 Hackney                E13000001   Inner London
    ## 5     205 Hammersmith and Fulham E13000001   Inner London
    ## 6     206 Islington              E13000001   Inner London

[^1]: Columns which have been detected as logical, or boolean, always
    raise a small red flag for me. It can be an indicator that the
    column is empty of data (i.e. all values are `NA`). In this case, it
    looks like this is indeed what has happened, since running the
    `unique()` function over any of these columns always returns just a
    single value of `NA`. Therefore, I can safely exclude these columns
    from my analysis since they contain no useful data.
