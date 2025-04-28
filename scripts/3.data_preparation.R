
# y_star (Industrial Production Index (IPI)) ------------------------------------------------------------------

# impute missing data of ipi for last periods

last_data_ipi <- max(ipi$TIME_PERIOD)
non_missing_countries_ipi <- ipi |> 
  filter(TIME_PERIOD == last_data_ipi) |> 
  select(geo) |> 
  pull()

# if any countries of ipi data for last period is missing, do imputation with last observation carry forward 
ipi_imputed <- if( length(non_missing_countries_ipi) < length(countries)) {
	data.frame(
  geo = countries[!countries %in% non_missing_countries_ipi],
  TIME_PERIOD = last_data_ipi,
  values  = NA,
  indicator = "IPI"
)  |> 
  rbind(ipi) |> 
  arrange(geo,TIME_PERIOD) |> 
  group_by(geo) |> 
  mutate(values = na.locf(values)) |> 
  ungroup()
} else {

	ipi
}

# y_star (Industrial Production Index (IPI))
ipi_rebase <- ipi_imputed |>
  group_by(geo) |> 
  mutate(Year = year(TIME_PERIOD),
         index = values / mean(values[Year == 2014]) * 100) |>  # rebase data to 2014=100
  ungroup() |> 
  select(country_code = geo,TIME_PERIOD,index,Year)

# get foreign industrial production index by using trade weights for every country

y_star <- get_star_reg(ipi_rebase)

# er_star (exchange rates) -----------------------------------------------------------------

er_rebase <- exc_rate |> 
  mutate(adj_values = 1 / values) |> # get euro / national currency values
  group_by(geo) |> 
  mutate(index = adj_values / mean(adj_values[year(TIME_PERIOD) == 2014]) * 100) |> # rebase data to 2014=100
  ungroup() |> 
  mutate(Year = year(TIME_PERIOD)) |> 
  select(country_code = geo,TIME_PERIOD,index,Year)


# get foreign exchange rates by using trade weights for every country

er_star <- get_star_reg(er_rebase)


# rel_dp (Relative Harmonised Index of Consumer Prices (HICP)) ------------------------------------------------------------------

# impute missing data of hicp for last periods
last_data_hicp <- max(hicp$TIME_PERIOD)
non_missing_countries_hicp <- hicp |> 
  filter(TIME_PERIOD == last_data_hicp) |> 
  select(geo) |> 
  pull()
  
hicp_imputed <- if( length(non_missing_countries_hicp) < length(countries)) {
	data.frame(
  geo = countries[!countries %in% non_missing_countries_hicp],
  TIME_PERIOD = last_data_hicp,
  values  = NA,
  indicator = "HICP"
)  |> 
  rbind(hicp) |> 
  arrange(geo,TIME_PERIOD) |> 
  group_by(geo) |> 
  mutate(values = na.locf(values)) |> 
  ungroup()
  } else {
  
  hicp
  
  }

# dp_star (Harmonised Index of Consumer Prices (HICP))
hicp_rebase <- hicp_imputed |>
  filter(geo %in% countries) |> 
  group_by(geo) |> 
  mutate(Year = year(TIME_PERIOD),
         index = values / mean(values[Year == 2014]) * 100) |>  # rebase data to 2014=100
  ungroup() |> 
  select(country_code = geo,TIME_PERIOD,index,Year)

# get foreign Harmonised Index of Consumer Prices by using trade weights for every country

rel_dp <- get_star_reg(hicp_rebase) |> 
  pivot_longer(cols = -c(Date), names_to = "country_code", values_to = "index") |>
  rename(index_star = index) |> 
  left_join(hicp_rebase |> 
              mutate(Date = paste0(year(TIME_PERIOD), "M", month(TIME_PERIOD))) |> 
              select(-c(Year,TIME_PERIOD)) |> 
              rename(index_hicp = index),
            by = c("Date" = "Date", "country_code" = "country_code" )) |> 
  mutate(rel_dp = index_hicp / index_star) |> 
  pivot_wider(id_cols = Date,
              names_from = country_code,
              values_from = rel_dp) |>
  select(Date, all_of(countries))

# use intra import as regressor ----

imp_reg <- intra_imp |> 
  pivot_wider(id_cols = TIME_PERIOD,
              names_from = geo,
              values_from = values) |>
  select(Date = TIME_PERIOD , all_of(countries)) |>
  arrange(Date) |>
  mutate(Date = paste0(year(Date), "M", month(Date)))

# INTRA-EXPORT target data ----

target <- intra_exp |> 
  pivot_wider(id_cols = TIME_PERIOD,
              names_from = geo,
              values_from = values) |>
  select(Date = TIME_PERIOD , all_of(countries)) |>
  arrange(Date) |>
  mutate(Date = paste0(year(Date), "M", month(Date)))


# export regressors ----

# Create new workbook
data_export <- createWorkbook()

# Add worksheets
addWorksheet(data_export, "target")
addWorksheet(data_export, "y_star")
addWorksheet(data_export, "er_star")
addWorksheet(data_export, "rel_dp")
addWorksheet(data_export, "imp_reg")

# Write data to worksheets
writeData(data_export, "target", target)
writeData(data_export, "y_star", y_star)
writeData(data_export, "er_star", er_star)
writeData(data_export, "rel_dp", rel_dp)
writeData(data_export, "imp_reg", imp_reg)

saveWorkbook(data_export, paste0("./Data/",nowcast_period,"/data.xlsx"), overwrite = TRUE)

file.copy(from = paste0("./Data/",nowcast_period,"/data.xlsx"),
          to = paste0("./Results/",nowcast_period,"/data_",Sys.Date(),".xlsx"),
          overwrite = TRUE)





