#!/bin/bash/

# Make sure that none of the shell scripts made their way into the directory 
find ./archive/ -name "*.sh" -delete

# Remove any duplicate files, when there are duplicate downloads the files are appended by a .~N~ tag. 
find ./archive/ -name "*.nc.~*~" -delete

