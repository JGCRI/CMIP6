## format_filelistTEMPLATE.R 
## This is the template script for formating the file list from the cantains all  
## of the conents of the cmip6 files saved on EZH. So that Rsync commands can 
## be run to a sepcific set of files. 

## Section 3 of this script will need to be modified for each indiviudal use!! 

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

# Now fomat the categorized data into a data frame that contains model / variable / ensemble and so 
# on inforamation. This data frame will be compared with the cmip6 archive to select the files 
# that we want to subset. 
categorized_data %>%
  filter(type == 'data') %>%  
  mutate(name = gsub(pattern = '.nc', replacement = '', x = nc)) %>% 
  tidyr::separate(name, c('variable', 'domain', 'model', 'experiment', 'ensemble', 'grid', 'time'), sep = '_') -> 
  data_df


# 2. Import the CMIP6 Archive -------------------------------------------------------------

list.files(CMIP6_ARCHIVE, 'cmip6_archive_index.csv', full.names = TRUE) %>% 
  read.csv(stringsAsFactors = FALSE)  -> 
  cmip6_index



# 3. CUSTOM PORTION  -------------------------------------------------------------
# ## Combine the file list data frame with the cmip6 arcvie data frame. And subset the 
# ## resulting data frame for the entries that do not exist on pic. 
data_df %>%
  left_join(cmip6_index) %>%
  filter(is.na(file)) %>%
  # Add a filter statement here to determine what files are to be downloaded. 
  # filter( for some model / domain / variable and so on)
  select(path, nc) %>%
  mutate(file = paste0(path, '/', nc)) %>%
  pull(file) ->
  to_download
  

# 4. Save to download list  -------------------------------------------------------------
write.table(to_download, file = file.path(DTN2_DIR, 'to_download.txt'), row.names = FALSE, quote = FALSE, col.names = FALSE)






