## archive_index.R
## This script serarches the CMIP6 archive on pic and parses out information about the model / resolution / 
## ensemble member and so on about the each netcdf into a version controled csv file that can easily 
## be searched for sepcifc files of interest. 
# 0. Set Up -------------------------------------------------------------------------------
# The required libraries
library(dplyr)
library(tidyr)
library(tibble)

# Define the directories to search for CMIP6 files and save the archive index at. 
PIC_ARCHIVE_DIR <- '/pic/projects/GCAM/CMIP6/archive'  
WRITE_TO        <- file.path(PIC_ARCHIVE_DIR, '..')

# 1. Find Files -------------------------------------------------------------------------------
# Find all of the CMIP6 netcdf files on pic. 
file <- list.files(path = PIC_ARCHIVE_DIR, pattern = '.nc', full.names = TRUE, recursive = TRUE)

# 2. Parse out CMIP6 info ---------------------------------------------------------------------
## Parse out CMIP6 info from the CMIP6 netcdf file name. But first the files will have to be 
## categorized by the type of netcdf file, whether or not the netcdf file contains 
## actual data or meta data. 

# Define the netcdf serach file patterns. 
month_data_pattern <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{6})-([0-9]{6}).nc'
day_data_pattern   <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{8})-([0-9]{8}).nc'
hr_data_pattern    <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{12})-([0-9]{12}).nc'
subHr_data_pattern <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{14})-([0-9]{14}).nc'
data_pattern <- paste(month_data_pattern, day_data_pattern, hr_data_pattern, subHr_data_pattern, sep = '|')
fx_pattern   <- '([a-zA-Z0-9-]+)_fx_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+).nc'
Ofx_pattern  <- '([a-zA-Z0-9-]+)_Ofx_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+).nc'

# Cateforize the netcdfs. 
tibble(file = file) %>%  
  mutate(type = if_else(grepl(pattern = data_pattern, x = file), 'data', 'NA')) %>%  
  mutate(type = if_else(grepl(pattern = fx_pattern , x = file), 'fx', type)) %>% 
  mutate(type = if_else(grepl(pattern = Ofx_pattern , x = file), 'fx', type)) -> 
  categorized_data 
  
# Make sure that ever file has been categorized as a type. 
assertthat::assert_that(sum(categorized_data$type == 'NA') == 0, msg = 'unkown data file strucutre')

# Parse out the data information for the data files. 
categorized_data %>% 
  dplyr::filter(type == 'data') %>% 
  mutate(name = gsub(pattern = '.nc', replacement = '', x = basename(file))) %>% 
  tidyr::separate(col = name, into = c('variable', 'domain', 'model', 'experiment', 'ensemble', 'grid', 'time'), sep = '_') -> 
  data_df

# Parse our the information for the meta data files. 
categorized_data %>% 
  dplyr::filter(type == 'fx') %>% 
  mutate(name = gsub(pattern = '.nc', replacement = '', x = basename(file))) %>% 
  tidyr::separate(col = name, into = c('variable', 'domain', 'model', 'experiment', 'ensemble', 'grid'), sep = '_') -> 
  fx_df

# Combine the data and meta data information data frames into a single data frame. 
bind_rows(data_df, 
          fx_df) -> 
  cmip6_index

# 3. Checks and Correct ---------------------------------------------------------------------
# Final checks before saving. Somethings I've noticed is that there can be errors with the way that the modeling groups 
# saved the netcdf files. These will need to be correcte before saving. 
cmip6_experiments <- c("esm-hist", "esm-piControl", "piControl", "ssp126",         
                       "ssp585", "historical", "1pctCO2", "ssp245", 
                       "ssp370", "ssp119", "ssp434", "ssp460", 
                       "ssp534-over", "abrupt-4xCO2", "abrupt-2xCO2", "abrupt-0p5xCO2", 
                       "esm-ssp585", "ssp126-ssp370Lu", "ssp370-lowNTCF", "ssp245-GHG", 
                       "hist-aer", "hist-GHG", "hist-nat", "hist-sol", "hist-volc", "piClim-4xCO2", "piClim-aer", 
                       "piClim-anthro", "piClim-control", "piClim-ghg", "land-hist")

assertthat::assert_that(all(cmip6_index$experiment %in% cmip6_experiments), msg = 'Unexpected CMIP experiment name.')

# The other important thing to check for is to make sure that there are no duplicates in the archive. 
duplicates <- duplicated(cmip6_index[ , names(cmip6_index) != 'file'])

assertthat::assert_that(!any(duplicates), msg = 'There are duplicates in the cmip6 archive!')

if(any(duplicates)){
  
  duplicated_info <- cmip6_index[duplicates, names(cmip6_index) != 'file']
  
  cmip6_index %>% 
    inner_join(duplicated_info) %>%  
    arrange(type, variable, domain, model, experiment, ensemble, grid, time) -> 
    problem_files 
}




# 4. Save Index ---------------------------------------------------------------------
write.csv(x = cmip6_index, file = file.path(WRITE_TO, 'cmip6_archive_index.csv'), row.names = FALSE)
  

