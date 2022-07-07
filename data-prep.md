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

I have created several custom functions to assist with data prep. We can
load these functions by sourcing the `utils.R` script in the working
repository.

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

``` r
# Read in the source data for offers
src_offers_path <- "https://drive.google.com/file/d/1bG0a0WRg-LEnASl6M3J0qyHJA_cMY1CQ/view?usp=sharing"
src_offers <- read_csv_gdrive(src_offers_path)
```
