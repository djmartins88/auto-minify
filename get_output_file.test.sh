#!/bin/bash

test_output_file () {
	
    f_name=$( basename $1 | grep -oP '^.*(?=\.)' )
    # file extension
    f_extn=$( basename $1 | grep -oP '\.[^\.]*$' )
    # file path without file name
    f_dir=$( dirname $1 )
    # remove input folder from f_dir to build same relative folder path inside the $output folder
    o_dir=${f_dir//$input/}

    o_file=""

    # if o_dir is same as f_dir, replace was not possible which means no "o_dir" is not needed
    if [ "$o_dir" != "$f_dir" ]; then
        
        # create relative output folder if it doesn't exist
        if [ ! -d "$output/$o_dir" ]; then
            echo "$output/$o_dir doesn't exist. creating it."
            mkdir -p "$output/$o_dir"
        fi

        o_file=$(echo "$output/$o_dir/$f_name.min$f_extn")
    else 
        o_file=$(echo "$output/$f_name.min$f_extn")
    fi

    if [ ! -d "$output/$o_dir" ]; then
        echo "$output/$o_dir doesn't exist. creating it."
        mkdir -p "$output/$o_dir"
    fi

    echo "input folder: $input    output folder: $output"
    echo "relative file: $1    input_f: $input"
    echo "file name: $f_name    file ext: $f_extn"
    echo "file folder: $f_dir"
    echo "relative output folder path: $o_dir"
    echo "$1 >>> $o_file"

}

input="app/assets/"
output="app/assets/min"

test_output_file "app/assets/ticket.html"
test_output_file "app/assets/css/notes.css"

