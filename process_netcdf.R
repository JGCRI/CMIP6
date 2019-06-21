#Import libraries necessary to run code
library(dplyr)
library(ncdf4)

#Set up directory paths and constants here
BASE        <- './'                   #Sets the working folder root
INPUT       <- BASE                                           #Sets the input file location, in this case it is same as base
OUTPUT      <- file.path(BASE, 'output');                     #Sets the output file location to base/output/

#to_process <- 'tas_Amon_MRI-ESM2-0_ssp245_r1i1p1f1_gn_201501-210012.nc'
to_process <- 'test.nc'

filelist <- list.files(BASE, to_process, full.names = TRUE)
filepath <- filelist[1]

nc = nc_open(filepath) 
temp = ncvar_get(nc, 'tas')

ar<-c(1:12)
arc = 1
for (j in 0:(length(temp)/12)) 
{
  counter = j*12+1
    vx <- sum(temp[counter:(counter+11)])
    ar[arc] <- mean(vx)
    ar[arc] <- ar[arc]/12
    arc <- arc+1
}
output = data.frame(ar)
write.csv(ar, file = file.path(OUTPUT, 'CMIP6_annual_global_average.csv'), row.names = FALSE)