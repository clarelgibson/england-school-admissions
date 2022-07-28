Source data preparation for the England school admissions dashboard
================
Clare Gibson

-   <a href="#introduction" id="toc-introduction">Introduction</a>
    -   <a href="#source-data" id="toc-source-data">Source data</a>
    -   <a href="#required-packages" id="toc-required-packages">Required
        packages</a>
    -   <a href="#custom-functions" id="toc-custom-functions">Custom
        functions</a>
-   <a href="#read-data" id="toc-read-data">Read data</a>
    -   <a href="#info" id="toc-info">Info</a>
    -   <a href="#offers" id="toc-offers">Offers</a>
    -   <a href="#performance" id="toc-performance">Performance</a>
    -   <a href="#phase" id="toc-phase">Phase</a>
    -   <a href="#calendar" id="toc-calendar">Calendar</a>
-   <a href="#clean-data" id="toc-clean-data">Clean data</a>
    -   <a href="#info-1" id="toc-info-1">Info</a>
    -   <a href="#offers-1" id="toc-offers-1">Offers</a>
    -   <a href="#performance-1" id="toc-performance-1">Performance</a>
    -   <a href="#phase-1" id="toc-phase-1">Phase</a>
    -   <a href="#calendar-1" id="toc-calendar-1">Calendar</a>
-   <a href="#model-data" id="toc-model-data">Model data</a>
    -   <a href="#dimensions" id="toc-dimensions">Dimensions</a>
        -   <a href="#local-authority" id="toc-local-authority">Local Authority</a>
        -   <a href="#school" id="toc-school">School</a>
        -   <a href="#phase-2" id="toc-phase-2">Phase</a>
        -   <a href="#calendar-2" id="toc-calendar-2">Calendar</a>

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

## Required packages

``` r
# Packages
library(tidyverse)      # for general wrangling
library(data.table)     # for transposing data frames
library(janitor)        # for cleaning column headers
library(lubridate)      # for working with dates
library(googlesheets4)  # for reading in Google Sheets files
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

This data frame has 36704 rows and 122 columns. The columns include some
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

``` r
# Set up the bridge table
brg_school <- src_info %>%
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
unique(brg_school$link_type)
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
brg_school <- brg_school %>% 
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
         la_name,
         number_preferences_la,
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
         number_of_preferences = number_preferences_la,
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
offers_num <- c("number_of_preferences",
                "proportion_1stprefs_v_1stprefoffers",
                "proportion_1stprefs_v_totaloffers",
                "offers_to_applicants_from_another_la")

# Correct data types in offers
offers <- offers %>% 
  mutate(across(all_of(offers_num), as.numeric))
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
    ## 1                                  year             9
    ## 2                           region_code            10
    ## 3                           region_name            10
    ## 4                               la_code           155
    ## 5                               la_name           157
    ## 6                 number_of_preferences             5
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

    ## # A tibble: 6 × 22
    ##    year region…¹ regio…² la_code la_name numbe…³ total…⁴ numbe…⁵ numbe…⁶ numbe…⁷
    ##   <dbl> <chr>    <chr>     <dbl> <chr>     <dbl>   <dbl>   <dbl>   <dbl>   <dbl>
    ## 1  2022 E120000… South …     803 South …       3      61      61      61       0
    ## 2  2022 E120000… East M…     830 Derbys…       3      30      30      29       1
    ## 3  2022 E120000… South …     865 Wiltsh…       3      30      30      29       1
    ## 4  2022 E120000… South …     865 Wiltsh…       3      35      34      32       2
    ## 5  2022 E120000… South …     866 Swindon       3      59      59      58       1
    ## 6  2022 E120000… South …     867 Brackn…       3      30      30      30       0
    ## # … with 12 more variables: number_3rd_preference_offers <dbl>,
    ## #   times_put_as_any_preferred_school <dbl>, times_put_as_1st_preference <dbl>,
    ## #   times_put_as_2nd_preference <dbl>, times_put_as_3rd_preference <dbl>,
    ## #   proportion_1stprefs_v_1stprefoffers <dbl>,
    ## #   proportion_1stprefs_v_totaloffers <dbl>,
    ## #   all_applications_from_another_la <dbl>,
    ## #   offers_to_applicants_from_another_la <dbl>, religious_denomination <chr>, …
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
  mutate(across(everything(), as.numeric))

