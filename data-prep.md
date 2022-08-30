Source data preparation for the England school admissions dashboard
================
Clare Gibson

-   <a href="#setup" id="toc-setup">Setup</a>
-   <a href="#introduction" id="toc-introduction">Introduction</a>
    -   <a href="#source-data" id="toc-source-data">Source data</a>
    -   <a href="#custom-functions" id="toc-custom-functions">Custom
        functions</a>
-   <a href="#read-data" id="toc-read-data">Read data</a>
    -   <a href="#info" id="toc-info">Info</a>
    -   <a href="#offers" id="toc-offers">Offers</a>
        -   <a href="#by-local-authority" id="toc-by-local-authority">By Local
            Authority</a>
        -   <a href="#by-school" id="toc-by-school">By School</a>
    -   <a href="#performance" id="toc-performance">Performance</a>
    -   <a href="#phase" id="toc-phase">Phase</a>
    -   <a href="#calendar" id="toc-calendar">Calendar</a>
-   <a href="#clean-data" id="toc-clean-data">Clean data</a>
    -   <a href="#info-1" id="toc-info-1">Info</a>
    -   <a href="#offers-1" id="toc-offers-1">Offers</a>
        -   <a href="#by-local-authority-1" id="toc-by-local-authority-1">By Local
            Authority</a>
        -   <a href="#by-school-1" id="toc-by-school-1">By School</a>
    -   <a href="#performance-1" id="toc-performance-1">Performance</a>
    -   <a href="#phase-1" id="toc-phase-1">Phase</a>
    -   <a href="#calendar-1" id="toc-calendar-1">Calendar</a>
-   <a href="#model-data" id="toc-model-data">Model data</a>
    -   <a href="#dimensions" id="toc-dimensions">Dimensions</a>
        -   <a href="#local-authority" id="toc-local-authority">Local Authority</a>
        -   <a href="#school" id="toc-school">School</a>
        -   <a href="#phase-2" id="toc-phase-2">Phase</a>
        -   <a href="#calendar-2" id="toc-calendar-2">Calendar</a>
    -   <a href="#facts" id="toc-facts">Facts</a>
        -   <a href="#school-facts" id="toc-school-facts">School Facts</a>
        -   <a href="#school-year-facts" id="toc-school-year-facts">School Year
            Facts</a>
        -   <a href="#local-authority-year-facts"
            id="toc-local-authority-year-facts">Local Authority Year Facts</a>
        -   <a href="#all-facts" id="toc-all-facts">All Facts</a>
-   <a href="#export-data" id="toc-export-data">Export data</a>

# Setup

``` r
# Load packages
library(knitr)          # for Rmd options
library(tidyverse)      # for general wrangling
```

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──

    ## ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
    ## ✔ tibble  3.1.8     ✔ dplyr   1.0.9
    ## ✔ tidyr   1.2.0     ✔ stringr 1.4.0
    ## ✔ readr   2.1.2     ✔ forcats 0.5.1

    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

``` r
library(data.table)     # for transposing data frames
```

    ## 
    ## Attaching package: 'data.table'

    ## The following objects are masked from 'package:dplyr':
    ## 
    ##     between, first, last

    ## The following object is masked from 'package:purrr':
    ## 
    ##     transpose

``` r
library(janitor)        # for cleaning column headers
```

    ## 
    ## Attaching package: 'janitor'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     chisq.test, fisher.test

``` r
library(lubridate)      # for working with dates
```

    ## 
    ## Attaching package: 'lubridate'

    ## The following objects are masked from 'package:data.table':
    ## 
    ##     hour, isoweek, mday, minute, month, quarter, second, wday, week,
    ##     yday, year

    ## The following objects are masked from 'package:base':
    ## 
    ##     date, intersect, setdiff, union

``` r
library(googlesheets4)  # for reading in Google Sheets files

# Knitr Options
knitr::opts_chunk$set(
    echo = TRUE,
    fig.align = "center",
    message = FALSE,
    warning = FALSE
)
```

# Introduction

