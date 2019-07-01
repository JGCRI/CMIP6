#Import libraries necessary to run code
library(dplyr)
library(ncdf4)
library(ggplot2)
#Set up directory paths and constants here
BASE        <- './'                         #Sets the working folder root
INPUT       <- BASE                         #Sets the input file location, in this case it is same as base
OUTPUT      <- file.path(BASE, 'output');   #Sets the output file location to base/output/


process_NetCDF <- function(filename-list, variable, years, cdovariable)
{
  
  
}