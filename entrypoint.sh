#!/bin/bash -l

get_files () {
	# gets the list of files to minimize, ignore output folder
	# find "app/assets/" -path "app/assets/min" -prune -o -name "*.html" -print'
	find $input -path $output -prune -o -name "*.$1" -print
}

get_output_file () {
	#gets the name of the output file 
	
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

	echo "input folder: $input    output folder: $output"
    echo "relative file: $1       input_f: $input"
    echo "file name: $f_name      file ext: $f_extn"
    echo "file folder: $f_dir"
    echo "relative output folder path: $o_dir"

	echo $o_file
}

minify() {

	in=$( readlink -m $1 )
	out=$( readlink -m $2 )

	echo "Minify : $in -> $out"

	if [[ $in == *.html ]]; then
		npx html-minifier-terser $in --collapse-whitespace --remove-comments > $out
	elif [[ $in == *.js ]]; then
		npx terser $in --compress --mangle --minify-js --toplevel > $out
	elif [[ $in == *.css ]]; then
		npx html-minifier-terser $in --collapse-whitespace --remove-comments > $out
	fi
}

cd /app/

dir="/github/workspace"

input="$dir/$INPUT_INPUT"
output="$dir/$INPUT_OUTPUT"

echo "minimizing files found on $input"
echo "writing results to $output"

# create output folder if it doesn't exist
if [ ! -z $output ]; then
	mkdir -p $output
fi

set -e

file_set=$({
	get_files 'html' &
	get_files 'js' &
	get_files 'css' &
})

# look for files with the specified extensions
for file in $file_set; do
	minify $file $( get_output_file $file )
done
