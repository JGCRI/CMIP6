# Objective
This is the repository for JGCRI's CMIP6 archive that is stored under `/pic/projects/GCAM` on pic. The purpose of this repository is to document and organize the CMIP6 netcdfs used at the Institute and to minimize duplicative efforts to download the data. 

All JGCRI pic users are welcome to process CMIP6 netcdfs stored on the pic archive however we ask that you do not modify the netcdf files or save any of your work here because these netcdf files are shared Institute resources. 


*** 

# Available Data 

To figure out what data and where data is stored on pic take a look at `cmip6_archive_index.csv` it contains a CMIP6 information in a table that is easy to subset and filter. 

`cmip6_archive_index` column description
* file: as string of the full CMIP6 netcdf file name 
* type: a string set euqal to data or fx to indicate if the netcdf file is CMIP model output data or CMIP model meta data information. 
* variable: a string indicating the CMIP6 variable name, (TODO find the link to the CMIP6_MIP_tables_variable_names.xlsx)
* domain: a string indicating the CMIP6 modeling domain (TODO break out information about the frequency of the data from domain name)
* model: a string indicating the CMIP6 model group.
* experiment: as string indicating the CMIP6 experiment name. 
* ensemble: a string of the ensemble variant.
* grid: a string of the grid information (TODO check CMIP6 documenation for more information about the grid)
* time: a string describing the start and end date of the output netcdf, some modeling groups break output files for a single experiment into mulitple netcdf files by time. 


|file                                                                                                   |type |variable |domain |model       |experiment    |ensemble |grid |time          |
|:------------------------------------------------------------------------------------------------------|:----|:--------|:------|:-----------|:-------------|:--------|:----|:-------------|
|/pic/projects/GCAM/CMIP6/archive/co2s/co2s_Emon_CNRM-ESM2-1_esm-hist_r1i1p1f2_gr_185001-201412.nc      |data |co2s     |Emon   |CNRM-ESM2-1 |esm-hist      |r1i1p1f2 |gr   |185001-201412 |
|/pic/projects/GCAM/CMIP6/archive/co2s/co2s_Emon_CNRM-ESM2-1_esm-piControl_r1i1p1f2_gr_185001-209912.nc |data |co2s     |Emon   |CNRM-ESM2-1 |esm-piControl |r1i1p1f2 |gr   |185001-209912 |
|/pic/projects/GCAM/CMIP6/archive/co2s/co2s_Emon_CNRM-ESM2-1_esm-piControl_r1i1p1f2_gr_210001-234912.nc |data |co2s     |Emon   |CNRM-ESM2-1 |esm-piControl |r1i1p1f2 |gr   |210001-234912 |
|/pic/projects/GCAM/CMIP6/archive/co2s/co2s_Emon_CNRM-ESM2-1_piControl_r1i1p1f2_gr_185001-234912.nc     |data |co2s     |Emon   |CNRM-ESM2-1 |piControl     |r1i1p1f2 |gr   |185001-234912 |
|/pic/projects/GCAM/CMIP6/archive/co2s/co2s_Emon_CNRM-ESM2-1_ssp126_r1i1p1f2_gr_201501-210012.nc        |data |co2s     |Emon   |CNRM-ESM2-1 |ssp126        |r1i1p1f2 |gr   |201501-210012 |
|/pic/projects/GCAM/CMIP6/archive/co2s/co2s_Emon_CNRM-ESM2-1_ssp585_r1i1p1f2_gr_201501-210012.nc        |data |co2s     |Emon   |CNRM-ESM2-1 |ssp585        |r1i1p1f2 |gr   |201501-210012 |
|/pic/projects/GCAM/CMIP6/archive/gpp/gpp_Lmon_BCC-CSM2-MR_esm-hist_r1i1p1f1_gn_185001-201412.nc        |data |gpp      |Lmon   |BCC-CSM2-MR |esm-hist      |r1i1p1f1 |gn   |185001-201412 |
|/pic/projects/GCAM/CMIP6/archive/gpp/gpp_Lmon_BCC-CSM2-MR_esm-hist_r2i1p1f1_gn_185001-201412.nc        |data |gpp      |Lmon   |BCC-CSM2-MR |esm-hist      |r2i1p1f1 |gn   |185001-201412 |
|/pic/projects/GCAM/CMIP6/archive/gpp/gpp_Lmon_BCC-CSM2-MR_esm-hist_r3i1p1f1_gn_185001-201412.nc        |data |gpp      |Lmon   |BCC-CSM2-MR |esm-hist      |r3i1p1f1 |gn   |185001-201412 |
|/pic/projects/GCAM/CMIP6/archive/gpp/gpp_Lmon_BCC-CSM2-MR_historical_r1i1p1f1_gn_185001-201412.nc      |data |gpp      |Lmon   |BCC-CSM2-MR |historical    |r1i1p1f1 |gn   |185001-201412 |


*** 

# Requesting Data

If you are intrested in data that is not included in the index then it is also not downlaoded on pic. Please open a GitHub issue describing your data needs (model / experiment / variable and so on) and an ideal timeline. That way we can coordinate the data download and keep track of changes the the archive. 