This notebook serves as the documented code to read and prepare data for
the England School Admissions Dashboard project
([github](https://github.com/clarelgibson/england-school-admissions) \|
[tableau](https://public.tableau.com/views/Schools_16505251102060/Home?:language=en-GB&:display_count=n&:origin=viz_share_link)).

The notebook begins by reading in the source data required for the
dashboards. It then works through the data wrangling steps necessary to
clean and prepare the data for transfer to Tableau.

## Source data

The full list of data sources, download links and retrieval steps can be
found in the [project
wiki](https://github.com/clarelgibson/england-school-admissions/wiki/Source-data).

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

This data frame has 36704 rows and 122 columns. The columns include some
identifiers for time, geography and school, some descriptive dimensions
about each school and some measures relating to the number of pupils of
different types. Each row represents a single school and the data
represents the latest available.

## Offers

### By Local Authority

This file contains data relating to the number of applications from
offers made to applicants for secondary and primary school places since
2014. The data is aggregated at the local authority level. This file
will be important as our single source of truth for local
authority-level measures (e.g. the number of preferences allowed on the
application form and the total number of applications received).

``` r
# Read in the source data for offla
src_offla_path <- "https://drive.google.com/file/d/12jONhUf3xSZdRbsUE_4tZRA014sIHO_D/view?usp=sharing"
src_offla <- read_csv_gdrive(src_offla_path)
```

### By School

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
Google Drive. Having read through the guidance notes for these files,
for the measures I want to compare, I can find these in all years from
2015/16 onwards.

``` r
# Read in the performance data files from 2015/16 onwards
# 2015-16 KS2
src_perf_1516ks2_path <- "https://drive.google.com/file/d/1migtFWfMUr8HJDeujfw6h7p2nNDVsbp4/view?usp=sharing"
src_perf_1516ks2 <- read_csv_gdrive(src_perf_1516ks2_path)

# 2015-16 KS4
src_perf_1516ks4_path <- "https://drive.google.com/file/d/1ijl88VsaaNdEC-N2O9hcRKc2sixcMyES/view?usp=sharing"
src_perf_1516ks4 <- read_csv_gdrive(src_perf_1516ks4_path)

# 2016-17 KS2
src_perf_1617ks2_path <- "https://drive.google.com/file/d/1B1LpH8RXlBoH7C9mJPL4FribTvIUzekq/view?usp=sharing"
src_perf_1617ks2 <- read_csv_gdrive(src_perf_1617ks2_path)

# 2016-17 KS4
src_perf_1617ks4_path <- "https://drive.google.com/file/d/1jOOmuKXDDp--cbESCz-j4Vp7ufVK3tPV/view?usp=sharing"
src_perf_1617ks4 <- read_csv_gdrive(src_perf_1617ks4_path)

# 2017-18 KS2
src_perf_1718ks2_path <- "https://drive.google.com/file/d/1zJxcJrsOr7nvWwb6Yyg48QoMgSp76e8V/view?usp=sharing"
src_perf_1718ks2 <- read_csv_gdrive(src_perf_1718ks2_path)

# 2017-18 KS4
src_perf_1718ks4_path <- "https://drive.google.com/file/d/1-5WDJ5dZulWmqQa8fX5eczA0Bo2m_jEc/view?usp=sharing"
src_perf_1718ks4 <- read_csv_gdrive(src_perf_1718ks4_path)

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

## Phase

This dataset includes details about the educational phase. Since there
are some schools in England that offer both primary and secondary
education, we will need a way to distinguish the phases in the fact
table.

``` r
# Read in the source data for phase
src_phase_path <- "https://drive.google.com/file/d/1I9Ibo-hG_VzXvzNgOVMi6PPYfSCuJzgG/view?usp=sharing"
src_phase <- read_csv_gdrive(src_phase_path)
```

This dataset has 2 rows and 4 columns and contains largely descriptive
information about the educational phases in England.

## Calendar

This dataset includes details about the academic years covered by the
data.

``` r
# Read in the source data for calendar
src_calendar_path <- "https://drive.google.com/file/d/1el2cL02nQidzN1pMcZ7AUb3h6wXuzN_E/view?usp=sharing"
src_calendar <- read_csv_gdrive(src_calendar_path)
```

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

The links I am interested in are the predecessor-successor links so that
I can keep schools grouped over time. I want the successor school to be
retained as the master school and all predecessors to be linked to the
master. If a school has no links then we simply list the master and
linked URNs as the same number. Therefore, I need to keep all of the
open schools as the master list and any predecessors need to be linked
to those master URNs.

``` r
# Set up the bridge table
brg_school <- src_info %>%
  # keep only currently open schools
  filter(grepl("^Open.*", establishment_status_name)) %>%
  # select required columns
  select(master_urn = urn,
         status = establishment_status_name,
         starts_with("link_")) %>% 
  # pivot the links
  pivot_longer(!c(master_urn, status),
               values_drop_na = TRUE) %>% 
  # drop the name column
  select(-name) %>% 
  # drop the non-useful link types
  mutate(value = case_when(
    value == "Does not have links" ~ value,
    grepl(".*Predecessor.*", value) ~ value,
    TRUE ~ "No useful links"
  )) %>% 
  # split the description column into useful data
  mutate(linked_urn = as.numeric(str_extract(value,"\\d+")),
         link_type = str_trim(str_extract(value,"\\D+"))) %>% 
  # drop the value column
  select(-value) %>% 
  # add self-urn
  mutate(self_urn = master_urn) %>% 
  pivot_longer(cols = c(linked_urn, self_urn),
               names_to = "urn_type",
               values_to = "linked_urn",
               values_drop_na = TRUE) %>% 
  # select required columns
  select(master_urn,
         linked_urn) %>% 
  distinct()
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

Now we can rename the columns more appropriately.

``` r
# Rename columns in info
info <- info %>% 
  rename(establishment_type = type_of_establishment_name,
         establishment_type_group = establishment_type_group_name,
         establishment_status = establishment_status_name,
         education_phase = phase_of_education_name,
         gender = gender_name,
         religious_character = religious_character_name,
         admissions_policy = admissions_policy_name,
         county = county_name,
         head_title = head_title_name,
         gor = gor_name,
         administrative_district = district_administrative_name,
         administrative_ward = administrative_ward_name,
         parliamentary_constituency = parliamentary_constituency_name,
         urban_rural_indicator = urban_rural_name,
         gss_la_code = gssla_code_name,
         msoa = msoa_name,
         lsoa = lsoa_name,
         ofsted_rating = ofsted_rating_name,
         number_of_fsm = fsm)
```

And convert the columns to the correct data types.

``` r
# Define the columns by type
info_date <- c("open_date",
               "close_date",
               "ofsted_last_insp",
               "last_changed_date")

# Correct the data types in info
info <- info %>% 
  mutate(across(all_of(info_date), dmy)) %>% 
  mutate(telephone_num = as.character(telephone_num),
         telephone_num = paste0("0", telephone_num))
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

    ##                         field unique_values
    ## 1                         urn         20188
    ## 2                     la_code           152
    ## 3                     la_name           152
    ## 4        establishment_number          2531
    ## 5          establishment_name         18522
    ## 6          establishment_type             9
    ## 7    establishment_type_group             3
    ## 8        establishment_status             2
    ## 9                   open_date           311
    ## 10                 close_date             8
    ## 11            education_phase             5
    ## 12          statutory_low_age            14
    ## 13         statutory_high_age            13
    ## 14                     gender             4
    ## 15        religious_character            29
    ## 16          admissions_policy             4
    ## 17            school_capacity          1488
    ## 18           number_of_pupils          1735
    ## 19             number_of_boys          1050
    ## 20            number_of_girls          1065
    ## 21             percentage_fsm           708
    ## 22           ofsted_last_insp          1487
    ## 23          last_changed_date           294
    ## 24                     street         13495
    ## 25                   locality          6591
    ## 26                   address3           991
    ## 27                       town          1427
    ## 28                     county            58
    ## 29                   postcode         19440
    ## 30             school_website         19603
    ## 31              telephone_num         20035
    ## 32                 head_title            19
    ## 33            head_first_name          2252
    ## 34             head_last_name          8079
    ## 35   head_preferred_job_title           152
    ## 36                        gor             9
    ## 37    administrative_district           309
    ## 38        administrative_ward          6249
    ## 39 parliamentary_constituency           533
    ## 40      urban_rural_indicator            10
    ## 41                gss_la_code           153
    ## 42                    easting         19149
    ## 43                   northing         19321
    ## 44                       msoa          6579
    ## 45                       lsoa         15565
    ## 46              ofsted_rating             6
    ## 47                  msoa_code          6579
    ## 48                  lsoa_code         15565
    ## 49              number_of_fsm           525

The `la_name` and `la_code` fields need to be checked to ensure they are
consistent. I refer to the [Office for National
Statistics](https://www.ons.gov.uk) [Local Authority Districts (December
2021) Names and Codes in the United
Kingdom](https://geoportal.statistics.gov.uk/documents/c4f647d8a4a648d7b4a1ebf057f8aaa3/about)
document for the latest reference data for these fields. This document
is included in the Google Drive [ref
folder](https://drive.google.com/drive/folders/1lsRDMfjSzabSF8HVJdF8ex5JM6rDRlSo?usp=sharing).

Let’s review the unique values of LA code and name in the `info` df.

``` r
# Review the unique values in la_name
info %>% 
  select(la_code, gss_la_code, la_name) %>% 
  distinct() %>% 
  arrange(la_name, la_code, gss_la_code)
```

    ## # A tibble: 184 × 3
    ##    la_code gss_la_code la_name                     
    ##      <dbl> <chr>       <chr>                       
    ##  1     301 E09000002   Barking and Dagenham        
    ##  2     302 E09000003   Barnet                      
    ##  3     302 X999999     Barnet                      
    ##  4     370 E08000016   Barnsley                    
    ##  5     800 E06000022   Bath and North East Somerset
    ##  6     800 X999999     Bath and North East Somerset
    ##  7     822 E06000055   Bedford                     
    ##  8     303 E09000004   Bexley                      
    ##  9     330 E08000025   Birmingham                  
    ## 10     330 X999999     Birmingham                  
    ## # … with 174 more rows
    ## # ℹ Use `print(n = ...)` to see more rows

We can see that some of the `gss-la-code` values here are wrong. It
looks like a value of `X999999` has been used where the true value could
not be determined when the source data was put together. We need to
replace this value with the correct value according to the reference
table.

``` r
# Correct the erroneous gss_la_code fields
info <- info %>% 
  group_by(la_code, la_name) %>% 
  mutate(gss_la_code = min(gss_la_code)) %>% 
  ungroup()

# Check the results
info_la <- info %>% 
  select(la_code, gss_la_code, la_name) %>% 
  distinct() %>% 
  arrange(la_name, la_code, gss_la_code)
```

Some columns have relatively few unique values, making these columns
clearly categorical. I’d like to review the values to ensure they are
consistent and well labelled.

``` r
# Review the unique values in establishment type
unique(info$establishment_type)
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
unique(info$establishment_type_group)
```

    ## [1] "Local authority maintained schools" "Academies"                         
    ## [3] "Free Schools"

All ok.

``` r
# Review the unique values in establishment status
unique(info$establishment_status)
```

    ## [1] "Open"                        "Open, but proposed to close"

All ok.

``` r
# Review the unique values in phase of education
unique(info$education_phase)
```

    ## [1] "Primary"                 "Secondary"              
    ## [3] "All-through"             "Middle deemed secondary"
    ## [5] "Middle deemed primary"

All ok.

``` r
# Review the unique values in gender
unique(info$gender)
```

    ## [1] "Mixed" "Girls" "Boys"  NA

Some missing values here. Let’s replace those with ‘Not reported’.

``` r
# Convert missing values in gender
info$gender[is.na(info$gender)] <- "Not reported"

# Check the results
unique(info$gender)
```

    ## [1] "Mixed"        "Girls"        "Boys"         "Not reported"

All ok.

``` r
# Review the unique values in religious character
unique(info$religious_character)
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
info$religious_character[is.na(info$religious_character)] <- 
  "Not reported"

# Check the results
unique(info$religious_character)
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
unique(info$admissions_policy)
```

    ## [1] "Not applicable" "Non-selective"  "Selective"      NA

Again let’s fix the missing values.

``` r
# Convert missing values in admissions policy
info$admissions_policy[is.na(info$admissions_policy)] <- 
  "Not reported"

# Check the results
unique(info$admissions_policy)
```

    ## [1] "Not applicable" "Non-selective"  "Selective"      "Not reported"

All ok.

``` r
# Review the unique values in ofsted rating
unique(info$ofsted_rating)
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
    mutate(ofsted_rating = case_when(
      grepl("Weakness", ofsted_rating) ~ "Inadequate",
      grepl("Measures", ofsted_rating) ~ "Inadequate",
      is.na(ofsted_rating) ~ "Not reported",
      TRUE ~ ofsted_rating
    ),
    ofsted_rating_score = case_when(
    grepl("Outstanding", ofsted_rating) ~ 1,
    grepl("Good", ofsted_rating) ~ 2,
    grepl("improvement", ofsted_rating) ~ 3,
    grepl("Inadequate", ofsted_rating) ~ 4
  ))

# Check results
unique(info$ofsted_rating)
```

    ## [1] "Outstanding"          "Good"                 "Requires improvement"
    ## [4] "Inadequate"           "Not reported"

``` r
unique(info$ofsted_rating_score)
```

    ## [1]  1  2  3  4 NA

## Offers

### By Local Authority

From the `src_offla` dataset we need to keep the identifiers for local
authority, year and phase as well as the numerical data. We should
filter the source data to keep only data at the `geographic_level` of
“Local authority”.

``` r
# Select the required columns from offla and correct data types
offla <- src_offla %>% 
  mutate(across(everything(), as.character)) %>% 
  filter(geographic_level == "Local authority") %>% 
  select(-c(nc_year_admission,
            time_identifier,
            geographic_level,
            country_code,
            country_name,
            one_of_the_three_preference_offers,
            ends_with("_percent"))) %>% 
  type_convert(na = "c")
```

Now we can rename the columns more appropriately.

``` r
# Rename the columns
offla <- offla %>% 
  rename(year = time_period,
         gss_la_code = new_la_code,
         la_code = old_la_code,
         phase = school_phase,
         number_of_preferences = no_of_preferences)
```

Now let’s review the entries for the local authority identifiers and
check which rows in `offla` are not present in `info_la` and therefore
need to be changed.

``` r
# Review the unique values of la_name
offla %>% 
  select(la_code, gss_la_code, la_name) %>% 
  distinct() %>% 
  arrange(la_name, la_code) %>% 
  anti_join(info_la)
```

    ## # A tibble: 7 × 3
    ##   la_code gss_la_code la_name         
    ##     <dbl> <chr>       <chr>           
    ## 1     837 E06000028   Bournemouth     
    ## 2     825 E10000002   Buckinghamshire 
    ## 3     835 E10000009   Dorset          
    ## 4     390 E08000020   Gateshead       
    ## 5     928 E10000021   Northamptonshire
    ## 6     929 E06000048   Northumberland  
    ## 7     836 E06000029   Poole

Let’s make the necessary replacements.

``` r
# Recode the LA identifier fields in offla
offla <- offla %>% 
  mutate(
    la_code = case_when(
      la_code == 837 ~ 839,
      la_code == 835 ~ 838,
      la_code == 928 ~ 940,
      la_code == 836 ~ 839,
      TRUE ~ la_code
    ),
    gss_la_code = case_when(
      gss_la_code == "E06000028" ~ "E06000058",
      gss_la_code == "E10000002" ~ "E06000060",
      gss_la_code == "E10000009" ~ "E06000059",
      gss_la_code == "E08000020" ~ "E08000037",
      gss_la_code == "E10000021" ~ "E06000061",
      gss_la_code == "E06000048" ~ "E06000057",
      gss_la_code == "E06000029" ~ "E06000058",
      TRUE ~ gss_la_code
    ),
    la_name = case_when(
      la_name == "Bournemouth" ~ "Bournemouth, Christchurch and Poole",
      la_name == "Northamptonshire" ~ "North Northamptonshire",
      la_name == "Poole" ~ "Bournemouth, Christchurch and Poole",
      TRUE ~ la_name
    )
  )

# Extra rows because Northamptonshire is now two distinct regions
offla_extra <- tibble(
  year = c(202122, 202122, 202021, 202021, 201920, 201920, 201819, 201819,
           201718, 201718, 201617, 201617, 201516, 201516, 201415, 201415),
  region_code = rep("E12000004", 16),
  region_name = rep("East Midlands", 16),
  gss_la_code = rep("E06000062", 16),
  la_code = rep(941, 16),
  la_name = rep("West Northamptonshire", 16),
  phase = rep(c("Primary", "Secondary"), 8),
  number_of_preferences = rep(3,16)
)

# Bind extra rows on to prefs
offla <- offla %>% 
  bind_rows(offla_extra) %>% 
  group_by_at(vars(-number_of_preferences)) %>% 
  slice_max(number_of_preferences) %>% 
  ungroup() %>% 
  distinct()

# Check the results
offla_la <- offla %>% 
  select(la_code, gss_la_code, la_name) %>% 
  distinct() %>% 
  arrange(la_name, la_code) 

offla_la %>% 
  anti_join(info_la)
```

    ## # A tibble: 0 × 3
    ## # … with 3 variables: la_code <dbl>, gss_la_code <chr>, la_name <chr>
    ## # ℹ Use `colnames()` to see all variable names

``` r
# Review the unique values of year
unique(offla$year)
```

    ## [1] 201415 201516 201617 201718 201819 201920 202021 202122 202223

These values should be recoded to match the `year_key` in the calendar
table. We need to extract the academic start year, which is the first 4
digits of the value.

``` r
# Recode the values in year
offla$year <- as.numeric(str_extract(offla$year, "^\\d{4}"))

# Check the results
unique(offla$year)
```

    ## [1] 2014 2015 2016 2017 2018 2019 2020 2021 2022

### By School

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
         new_la_code,
         la_name,
         total_number_places_offered:offers_to_applicants_from_another_la,
         denomination,
         school_urn,
         entry_year)
```

Next we can rename the columns more appropriately.

``` r
# Rename the columns
offers <- offers %>% 
  rename(year = time_period,
         la_code = old_la_code,
         gss_la_code = new_la_code,
         religious_denomination = denomination,
         urn = school_urn,
         phase = entry_year)
```

Next we can filter out any records where the `school_urn` is `n/a` and
convert the remaining values to numeric.

``` r
# Remove entries with null URN
offers <- offers %>% 
  filter(urn != "n/a") %>% 
  mutate(urn = as.numeric(urn))
```

Now we can check and correct the data types.

``` r
# Define cols to be converted
offers_num <- c("proportion_1stprefs_v_1stprefoffers",
                "proportion_1stprefs_v_totaloffers",
                "offers_to_applicants_from_another_la")

# Correct data types in offers
offers <- offers %>% 
  mutate(across(all_of(offers_num), as.numeric))
```

Let’s now review the selected column headings in this dataset and the
number of unique values in each column.

``` r
# Print a list of the column headings in the offers df
offers %>% 
  summarise_all(n_distinct) %>% 
  transpose(keep.names = "field") %>% 
  rename(unique_values = V1)
```

    ##                                   field unique_values
    ## 1                                  year             9
    ## 2                           region_code            10
    ## 3                           region_name            10
    ## 4                               la_code           155
    ## 5                           gss_la_code           155
    ## 6                               la_name           157
    ## 7           total_number_places_offered           425
    ## 8               number_preferred_offers           425
    ## 9          number_1st_preference_offers           403
    ## 10         number_2nd_preference_offers           108
    ## 11         number_3rd_preference_offers            61
    ## 12    times_put_as_any_preferred_school          1599
    ## 13          times_put_as_1st_preference           593
    ## 14          times_put_as_2nd_preference           539
    ## 15          times_put_as_3rd_preference           438
    ## 16  proportion_1stprefs_v_1stprefoffers          9826
    ## 17    proportion_1stprefs_v_totaloffers         15429
    ## 18     all_applications_from_another_la           760
    ## 19 offers_to_applicants_from_another_la           197
    ## 20               religious_denomination             3
    ## 21                                  urn         24404
    ## 22                                phase             3

Let’s review the categorical values to ensure they are consistent and
well labelled.

``` r
# Review the unique values of la_name
offers %>% 
  select(la_code, gss_la_code, la_name) %>% 
  distinct() %>% 
  arrange(la_name, la_code)
```

    ## # A tibble: 160 × 3
    ##    la_code gss_la_code la_name                     
    ##      <dbl> <chr>       <chr>                       
    ##  1     301 E09000002   Barking and Dagenham        
    ##  2     302 E09000003   Barnet                      
    ##  3     370 E08000016   Barnsley                    
    ##  4     800 E06000022   Bath and North East Somerset
    ##  5     822 E06000055   Bedford                     
    ##  6     303 E09000004   Bexley                      
    ##  7     330 E08000025   Birmingham                  
    ##  8     889 E06000008   Blackburn with Darwen       
    ##  9     890 E06000009   Blackpool                   
    ## 10     350 E08000001   Bolton                      
    ## # … with 150 more rows
    ## # ℹ Use `print(n = ...)` to see more rows

Some of these entries need to be corrected to match the values in
`info`.

``` r
offers_la <- offers %>% 
  select(urn,
         year,
         la_code,
         gss_la_code,
         la_name,
         region_code,
         region_name) %>% 
  distinct() %>% 
  arrange(urn,
          -year,
          la_code,
          la_name) %>% 
  group_by(urn) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>%
  inner_join(brg_school,
            by = c("urn" = "linked_urn")) %>% 
  left_join(select(info,
                   master_urn = urn,
                   master_la_code = la_code,
                   master_gss_la_code = gss_la_code,
                   master_la_name = la_name)) %>% 
  mutate(la_code = coalesce(master_la_code, la_code),
         gss_la_code = coalesce(master_gss_la_code, gss_la_code),
         la_name = coalesce(master_la_name, la_name)) %>% 
  select(urn,
         master_urn,
         la_code,
         gss_la_code,
         la_name,
         region_code,
         region_name) %>% 
  distinct()
```

``` r
offers <- offers %>% 
  select(-c(region_code,
            region_name,
            la_code,
            gss_la_code,
            la_name)) %>% 
  inner_join(offers_la)

# Check the results
offers_la <- offers %>% 
  select(la_code, gss_la_code, la_name) %>% 
  distinct() %>% 
  arrange(la_name, la_code)
```

``` r
# Review the unique values of year
unique(offers$year)
```

    ## [1] 202223 202122 202021 201920 201819 201718 201617 201516 201415

These values should be recoded to match the `year_key` in the calendar
table. We need to extract the academic start year, which is the first 4
digits of the value.

``` r
# Recode the values in year
offers$year <- as.numeric(str_extract(offers$year, "^\\d{4}"))

# Check the results
unique(offers$year)
```

    ## [1] 2022 2021 2020 2019 2018 2017 2016 2015 2014

All ok.

``` r
# Review the unique values in denomination
unique(offers$religious_denomination)
```

    ## [1] "Faith"                  "No religious character" "n/a"

There are some values of `n/a` here. Let’s see what those are.

``` r
# Review the n/a values in denomination
offers %>% 
  filter(religious_denomination == "n/a") %>% 
  head()
```

    ## # A tibble: 6 × 23
    ##    year total_…¹ numbe…² numbe…³ numbe…⁴ numbe…⁵ times…⁶ times…⁷ times…⁸ times…⁹
    ##   <dbl>    <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
    ## 1  2022       61      61      61       0       0     132      98      20      14
    ## 2  2022       30      30      29       1       0     101      44      47      10
    ## 3  2022       30      30      29       1       0      79      38      32       9
    ## 4  2022       35      34      32       2       0      68      32      20      16
    ## 5  2022       59      59      58       1       0     137      68      57      12
    ## 6  2022       30      30      30       0       0     112      36      49      26
    ## # … with 13 more variables: proportion_1stprefs_v_1stprefoffers <dbl>,
    ## #   proportion_1stprefs_v_totaloffers <dbl>,
    ## #   all_applications_from_another_la <dbl>,
    ## #   offers_to_applicants_from_another_la <dbl>, religious_denomination <chr>,
    ## #   urn <dbl>, phase <chr>, master_urn <dbl>, la_code <dbl>, gss_la_code <chr>,
    ## #   la_name <chr>, region_code <chr>, region_name <chr>, and abbreviated
    ## #   variable names ¹​total_number_places_offered, ²​number_preferred_offers, …
    ## # ℹ Use `colnames()` to see all variable names

I guess this must be for schools who did not report their denomination.
Let’s replace `n/a` with `Not reported`.

``` r
# Replace n/a
offers$religious_denomination[offers$religious_denomination == "n/a"] <- "Not reported"

# Check the results
unique(offers$religious_denomination)
```

    ## [1] "Faith"                  "No religious character" "Not reported"

All ok.

``` r
# Review the unique values in phase
unique(offers$phase)
```

    ## [1] "R" "7" "9"

Here we need to make some changes so that this column can be used to
refer to the educational phase of the data. We need to recode these
values to match the phases in our phase table (primary or secondary).
The value `R` corresponds to primary and `7` and `9` both correspond to
secondary.

``` r
# Recode the phase values
offers <- offers %>% 
  mutate(phase = case_when(
    phase == "R" ~ "Primary",
    phase %in% c("7", "9") ~ "Secondary",
    TRUE ~ phase
  ))

# Check the results
unique(offers$phase)
```

    ## [1] "Primary"   "Secondary"

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
# Bind rows from all years
perf_ks2 <- bind_rows(
  "2015" = src_perf_1516ks2,
  "2016" = src_perf_1617ks2,
  "2017" = src_perf_1718ks2,
  "2018" = src_perf_1819ks2,
  .id = "year"
) %>% 
  # Filter to rectype == 1
  filter(rectype == 1) %>% 
  # Select the required columns
  select(year,
         urn,
         readprog,
         writprog,
         matprog) %>% 
  # convert to numeric (any strings can be converted to NA)
  mutate(across(everything(), as.numeric)) %>% 
  # add a column for phase
  mutate(phase = "Primary")

# View the head
head(perf_ks2)
```

    ## # A tibble: 6 × 6
    ##    year    urn readprog writprog matprog phase  
    ##   <dbl>  <dbl>    <dbl>    <dbl>   <dbl> <chr>  
    ## 1  2015 100000      2.7      2.2     3   Primary
    ## 2  2015 100028      2.6      4       3.5 Primary
    ## 3  2015 100029      2.3      1.4     0.3 Primary
    ## 4  2015 130342      3.4      2.2     2.3 Primary
    ## 5  2015 100013      2        1.4     6   Primary
    ## 6  2015 100027      3.5      0.4     2.7 Primary

``` r
# Bind rows from all years
perf_ks4 <- bind_rows(
  "2015" = select(src_perf_1516ks4, rectype, urn, p8mea, att8scr),
  "2016" = select(src_perf_1617ks4, rectype, urn, p8mea, att8scr),
  "2017" = select(src_perf_1718ks4, rectype, urn, p8mea, att8scr),
  "2018" = select(src_perf_1819ks4, rectype, urn, p8mea, att8scr),
  .id = "year"
) %>% 
  # Filter to rectype == 1
  filter(rectype == 1) %>% 
  # Select the required columns
  select(year,
         urn,
         p8mea,
         att8scr) %>% 
  # convert to numeric (any strings can be converted to NA)
  mutate(across(everything(), as.numeric)) %>% 
  # add the phase
  mutate(phase = "Secondary")

# View the head
head(perf_ks4)
```

    ## # A tibble: 6 × 5
    ##    year    urn p8mea att8scr phase    
    ##   <dbl>  <dbl> <dbl>   <dbl> <chr>    
    ## 1  2015 100003 NA       42.1 Secondary
    ## 2  2015 100001 NA       32.2 Secondary
    ## 3  2015 100053 -0.26    50.1 Secondary
    ## 4  2015 100054  0.31    60.1 Secondary
    ## 5  2015 137333 NA        3.4 Secondary
    ## 6  2015 100084 NA       49.4 Secondary

Now we can join the KS2 and KS4 data together and recode the progress
measure names.

``` r
# Combine two data frames
performance <- perf_ks2 %>% 
  full_join(perf_ks4) %>% 
  rename(reading_progress = readprog,
         writing_progress = writprog,
         maths_progress = matprog,
         progress_8 = p8mea,
         attainment_8 = att8scr)

# View the head
head(performance)
```

    ## # A tibble: 6 × 8
    ##    year    urn reading_progress writing_progress maths_p…¹ phase progr…² attai…³
    ##   <dbl>  <dbl>            <dbl>            <dbl>     <dbl> <chr>   <dbl>   <dbl>
    ## 1  2015 100000              2.7              2.2       3   Prim…      NA      NA
    ## 2  2015 100028              2.6              4         3.5 Prim…      NA      NA
    ## 3  2015 100029              2.3              1.4       0.3 Prim…      NA      NA
    ## 4  2015 130342              3.4              2.2       2.3 Prim…      NA      NA
    ## 5  2015 100013              2                1.4       6   Prim…      NA      NA
    ## 6  2015 100027              3.5              0.4       2.7 Prim…      NA      NA
    ## # … with abbreviated variable names ¹​maths_progress, ²​progress_8, ³​attainment_8

## Phase

No cleaning required. We can simply rename without the `src_` prefix.

``` r
# Rename the variable
phase <- src_phase
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

| Fact/Dimension   | dim_la | dim_school | dim_calendar | dim_phase |
|------------------|:------:|:----------:|:------------:|:---------:|
| fact_la_year     |   x    |            |      x       |     x     |
| fact_school_year |   x    |     x      |      x       |     x     |
| fact_school      |   x    |     x      |              |           |

Fact and dimension tables

To build out the dimensional model for this data, we need to review all
of the columns we intend to use, so that we can determine where they fit
in the model. The custom function `describe_df()` contained in the
`utils.R` file can help us with this.

``` r
# Create a vector of dfs to describe
data <- list("info" = info,
             "offers_by_la" = offla,
             "offers" = offers,
             "performance" = performance,
             "phase" = phase,
             "calendar" = calendar)

# Run describe_df() over each df
t_data <- lapply(data, describe_df)

# Bind each df into a single df
t_data <- bind_rows(t_data, .id = "source_table")
```

After exporting the new `t_data` dataframe to a spreadsheet, I created a
file named
[star-schema](https://docs.google.com/spreadsheets/d/1rrlhlvFrnPpTQtn2YzWyJZzwlm-2wWAzDiEv6fKBoHU/edit?usp=sharing)
which maps the raw source data to the corresponding dimension and fact
tables for the star schema model.

``` r
# Read in star schema planning document
star_schema_path <- "https://docs.google.com/spreadsheets/d/1rrlhlvFrnPpTQtn2YzWyJZzwlm-2wWAzDiEv6fKBoHU/edit?usp=sharing"
star_schema <- read_sheet(star_schema_path,
                          col_types = "c")
```

## Dimensions

### Local Authority

The following columns are required for the local authority dimension
table:

``` r
# Which columns are needed for the local authority dimension?
star_schema %>% 
  filter(model_table == "dim_la") %>% 
  kable()
```

| source_table | source_field | source_value_example | model_table |
|:-------------|:-------------|:---------------------|:------------|
| info         | la_code      | 891                  | dim_la      |
| info         | la_name      | Nottinghamshire      | dim_la      |
| info         | gss_la_code  | E10000024            | dim_la      |
| offers_by_la | region_code  | E12000001            | dim_la      |
| offers_by_la | region_name  | North East           | dim_la      |
| offers_by_la | gss_la_code  | E06000004            | dim_la      |
| offers_by_la | la_code      | 808                  | dim_la      |
| offers_by_la | la_name      | Stockton-on-Tees     | dim_la      |
| offers       | region_code  | E13000001            | dim_la      |
| offers       | region_name  | Inner London         | dim_la      |
| offers       | la_code      | 201                  | dim_la      |
| offers       | la_name      | City of London       | dim_la      |
| offers       | gss_la_code  | E09000001            | dim_la      |

These columns can all come from the `offers` and `info` data frames.

``` r
# Build out the local authority dimension table
dim_la <- offers %>% 
  select(la_code,
         gss_la_code,
         la_name, 
         region_code,
         region_name) %>% 
  distinct() %>% 
  full_join(info_la) %>% 
  mutate(region_code = case_when(la_code == 420 ~ "E12000009",
                                 TRUE ~ region_code),
         region_name = case_when(la_code == 420 ~ "South West",
                                 TRUE ~ region_name))

# Check the result
head(dim_la)
```

    ## # A tibble: 6 × 5
    ##   la_code gss_la_code la_name                region_code region_name 
    ##     <dbl> <chr>       <chr>                  <chr>       <chr>       
    ## 1     201 E09000001   City of London         E13000001   Inner London
    ## 2     202 E09000007   Camden                 E13000001   Inner London
    ## 3     203 E09000011   Greenwich              E13000002   Outer London
    ## 4     204 E09000012   Hackney                E13000001   Inner London
    ## 5     205 E09000013   Hammersmith and Fulham E13000001   Inner London
    ## 6     206 E09000019   Islington              E13000001   Inner London

Let’s assign a unique key to each record, and add a record for the
`null` case, which we’ll call `Not reported`.

``` r
# Specify the null value
dim_la_null <- tibble(la_key = 0,
                      la_code = 0,
                      la_name = "Not reported",
                      gss_la_code = "Not reported",
                      region_code = "Not reported",
                      region_name = "Not reported")

# Assign a key and row for null values
dim_la <- dim_la %>% 
  rowid_to_column(var = "la_key") %>% 
  bind_rows(dim_la_null) %>% 
  arrange(la_key)
```

### School

The following fields are required for the school dimension.

``` r
# Which columns are needed for the school dimension?
star_schema %>% 
  filter(model_table == "dim_school") %>% 
  kable()
```

| source_table | source_field               | source_value_example                  | model_table |
|:-------------|:---------------------------|:--------------------------------------|:------------|
| info         | urn                        | 131560                                | dim_school  |
| info         | establishment_number       | 3793                                  | dim_school  |
| info         | establishment_name         | Blidworth Oaks Primary School         | dim_school  |
| info         | establishment_type         | Community school                      | dim_school  |
| info         | establishment_type_group   | Local authority maintained schools    | dim_school  |
| info         | establishment_status       | Open, but proposed to close           | dim_school  |
| info         | open_date                  | 13604                                 | dim_school  |
| info         | close_date                 | 19204                                 | dim_school  |
| info         | education_phase            | Primary                               | dim_school  |
| info         | statutory_low_age          | 2                                     | dim_school  |
| info         | statutory_high_age         | 11                                    | dim_school  |
| info         | gender                     | Mixed                                 | dim_school  |
| info         | religious_character        | Does not apply                        | dim_school  |
| info         | admissions_policy          | Not applicable                        | dim_school  |
| info         | ofsted_last_insp           | 17344                                 | dim_school  |
| info         | last_changed_date          | 19166                                 | dim_school  |
| info         | street                     | Haywood Avenue                        | dim_school  |
| info         | locality                   | Blidworth                             | dim_school  |
| info         | address3                   | Blidworth Oaks Primary School         | dim_school  |
| info         | town                       | Mansfield                             | dim_school  |
| info         | county                     | Nottinghamshire                       | dim_school  |
| info         | postcode                   | NG21 0RE                              | dim_school  |
| info         | school_website             | www.blidworthoaks.co.uk               | dim_school  |
| info         | telephone_num              | 1623792348                            | dim_school  |
| info         | head_title                 | Mr                                    | dim_school  |
| info         | head_first_name            | Shaun                                 | dim_school  |
| info         | head_last_name             | Walker                                | dim_school  |
| info         | head_preferred_job_title   | Headteacher                           | dim_school  |
| info         | gor                        | East Midlands                         | dim_school  |
| info         | administrative_district    | Newark and Sherwood                   | dim_school  |
| info         | administrative_ward        | Rainworth South & Blidworth           | dim_school  |
| info         | parliamentary_constituency | Sherwood                              | dim_school  |
| info         | urban_rural_indicator      | (England/Wales) Rural town and fringe | dim_school  |
| info         | easting                    | 459277                                | dim_school  |
| info         | northing                   | 356444                                | dim_school  |
| info         | msoa                       | Newark and Sherwood 006               | dim_school  |
| info         | lsoa                       | Newark and Sherwood 006B              | dim_school  |
| info         | ofsted_rating              | Good                                  | dim_school  |
| info         | msoa_code                  | E02005898                             | dim_school  |
| info         | lsoa_code                  | E01028298                             | dim_school  |
| offers       | religious_denomination     | Faith                                 | dim_school  |
| offers       | urn                        | 100000                                | dim_school  |
| performance  | urn                        | 137157                                | dim_school  |

These columns can all be found in the `info` and `offers` tables. We
need to ensure that we include only the URNs in the `master_urn` column
of our bridge table.

``` r
# Define columns to include
dim_school_cols_info <- star_schema %>% 
  filter(model_table == "dim_school",
         source_table == "info") %>% 
  pull(source_field)

dim_school_cols_offers <- star_schema %>% 
  filter(model_table == "dim_school",
         source_table == "offers") %>% 
  pull(source_field)

# Define which rows from offers should be joined (as there can be more than
# one record per URN)
dim_school_offers <- offers %>% 
  select(all_of(dim_school_cols_offers),
         year,
         phase) %>% 
  distinct() %>% 
  group_by(urn) %>% 
  slice_max(year) %>%
  slice_max(phase) %>% 
  ungroup()

# Build out the school dimension table
dim_school <- brg_school %>% 
  select(urn = master_urn) %>% 
  distinct() %>% 
  left_join(select(info,
                   all_of(dim_school_cols_info))) %>% 
  left_join(select(dim_school_offers,
                   all_of(dim_school_cols_offers)))
```

Let’s assign a unique key to each record, and add a record for the
`null` case, which we’ll call `Not reported`.

``` r
# Specify the null value
dim_school_null <- tibble(school_key = 0,
                          urn = 0,
                          establishment_number = 0,
                          establishment_name = "Not reported",
                          establishment_type = "Not reported",
                          establishment_type_group = "Not reported",
                          establishment_status = "Not reported",
                          open_date = NA,
                          close_date = NA,
                          education_phase = "Not reported",
                          statutory_low_age = NA,
                          statutory_high_age = NA,
                          gender = "Not reported",
                          religious_character = "Not reported",
                          admissions_policy = "Not reported",
                          ofsted_last_insp = NA,
                          last_changed_date = NA,
                          gor = "Not reported",
                          administrative_district = "Not reported",
                          administrative_ward = "Not reported",
                          parliamentary_constituency = "Not reported",
                          urban_rural_indicator = "Not reported",
                          msoa_code = "Not reported",
                          lsoa_code = "Not reported",
                          ofsted_rating = "Not reported",
                          religious_denomination = "Not reported")

# Assign a key and row for null values
dim_school <- dim_school %>% 
  rowid_to_column(var = "school_key") %>% 
  bind_rows(dim_school_null) %>% 
  arrange(school_key)
```

### Phase

The following columns are needed for the phase dimension:

``` r
# Which columns are needed for the phase dimension?
star_schema %>% 
  filter(model_table == "dim_phase") %>% 
  kable()
```

| source_table | source_field          | source_value_example | model_table |
|:-------------|:----------------------|:---------------------|:------------|
| offers_by_la | phase                 | Primary              | dim_phase   |
| offers       | phase                 | Primary              | dim_phase   |
| performance  | phase                 | Primary              | dim_phase   |
| phase        | phase_key             | 1                    | dim_phase   |
| phase        | phase_name            | Primary              | dim_phase   |
| phase        | phase_intake_year     | Reception            | dim_phase   |
| phase        | performance_key_stage | KS2                  | dim_phase   |

For this table we just need to use the `phase` data frame as it already
exists.

``` r
# Build the dim_phase table
dim_phase <- phase
```

### Calendar

For this table we just need to use the `calendar` data frame as it
already exists.

``` r
# Build the calendar dimension
dim_calendar <- calendar
```

## Facts

### School Facts

To build the school facts table we will need to following columns, plus
keys for all dimensions:

``` r
# Which columns are needed for the school fact table?
star_schema %>% 
  filter(model_table == "fact_school") %>% 
  kable()
```

| source_table | source_field        | source_value_example | model_table |
|:-------------|:--------------------|:---------------------|:------------|
| info         | school_capacity     | 315                  | fact_school |
| info         | number_of_pupils    | 382                  | fact_school |
| info         | number_of_boys      | 208                  | fact_school |
| info         | number_of_girls     | 174                  | fact_school |
| info         | percentage_fsm      | 30.6                 | fact_school |
| info         | number_of_fsm       | 102                  | fact_school |
| info         | ofsted_rating_score | 2                    | fact_school |

These fields can all come from the `info` table.

``` r
# Define columns to include
fct_school_cols <- star_schema %>% 
  filter(model_table == "fact_school",
         source_table == "info") %>% 
  pull(source_field)

# Build out the school fact table
fct_school <- info %>% 
  # select columns
  select(linked_urn = urn,
         la_code,
         la_name,
         all_of(fct_school_cols)) %>% 
  # join school key (via bridge)
  left_join(brg_school) %>% 
  left_join(select(dim_school,
                   master_urn = urn,
                   school_key)) %>% 
  # join la key
  left_join(select(dim_la,
                   la_code,
                   la_name,
                   la_key)) %>% 
  # select final columns
  select(school_key,
         la_key,
         all_of(fct_school_cols)) %>% 
  # deal with duplicates
  group_by(school_key,
           la_key) %>% 
  mutate(fct_school_count = n()) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  ungroup() %>% 
  mutate(fct_school_flg = if_else(fct_school_count == 1,
                                  "Actual",
                                  "Average"))
```

### School Year Facts

To build the school year facts table we need the following columns:

``` r
# Which columns are needed for the school year fact table?
star_schema %>% 
  filter(model_table == "fact_school_year") %>% 
  kable()
```

| source_table | source_field                         | source_value_example | model_table      |
|:-------------|:-------------------------------------|:---------------------|:-----------------|
| offers       | total_number_places_offered          | 30                   | fact_school_year |
| offers       | number_preferred_offers              | 30                   | fact_school_year |
| offers       | number_1st_preference_offers         | 30                   | fact_school_year |
| offers       | number_2nd_preference_offers         | 0                    | fact_school_year |
| offers       | number_3rd_preference_offers         | 0                    | fact_school_year |
| offers       | times_put_as_any_preferred_school    | 81                   | fact_school_year |
| offers       | times_put_as_1st_preference          | 42                   | fact_school_year |
| offers       | times_put_as_2nd_preference          | 16                   | fact_school_year |
| offers       | times_put_as_3rd_preference          | 6                    | fact_school_year |
| offers       | proportion_1stprefs_v\_1stprefoffers | 1.4                  | fact_school_year |
| offers       | proportion_1stprefs_v\_totaloffers   | 1.4                  | fact_school_year |
| offers       | all_applications_from_another_la     | 62                   | fact_school_year |
| offers       | offers_to_applicants_from_another_la | 16                   | fact_school_year |
| performance  | reading_progress                     | 2.8                  | fact_school_year |
| performance  | writing_progress                     | 4                    | fact_school_year |
| performance  | maths_progress                       | 0.5                  | fact_school_year |
| performance  | progress_8                           | 0.47                 | fact_school_year |
| performance  | attainment_8                         | 65                   | fact_school_year |

These columns all come from `offers`, `prefs` and `performance`.

``` r
# Define columns to include
fct_school_year_cols_offers <- star_schema %>% 
  filter(model_table == "fact_school_year",
         source_table == "offers") %>% 
  pull(source_field)

fct_school_year_cols_perf <- star_schema %>% 
  filter(model_table == "fact_school_year",
         source_table == "performance") %>% 
  pull(source_field)

# Build out the school year fact table
fct_school_year <- offers %>% 
  select(linked_urn = urn,
         la_code,
         la_name,
         year,
         phase_name = phase,
         all_of(fct_school_year_cols_offers)) %>% 
  left_join(select(performance,
                   linked_urn = urn,
                   year,
                   phase_name = phase,
                   all_of(fct_school_year_cols_perf))) %>% 
  # join school key (via bridge)
  inner_join(brg_school) %>% 
  left_join(select(dim_school,
                   master_urn = urn,
                   school_key)) %>% 
  # join la key
  left_join(select(dim_la,
                   la_code,
                   la_name,
                   la_key)) %>% 
  # join phase key
  left_join(select(dim_phase,
                   phase_name,
                   phase_key)) %>% 
  # select final columns
  select(school_key,
         la_key,
         year_key = year,
         phase_key,
         all_of(fct_school_year_cols_offers),
         all_of(fct_school_year_cols_perf)) %>% 
  # deal with duplicates
  group_by(school_key,
           la_key,
           phase_key,
           year_key) %>% 
  mutate(fct_school_year_count = n()) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  ungroup() %>% 
  mutate(fct_school_year_flg = if_else(fct_school_year_count == 1,
                                       "Actual",
                                       "Average"))
```

### Local Authority Year Facts

To build the LA year facts table we need the following columns:

``` r
# Which columns are needed for the LA year fact table?
star_schema %>% 
  filter(model_table == "fact_la_year") %>% 
  kable()
```

| source_table | source_field                | source_value_example | model_table  |
|:-------------|:----------------------------|:---------------------|:-------------|
| offers_by_la | admission_numbers           | 2626                 | fact_la_year |
| offers_by_la | applications_received       | 2386                 | fact_la_year |
| offers_by_la | online_applications         | 1638                 | fact_la_year |
| offers_by_la | number_of_preferences       | 3                    | fact_la_year |
| offers_by_la | first_preference_offers     | 2233                 | fact_la_year |
| offers_by_la | second_preference_offers    | 97                   | fact_la_year |
| offers_by_la | third_preference_offers     | 25                   | fact_la_year |
| offers_by_la | preferred_school_offer      | 2355                 | fact_la_year |
| offers_by_la | non_preferred_offer         | 0                    | fact_la_year |
| offers_by_la | no_offer                    | 31                   | fact_la_year |
| offers_by_la | schools_in_la_offer         | 2333                 | fact_la_year |
| offers_by_la | schools_in_another_la_offer | 22                   | fact_la_year |
| offers_by_la | offers_to_nonapplicants     | 0                    | fact_la_year |

These columns all come from `offers_by_la`.

``` r
# Define columns to include
fct_la_year_cols <- star_schema %>% 
  filter(model_table == "fact_la_year") %>% 
  pull(source_field)

# Build out the LA year fact table
fct_la_year <- offla %>% 
  select(la_code,
         la_name,
         year,
         phase_name = phase,
         all_of(fct_la_year_cols)) %>% 
  # join la key
  left_join(select(dim_la,
                   la_code,
                   la_name,
                   la_key)) %>% 
  # join phase key
  left_join(select(dim_phase,
                   phase_name,
                   phase_key)) %>% 
  # select final columns
  select(la_key,
         year_key = year,
         phase_key,
         all_of(fct_la_year_cols)) %>% 
  # deal with duplicates
  group_by(la_key,
           phase_key,
           year_key) %>% 
  mutate(fct_la_year_count = n()) %>% 
  summarise_all(mean, na.rm = TRUE) %>% 
  ungroup() %>% 
  mutate(fct_la_year_flg = if_else(fct_la_year_count == 1,
                                   "Actual",
                                   "Average"))
```

### All Facts

Finally we can join together the three individual fact tables to create
a single fact table which will be more useful for Tableau.

``` r
# Build a table for all facts
fct_all <- fct_school_year %>% 
  left_join(fct_school) %>% 
  left_join(fct_la_year)
```

# Export data

The final tables for the data model need to be saved as Rdata files, so
that they can be accessed by Tableau.

``` r
# Define folder location for save
export_path <- "data-out/"

# Save objects
save(dim_la, file = paste0(export_path,
                           "dim_la.Rda"))

save(dim_school, file = paste0(export_path,
                               "dim_school.Rda"))

save(dim_calendar, file = paste0(export_path,
                                 "dim_calendar.Rda"))

save(dim_phase, file = paste0(export_path,
                              "dim_phase.Rda"))

save(fct_school, file = paste0(export_path,
                               "fct_school.Rda"))

save(fct_school_year, file = paste0(export_path,
                                    "fct_school_year.Rda"))

save(fct_la_year, file = paste0(export_path,
                                "fct_la_year.Rda"))

save(fct_all, file = paste0(export_path,
                            "fct_all.Rda"))
```