# View the head
head(perf_ks2)
```

    ## # A tibble: 6 × 5
    ##    year    urn readprog writprog matprog
    ##   <dbl>  <dbl>    <dbl>    <dbl>   <dbl>
    ## 1  2015 100000      2.7      2.2     3  
    ## 2  2015 100028      2.6      4       3.5
    ## 3  2015 100029      2.3      1.4     0.3
    ## 4  2015 130342      3.4      2.2     2.3
    ## 5  2015 100013      2        1.4     6  
    ## 6  2015 100027      3.5      0.4     2.7

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
  mutate(across(everything(), as.numeric))

# View the head
head(perf_ks4)
```

    ## # A tibble: 6 × 4
    ##    year    urn p8mea att8scr
    ##   <dbl>  <dbl> <dbl>   <dbl>
    ## 1  2015 100003 NA       42.1
    ## 2  2015 100001 NA       32.2
    ## 3  2015 100053 -0.26    50.1
    ## 4  2015 100054  0.31    60.1
    ## 5  2015 137333 NA        3.4
    ## 6  2015 100084 NA       49.4

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

    ## # A tibble: 6 × 7
    ##    year    urn reading_progress writing_progress maths_progress progre…¹ attai…²
    ##   <dbl>  <dbl>            <dbl>            <dbl>          <dbl>    <dbl>   <dbl>
    ## 1  2015 100000              2.7              2.2            3         NA      NA
    ## 2  2015 100028              2.6              4              3.5       NA      NA
    ## 3  2015 100029              2.3              1.4            0.3       NA      NA
    ## 4  2015 130342              3.4              2.2            2.3       NA      NA
    ## 5  2015 100013              2                1.4            6         NA      NA
    ## 6  2015 100027              3.5              0.4            2.7       NA      NA
    ## # … with abbreviated variable names ¹​progress_8, ²​attainment_8

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
| fact_school_year |   x    |     x      |      x       |     x     |

Fact and dimension tables

To build out the dimensional model for this data, we need to review all
of the columns we intend to use, so that we can determine where they fit
in the model. The custom function `describe_df()` contained in the
`utils.R` file can help us with this.

``` r
# Create a vector of dfs to describe
data <- list("info" = info,
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
file named [star-schema](ref/star-schema.csv) which maps the raw source
data to the corresponding dimension and fact tables for the star schema
model.

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
| offers       | region_code  | E13000001            | dim_la      |
| offers       | region_name  | Inner London         | dim_la      |
| offers       | la_code      | 201                  | dim_la      |
| offers       | la_name      | City of London       | dim_la      |

These columns can all come from the `offers` and `info` data frames.

``` r
# Define columns to include
dim_la_cols_offers <- star_schema %>% 
  filter(model_table == "dim_la",
         source_table == "offers") %>% 
  pull(source_field)

dim_la_cols_info <- star_schema %>% 
  filter(model_table == "dim_la",
         source_table == "info") %>% 
  pull(source_field)

# Define which rows from offers should be joined (as there can be more than
# one record per URN)
dim_la_offers <- offers %>% 
  select(all_of(dim_la_cols_offers)) %>% 
  distinct()

# Build out the local authority dimension table
dim_la <- info %>% 
  select(all_of(dim_la_cols_info)) %>% 
  distinct() %>% 
  group_by(la_code, la_name) %>% 
  slice_min(gss_la_code) %>% 
  ungroup() %>% 
  full_join(dim_la_offers)

# Replace NA in dim_la
dim_la$gss_la_code[is.na(dim_la$gss_la_code)] <- "Not reported"

# Check the result
head(dim_la)
```

    ## # A tibble: 6 × 5
    ##   la_code la_name                gss_la_code region_code region_name 
    ##     <dbl> <chr>                  <chr>       <chr>       <chr>       
    ## 1     201 City of London         E09000001   E13000001   Inner London
    ## 2     202 Camden                 E09000007   E13000001   Inner London
    ## 3     203 Greenwich              E09000011   E13000002   Outer London
    ## 4     204 Hackney                E09000012   E13000001   Inner London
    ## 5     205 Hammersmith and Fulham E09000013   E13000001   Inner London
    ## 6     206 Islington              E09000019   E13000001   Inner London

Note that `la_code` is not unique.

``` r
# How many values of la_code are not unique?
dim_la %>% 
  count(la_code) %>% 
  filter(n > 1)
```

    ## # A tibble: 7 × 2
    ##   la_code     n
    ##     <dbl> <int>
    ## 1     203     2
    ## 2     801     2
    ## 3     810     2
    ## 4     839     2
    ## 5     840     2
    ## 6     884     2
    ## 7     928     2

Let’s check if `la_name` is unique.

``` r
# Is LA name unique?
dim_la %>% 
  count(la_name) %>% 
  filter(n > 1)
```

    ## # A tibble: 3 × 2
    ##   la_name       n
    ##   <chr>     <int>
    ## 1 Dorset        2
    ## 2 Norfolk       2
    ## 3 Wokingham     2

This means that, over time, some codes have been recycled and used for
different local authorities, and some local authorities have had changes
in code. Let’s assign a unique key to each record, and add a record for
the `null` case, which we’ll call `Not reported`.

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
| offers       | phase                 | Primary              | dim_phase   |
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
