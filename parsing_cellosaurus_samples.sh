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
	grep -w 'AC\|Derived\|NCIt\|SX\|AG\|CA' $f > filtered_cellosaurus/$(basename $f .txt)_filtered.txt
done

# make header for output table 
echo -e "" > celltype.csv
echo -e "AC,CC,DT,SX,AG,CA" > celltype.csv

# put meta data into the right column
for f in filtered_cellosaurus/*
do
	ac=$(grep "AC" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
	cc=$(grep "CC" $f | rev | cut -f1 -d ':' | rev | awk '{ gsub(/  /,""); print }' | rev | cut -d ':' -f1 | rev)
	di=$(grep "DI" $f | rev | cut -f1 -d ';' | cut -f1 -d ',' | rev | awk '{ gsub(/  /,""); print }')
	sx=$(grep "SX" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
	ag=$(grep "AG" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
	ca=$(grep "CA" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
	echo -e "${ac},${cc},${di},${sx},${ag},${ca}" >> celltype.csv
done

sort -k1 -n -t, celltype.csv > sorted_celltype.csv
