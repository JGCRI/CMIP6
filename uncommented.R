#Import libraries necessary to run code
library(dplyr)
library(ncdf4)

#Set up directory paths and constants here
BASE        <- './'                                            #Sets the working folder root
INPUT       <- BASE                                           #Sets the input file location, in this case it is same as base
OUTPUT      <- file.path(BASE, 'output');                    #Sets the output file location to base/output/
TEMP        <- '.'                                            #Sets the temp file path
CDO_EXE     <- "/share/apps/netcdf/4.3.2/gcc/4.4.7/bin/cdo"   #Sets the location of the CDO executable


#Overrides the input file location, sets it to point to a file in the cmip6 folder
to_process <- '/pic/projects/GCAM/CMIP6/hfls/hfls_Amon_MRI-ESM2-0_historical_r5i1p1f1_gn_185001-201412.nc'

#Sets local variables equal to constants
CDO_EXE = CDO_EXE
temp_dir = TEMP
output_dir = OUTPUT
showMessages = FALSE
cleanUp = TRUE

#Setup stop commands for fatal path errors. Code will stop executing if it cannot find the files or paths listed below
stopifnot(file.exists(CDO_EXE))
stopifnot(dir.exists(temp_dir))
stopifnot(dir.exists(output_dir))

#Assign the CMIP file parsing components to a vector
cmip_info <- c('hfls', 'Amon', 'IPSL-CM6A-LR', '1pctCO2', 'r1i1p1f1', 'gr', '18500101-19991231')

#Construct file names from components
file_basename        <- paste(cmip_info, collapse = '_')
concat_nc            <- file.path(temp_dir, paste0('concate_', file_basename, '.nc'))
global_annual_avg_nc <- file.path(output_dir, paste0('global_annual_avg-', file_basename, '.nc'))

#Delete existing temp files if they already exist
if(file.exists(concat_nc)) file.remove(concat_nc)
if(file.exists(global_annual_avg_nc)) file.remove(global_annual_avg_nc)

#Run the CDO command to process the data input file
system2(CDO_EXE, args = c("-a", "cat", to_process, concat_nc), stdout = TRUE, stderr = TRUE)

if(file.exists(concat_nc)) message('***file exists *******', concat_nc)


#Calculate the global annual average
system2(CDO_EXE, args = c('fldmean', concat_nc, global_annual_avg_nc), stdout = TRUE, stderr = TRUE)

if(cleanUp){ file.remove(concat_nc) }

global_annual_avg_nc


to_process <- global_annual_avg_nc

filelist <- list.files(BASE, to_process, full.names = TRUE)
filepath <- filelist[1]

nc = nc_open(filepath) 
temp = ncvar_get(nc, 'tas')

ar<-c(1:12)
arc = 1
grid_size = 320*160
num_years = 86
#reduce from 51200 grid cells/month to 1 value per month, to 1 value per year
for(a in 0:num_years)
{
  for(b in 0:12)
  {
    for (c in 0:grid_size)
    {
      grid_to_month[b] = grid_to_month[b] + temp[c]
    }
    grid_to_month[b] = grid_to_month[b]/grid_size
  }
}
for (j in 0:(length(temp)/12)) 
{
  counter = j*12+1
  vx <- sum(temp[counter:(counter+11)])
  ar[arc] <- mean(vx)
  ar[arc] <- ar[arc]/12
  arc <- arc+1
}
v = 5