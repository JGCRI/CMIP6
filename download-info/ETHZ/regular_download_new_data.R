## regular_download_newdata.R 
## This script creates the list of the netcdf files to download based on 
## what is avaiable in the cmip6 archive and what is not. 

## MINOR PROBLEM IT LOOKS LIKE THERE MIGHT BE SOMETHING WRONG WITH THE FILE LIST
## As of Dec 16 the file list downloaded from the rsync command is inconsistent. 
## it has a funky number of columns... which makes me really sad idk how this set 
## up will work any more... boooo... but i think I may wait to see if they 
## update it again if this issuse is fixed... 
# 0. Set Up ------------------------------------------------------------------------
# Import required libraries
library(dplyr)
library(tidyr)
library(tibble)

# Define directories
DTN2_DIR      <- '/pic/dtn2/dorh012'
CMIP6_ARCHIVE <- '/pic/projects/GCAM/CMIP6'

# 1. Import File List -------------------------------------------------------------
# Import the file list that is downloaded has file information about the cmip6 
# files stored at ETH but contains extra information that cannot be 
# easily run with Rsync commands. So this information will need to be 
# formated to work with Rsync commands. 
list.files(DTN2_DIR, 'filelist.txt', full.names = TRUE) %>% 
  read.table(header = FALSE, sep = " ") %>%  
  select(nc = V1, path = V2) -> 
  nc_path

# Categorize the data based on the file pattern name. 
month_data_pattern <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{6})-([0-9]{6}).nc'
day_data_pattern   <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{8})-([0-9]{8}).nc'
hr_data_pattern    <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{12})-([0-9]{12}).nc'
subHr_data_pattern <- '([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([0-9]{14})-([0-9]{14}).nc'
fx_file_pattern    <- '([a-zA-Z0-9-]+)_fx_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+).nc'
Ofx_file_pattern   <- '([a-zA-Z0-9-]+)_Ofx_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+)_([a-zA-Z0-9-]+).nc'

data_pattern <- paste(month_data_pattern, day_data_pattern, hr_data_pattern, subHr_data_pattern, sep = '|')
fx_pattern   <- paste(fx_file_pattern, Ofx_file_pattern, sep = '|')

nc_path %>%  
  mutate(type = if_else(grepl(pattern = data_pattern, x = nc), 'data', 'NA')) %>%  
  mutate(type = if_else(grepl(pattern = fx_pattern, x = nc), 'fx', type)) -> 
  categorized_data 

# Looks like there are some files that do not match the naming convention although it is 
# unclear if this is intentional or a mistake. Drop them for now. 
sum(categorized_data$type == 'NA')
categorized_data <- filter(categorized_data, type != 'NA')

## Now fomat the categorized data into a data frame that contains model / variable / ensemble and so 
## on inforamation. This data frame will be compared with the cmip6 archive to select the files 
## that we want to subset. 
categorized_data %>%
  filter(type == 'data') %>%  
  mutate(name = gsub(pattern = '.nc', replacement = '', x = nc)) %>% 
  tidyr::separate(name, c('variable', 'domain', 'model', 'experiment', 'ensemble', 'grid', 'time'), sep = '_') -> 
  data_df


# 2. Compare with the CMIP6 Files --------------------------------------------------
## Import the CMIP6 arhcive index and identify the files that have not been downloaded yet.
list.files(CMIP6_ARCHIVE, 'cmip6_archive_index.csv', full.names = TRUE) %>% 
  read.csv(stringsAsFactors = FALSE)  -> 
  cmip6_index

data_df %>%
  left_join(cmip6_index) %>%
  filter(is.na(file)) -> 
  not_downloaded
  
# Now figure out what data types have already been partically downloaded. 
cmip6_index %>% 
  select(variable, experiment) %>% 
  distinct %>% 
  mutate(missing = TRUE) -> 
  incomplete_data_sets

not_downloaded %>%  
  left_join(incomplete_data_sets) %>%
  filter(missing == TRUE)  -> 
  to_download 


## Because there are too many files to download we are only going to start 
## being more specific with the data files that are reguarly updated untill 
## asked for by a spcific user. 
to_download %>% 
  # Do not downlaod the global values 
  filter(!grid == 'gm') %>% 
  # Do not downloa the hourly data 
  filter(!grepl(pattern = 'hr', x = tolower(domain))) %>% 
  # Do not download the daily ocean data 
  filter(!domain == 'Oday') %>% 
  mutate(keep = FALSE) %>%
  mutate(keep = if_else(domain %in% c('Lmon', 'Emon', 'Omon'), TRUE, keep)) %>%  
  mutate(keep = if_else(variable %in% c('hfls', 'hfss', 'pr', 'tas', 'rlds', 'rlus', 'rsds', 'rsus') &
                          domain == 'Amon', TRUE, keep)) %>% 
  mutate(keep = if_else(variable %in% c('tasmax', 'tasmin', 'pr') & domain == 'day', TRUE, keep)) %>% 
  filter(keep) -> 
  to_download

# Save a copy of information about the new data. 
write.csv(x = to_download, file = file.path(DTN2_DIR, 'new_data.csv'), row.names = FALSE)

# Format and save the txt file that contains the list of the files to actually download. 
to_download %>% 
  select(path, nc) %>%
  mutate(file = paste0(path, '/', nc)) %>%
  pull(file) %>%  
  write.table(file = file.path(DTN2_DIR, 'to_download.txt'), row.names = FALSE, quote = FALSE, col.names = FALSE)