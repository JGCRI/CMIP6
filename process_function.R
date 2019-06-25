#Import libraries necessary to run code
library(dplyr)
library(ncdf4)
library(ggplot2)
#Set up directory paths and constants here
BASE        <- './'                         #Sets the working folder root
INPUT       <- BASE                         #Sets the input file location, in this case it is same as base
OUTPUT      <- file.path(BASE, 'output');   #Sets the output file location to base/output/

#load in file to process
to_process <- 'tas_Amon_MRI-ESM2-0_ssp245_r1i1p1f1_gn_201501-210012.nc'
filelist <- list.files(BASE, to_process, full.names = TRUE)
filepath <- filelist[1]

process_NetCDF <- function(filename, variable, gridsize, years, cdovariable)
{
  
}
#open file and load in variable to process
nc = nc_open(filepath) 
temp = ncvar_get(nc, 'tas')

#set up variables to process gridded data
grid_size = 320*160
num_years = 86
month_to_year = c(1:12)
yearly_sum = c(1:num_years)

#reduce from 51200 grid cells/month to 1 value per month, to 1 value per year
for(v_years in 1:num_years)
{
  for(v_months in 1:12)
  {
    for (v_cells in 1:grid_size)
    {
      month_to_year[v_months] = month_to_year[v_months] + temp[v_cells]
    }
    month_to_year[v_months] = month_to_year[v_months]/grid_size
    yearly_sum[v_years] = yearly_sum[v_years] + month_to_year[v_months]
  }
  yearly_sum[v_years] = yearly_sum[v_years] /12
}
#final calculation to reduce from yearly to one global mean value
global_mean = sum(yearly_sum)/num_years
#output = data.frame(ar)
write.csv(yearly_sum, file = file.path(OUTPUT, 'CMIP6_annual_global_average.csv'), row.names = FALSE)