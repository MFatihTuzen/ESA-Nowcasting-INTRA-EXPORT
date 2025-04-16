
# Nowcasting algorithm of INTRA EXPORT 

# get_nowcast values of each country. It depends on period of nowcast period.

get_nowcast <- function(nowcast_period){

# Create Directories ------------------------------------------------------

if(!dir.exists(paste0("Data/",nowcast_period))){
  dir.create(paste0("Data/",nowcast_period))
}

if(!dir.exists(paste0("Results/",nowcast_period))){
  dir.create(paste0("Results/",nowcast_period))
}

# Source R Codes ----------------------------------------------------------

source("./scripts/global.R", local = TRUE)
source("./scripts/1.utilities.R", local = TRUE)

if(format(Sys.Date(), "%Y-%m") == nowcast_period)
{
  
source("./scripts/2.data_import.R", local = TRUE)
source("./scripts/3.data_preparation.R", local = TRUE)
cat(paste0("Data Preparation Process Completed\n"))
  
}

source("./scripts/4.tramo_model_mv.R", local = TRUE)
cat(paste0("TRAMO MODEL MULTIVARIATE Process Completed\n"))
source("./scripts/5.tramo_model_uv.R", local = TRUE)
cat(paste0("TRAMO MODEL UNIVARIATE Process Completed\n"))
source("./scripts/6.tramo_model_average.R", local = TRUE)
cat(paste0("TRAMO MODEL AVERAGE Process Completed\n"))
source("./scripts/7.export_results.R", local = TRUE)
cat(paste0("Process Completed"))

}
