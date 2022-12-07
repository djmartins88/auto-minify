#!/bin/bash -l

# gets the list of files to minimize, ignore output folder
get_files () {
	# find "app/assets/" -path "app/assets/min" -prune -o -name "*.html" -print'
	find $input -path $output -prune -o -name "*.$1" -print
}

#gets the name of the output file 
get_output_file () {

	# echo "getting output file name for $1"
	
	f_name=$( basename $1 | grep -oP '^.*(?=\.)' )
    # file extension
    f_extn=$( basename $1 | grep -oP '\.[^\.]*$' )
    # file path without file name
    f_dir=$( dirname $1 )
    # remove input folder from f_dir to build same relative folder path inside the $output folder
    o_dir=${f_dir//$input/}

    o_file=""

	# echo "input folder: $input    output folder: $output"
    # echo "relative file: $1       input_f: $input"
    # echo "file name: $f_name      file ext: $f_extn"
    # echo "file folder: $f_dir"
    # echo "relative output folder path: $o_dir"

    # if o_dir is same as f_dir, replace was not possible which means no "o_dir" is not needed
    if [ "$o_dir" != "$f_dir" ]; then
        
        # create relative output folder if it doesn't exist
        if [ ! -d "$output$o_dir" ]; then
            echo "$output$o_dir doesn't exist. creating it."
            mkdir -p "$output$o_dir"
        fi

        o_file=$(echo "$output$o_dir/$f_name.min$f_extn")
    else 
        o_file=$(echo "$output$f_name.min$f_extn")
    fi

	echo $o_file
}

# calls the minify function
minify () {

	in=$( readlink -m $1 )
	o_file=$( readlink -m $2 )

	echo "Minify : $in -> $o_file"

	if [ $in == *.html ]; then
		npx html-minifier-terser "$in" --collapse-whitespace --remove-comments > $o_file
	elif [ $in == *.js ]; then
		npx terser "$in" --compress --mangle --minify-js --toplevel > $o_file
	elif [ $in == *.css ]; then
		npx html-minifier-terser "$in" --collapse-whitespace --remove-comments > $o_file
	fi

    echo "minified."
}

# echo "local-dbug: $LOCAL_DEBUG"
echo "input: $INPUT_INPUT"
echo "output: $INPUT_OUTPUT"

wf=""
if [ -z ${LOCAL_DEBUG+x} ]; then
    wf="/github/workspace"
else
	wf="."
fi

input="$wf/$INPUT_INPUT"
output="$wf/$INPUT_OUTPUT"

# create output folder if it doesn't exist
if [ ! -z $output ]; then
	mkdir -p $output
fi

# stop if too many errors
set -e

file_set=$({
	get_files 'html' &
	get_files 'js' &
	get_files 'css' &
})

# look for files with the specified extensions
for file in $file_set; do
	get_output_file $file;
	minify $file $o_file;
done
