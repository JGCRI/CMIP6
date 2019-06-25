
#Import libraries necessary to run code
library(dplyr)
library(ncdf4)
library(ggplot2)

#find and open the two files from the netcdf and cdo processing
#Set up directory paths and constants here
BASE        <- './'                         #Sets the working folder root
INPUT       <- BASE                         #Sets the input file location, in this case it is same as base
OUTPUT      <- file.path(BASE, 'output');   #Sets the output file location to base/output


#load in file to process
to_process <- 'finalyearmean.nc'
filelist <- list.files(BASE, to_process, full.names = TRUE)
filepath <- filelist

#open file and load in variable to process
nc = nc_open(filepath) 
temp = ncvar_get(nc,'tas')
df = data.frame(temp)
#file 2
file2 = read.csv("output/CMIP6_annual_global_average.csv")

ggplot() + geom_line(data=df, aes(x=c(2015:2100), temp)) + geom_line(data=file2, aes(x=c(2015:2100),x))

#global_annual_avg_nc
#graph both files