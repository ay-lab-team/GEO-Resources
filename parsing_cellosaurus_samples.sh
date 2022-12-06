# prepare dir to hold data
mkdir -p raw_cellosaurus; mkdir -p filtered_cellosaurus

# download sample-specific files
while read AC
do
	if [ ! -f "raw_cellosaurus/${AC}.txt" ]
	then
		wget -P raw_cellosaurus https://www.cellosaurus.org/${AC}.txt
	fi
done < accessions.txt

# filter for meta data from each file
for f in raw_cellosaurus/*
do	
	grep -w 'AC\|ID\|Derived\|NCIt\|SX\|AG\|CA\|OX' $f > filtered_cellosaurus/$(basename $f .txt)_filtered.txt
done

# make header for output table 
echo -e "" > celltype.csv
echo -e "Cellosaurus ID,Cell Line Name,Organ and/or Tissue,Cell Type,Disease,Sex,Age,Category,Species" > celltype.csv

# put meta data into the right column
for f in filtered_cellosaurus/*
do
	ac=$(grep -w "AC" $f | cut -f2- -d ' ' | awk '{$1=$1};1')
    id=$(grep -w "ID" $f | cut -f2- -d ' ' | awk '{$1=$1};1')
	cc=$(grep -w "CC" $f | rev | cut -f1 -d ':' | rev | awk '{$1=$1};1' | rev | cut -d ':' -f1 | rev)
	di=$(grep -w "DI" $f | rev | cut -f1 -d ';' | cut -f1 -d ',' | rev | awk '{$1=$1};1')
	sx=$(grep -w "SX" $f | cut -f2- -d ' ' | awk '{$1=$1};1')
	ag=$(grep -w "AG" $f | cut -f2- -d ' ' | awk '{$1=$1};1')
	ca=$(grep -w "CA" $f | cut -f2- -d ' ' | awk '{$1=$1};1')
    ox=$(grep -w "OX" $f | rev | cut -f1 -d '!' | rev | awk '{$1=$1};1')
    
    og=$(echo $cc | cut -f1 -d '.' | sed -e 's/\.//g')
    
    if [[ $cc == *"Cell type"* ]];
    then
        ct=$(echo $cc | cut -f2 -d '=' | sed -e 's/\.//g')
    else
        ct=""
    fi
    
    if [[ $ca == *"Cancer"* ]];
    then
        ca="Cancer"
    else
        ca="Normal"
    fi
    
	echo -e "${ac},${id},${og},${ct},${di},${sx},${ag},${ca},${ox}" >> celltype.csv
done

# sort -k1 -n -t, celltype.csv > sorted_celltype.csv

(head -n 2 celltype.csv && tail -n +3 celltype.csv | sort) > sorted_celltype.csv
