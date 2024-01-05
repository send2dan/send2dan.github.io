#Project setup
options(stringsAsFactors = FALSE)
options(scipen = 1, digits = 2)
ggplot2::theme_set(ggplot2::theme_minimal())

library(renv)
# renv::init()
# renv::activate()
# .libPaths()
# my_paths <- c("C:/Users/Weiandd2/Documents/win-library/4.1", "C:/Program Files/R/R-4.1.2/library")
# .libPaths(my_paths)

#Package load
library(tidyverse) # the tidyverse
library(lubridate) # tools that make it easier to parse and manipulate dates.
library(here) # for correctly loading files/data
library(knitr) # general-purpose tool for dynamic report generation in R
library(markdown) # for RMD
library(quarto) # next-generation tool for dynamic report generation in R
library(flextable) # for creating tables in R (various formats)
library(readxl) # import excel files into R.
library(readr) # a fast and friendly way to read rectangular data (like 'csv', 'tsv', and 'fwf')
library(janitor) # for tidying up R object names
library(skimr) # for superficially analysing larger datasets 
library(fontawesome) # for icons
library(beepr) # for cute sounds

# here::i_am()
here::set_here()
# here::dr_here()
here::here()

# Get the packages references
knitr::write_bib(c(.packages(), "bookdown"), here::here("packages.bib"))

# merge the zotero references and the packages references
cat(paste("% Automatically generated", Sys.time()), "\n% DO NOT EDIT",
    { readLines("urol_candidaemia.bib") %>% #which .bib file is being used?
        paste(collapse = "\n") },
    { readLines("packages.bib") %>% 
        paste(collapse = "\n") },
    file = "biblio.bib",
    sep = "\n")


