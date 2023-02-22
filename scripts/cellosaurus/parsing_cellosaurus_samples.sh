#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# define command line arguments
input_fn=$1
output_fn=$2
cs_dir=$3

# prepare dir to hold data
echo "Preparing directory to hold data"
raw_cs_dir="${cs_dir}/raw_cellosaurus"
filtered_cs_dir="${cs_dir}/filtered_cellosaurus"
mkdir -p $raw_cs_dir $filtered_cs_dir

# download sample-specific files
echo "Downloading sample-specific files"
while read AC
do
	if [ ! -f "${raw_cs_dir}/${AC}.txt" ]
	then
		wget -P ${raw_cs_dir} https://www.cellosaurus.org/${AC}.txt
	fi
done < $input_fn



# filter for meta data from each file
echo "Filtering for meta data from each file"
for f in ${raw_cs_dir}/*;
do	
    base_fn=$(basename $f | sed 's/.txt$//')
    fn="${filtered_cs_dir}/${base_fn}_filtered.txt"
    if [ ! -f $fn ]
    then
        grep -w 'AC\|ID\|Derived\|NCIt\|SX\|AG\|CA\|OX' $f > $fn
    fi
done

# make header for output table 
echo -e "Cellosaurus ID,Cell Line Name,Organ and/or Tissue,Cell Type,Disease,Sex,Age,Category,Species" > $output_fn

# put meta data into the right column
echo "Putting meta data into the right column"
i="0"
fns=$(find ${filtered_cs_dir}/ -mindepth 1)
for f in $fns;
do
    # printf "\t${i}\n"
    i=$((i+1))

    # printf "\t${f}\n"
	ac=$(grep -w "AC" $f | cut -f2- -d ' ' | awk '{$1=$1};1' || echo "AC not specified")
    # printf "\t${ac}\n"

    id=$(grep -w "ID" $f | cut -f2- -d ' ' | awk '{$1=$1};1' || echo "ID not specified")
    # printf "\t${id}\n"

	cc=$(grep -w "CC" $f | rev | cut -f1 -d ':' | rev | awk '{$1=$1};1' | rev | cut -d ':' -f1 | rev || echo "Cell type not specified")
    # printf "\t${cc}\n"

	di=$(grep -w "DI" $f | rev | cut -f1 -d ';' | cut -f1 -d ',' | rev | awk '{$1=$1};1' || echo "Disease not specified")
    # printf "\t${di}\n"

	sx=$(grep -w "SX" $f | cut -f2- -d ' ' | awk '{$1=$1};1' || echo "Sex not specified")
    # printf "\t${sx}\n"

	ag=$(grep -w "AG" $f | cut -f2- -d ' ' | awk '{$1=$1};1' || echo "Age not specified")
    # printf "\t${ag}\n"

	ca=$(grep -w "CA" $f | cut -f2- -d ' ' | awk '{$1=$1};1' || echo "Category not specified")
    # printf "\t${ca}\n"

    ox=$(grep -w "OX" $f | rev | cut -f1 -d '!' | rev | awk '{$1=$1};1' || echo "OX not specified")
    # printf "\t${ox}\n"

    og=$(echo $cc | cut -f1 -d '.' | sed -e 's/\.//g' || echo "Organ and/or tissue not specified")
    # printf "\t${og}\n"
    
    # get cell type
    # printf "\tGetting cell type\n"
    if [[ $cc == *"Cell type"* ]];
    then
        ct=$(echo $cc | cut -f2 -d '=' | sed -e 's/\.//g')
    else
        ct="Cell type not specified"
    fi
    
    # get disease
    # printf "\tGetting disease\n"
    if [[ $ca == *"Cancer"* ]];
    then
        ca="Cancer"
    else
        ca="Normal"
    fi
    
    # output data
    # printf "\tOutputting data\n\n"
	echo -e "${ac},${id},${og},${ct},${di},${sx},${ag},${ca},${ox}" >> $output_fn
done

# sort data
echo "Sorting data" 
temp_fn="${cs_dir}/temp.txt"
(head -n 1 $output_fn && tail -n +2 $output_fn | sort) > $temp_fn 
cat $temp_fn | sed 's/,/\t/g' > $output_fn
rm $temp_fn