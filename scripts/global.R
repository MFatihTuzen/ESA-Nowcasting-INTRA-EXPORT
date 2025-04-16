
# Load Packages ------------------------------------------------------------

packages <-
  c("pacman",
    "tidyverse",
    "RJDemetra",
    "lubridate",
    "openxlsx",
    "jsonlite",
    "zoo",
    "eurostat",
    "tictoc",
    "progress",
    "rsdmx",
    "Metrics"
  )

invisible(lapply(packages, function(pkg) library(pkg, character.only = TRUE)))

# get data from eurostat by using eurostat package, change method "libcurl" to "wininet"
options(download.file.method = "wininet")
options(scipen = 9999)
Subject <- "INTRA_EXPORT"

# Trade Weights Data Import -------------------------------------------------------------

# foreign trade weights between 2014 and 2025 for every country -------------------------------------------------------------
trade_weights <- read.xlsx("./Data/intra_export_trade_weights.xlsx") 
countries <- unique(trade_weights$trade_partner)

# Currency codes of all countries ----
currency_codes <- data.frame(currency = c("BGN", "CZK","DKK", "HUF", "PLN", "RON", "SEK"), 
                             geo = c("BG", "CZ","DK", "HU", "PL", "RO", "SE"))

# TRAMO model metadata ----
model_info_tramo <- read.table("./Data/intra_export_models_tramo.csv", sep = ";", header = TRUE)
