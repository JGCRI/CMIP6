import os


def list_to_lower(l):
    """Convert all strings in a list to lower case.

    :param l:                           Python list of strings

    :return:                            A list of lower case strings.

    """
    return [i.lower() for i in l]


def check_validity(reference_list, in_list, include=True):
    """

    :param reference_list:              List of parsed attributes from file name string
    :param in_list:                     List of either include or exclude attributes as strings
    :param include:                     If True, an include list is being passed; False, if an exclude list is being passed

    :return:                            True for valid; False for invalid

    """
    compare_list = list_to_lower(in_list)

    # if checking files against files to include
    if include:

        valid_elements = len([i for i in compare_list if i in reference_list])

        if valid_elements > 0:
            return True

        else:
            return False

    # if checking files against file to exclude
    else:

        valid_elements = len([i for i in reference_list if i not in compare_list])

        if (len(reference_list) - valid_elements) == 0:
            return True

        else:
            return False


def parse_wget(wget_file, wget_out, include_list=None, exclude_list=None,
               eof_string='EOF--dataset.file.url.chksum_type.chksum', download_shell_var='download_files',
               file_delim='_'):
    """Write target source files to download from an ESGF generated wget script into a new wget script.

    :param wget_file:                   Full path with file name and extension of the input wget shell script
    :param wget_out:                    Full path with file name and extension of the output wget shell script
    :param include_list:                List of attributes found in the file name as strings (e.g., IPSL-CM6A-LR) to signal keeping the file
    :param exclude_list:                List of attributes found in the file name as strings (e.g., IPSL-CM6A-LR) to signal removing the file
    :param eof_string:                  End of file string containing check sum that indicates the beginning and end of the files to download in the in file
    :param download_shell_var:          Variable name in the input script containing the download files
    :param file_delim:                  Attribute delimiter in the NetCDF file name

    """
    # initialize variables with starting condition
    capture = False
    active_index = 1

    # open output file
    with open(wget_out, 'w') as out:

        # open input file
        with open(wget_file, 'r') as get:

            for index, line in enumerate(get):

                # capture start of download file
                if (download_shell_var in line) and (eof_string in line):
                    capture = True

                    # skip this line and set the index value as the next iteration
                    active_index = index + 1

                # end capture of wget statements at EOF
                if (download_shell_var not in line) and (eof_string in line):
                    capture = False

                # capture target line
                if (capture is True) and (index == active_index):

                    # advance the capture index to prepare the next iteration
                    active_index += 1

                    # get the file name from the line
                    file_name = line.strip().split(' ')[0]

                    # remove single or double quotes and extension from file name
                    file_base = os.path.splitext(file_name.
                                                 replace("'", '').
                                                 replace('"', ''))[0]

                    # split file name by delimiter and make lower case for comparison
                    file_split = list_to_lower(file_base.split(file_delim))

                    # check if line should be excluded based on file attributes declared by user
                    if exclude_list is not None:
                        valid_exclude = check_validity(file_split, exclude_list, include=False)
                    else:
                        valid_exclude = True

                    # check if line should be included based on file attributes declared by user
                    if include_list is not None:
                        valid_include = check_validity(file_split, include_list, include=True)
                    else:
                        valid_include = True

                    # write line if valid
                    if (valid_exclude is False) or (valid_include is False):
                        pass
                    else:
                        out.write(line)

                # write line if out of downloads block
                else:
                    out.write(line)


if __name__ == '__main__':

    wget_file = 'path/of/wget/to/parse.sh'
    wget_out = '/path/of/where/to/save/new.sh'
    keep_list = None
    remove_list = ['model name']

    eof_string = 'EOF--dataset.file.url.chksum_type.chksum'
    download_shell_var = 'download_files'
    file_delim = '_'

    parse_wget(wget_file, wget_out, include_list=keep_list, exclude_list=remove_list,
               eof_string=eof_string, download_shell_var=download_shell_var, file_delim='_')
