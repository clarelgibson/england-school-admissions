Source data preparation for the England school admissions dashboard
================
Clare Gibson

-   [Introduction](#introduction)

# Introduction

This notebook serves as the documented code to read and prepare data for
the England School Admissions Dashboard project
([github](https://github.com/clarelgibson/england-school-admissions) \|
[tableau](https://public.tableau.com/views/Schools_16505251102060/Home?:language=en-GB&:display_count=n&:origin=viz_share_link)).

I begin by reading in the raw data required for the dashboards. I then
explain my intended approach to convert the raw data into a
“star-schema” dimensional model, using conformed dimensions to serve
multiple fact tables. Finally I work through the data wrangling steps
necessary to prepare the dimensional model.
