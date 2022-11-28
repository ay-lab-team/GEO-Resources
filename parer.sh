mkdir raw_cellosaurus; mkdir filtered_cellosaurus

cd raw_cellosaurus
while read AC; do wget https://www.cellosaurus.org/${AC}.txt; done <../accessions.txt

for f in ./*; do grep -w 'AC\|Derived\|NCIt\|SX\|AG\|CA' $f > ../filtered_cellosaurus/$(basename $f .txt)_filtered.txt; done
cd filtered_cellosaurus

echo -e "" > ../celltype.csv
echo -e "AC,CC,DT,SX,AG,CA" > ../celltype.csv

for f in ./*; do
ac=$(grep "AC" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
cc=$(grep "CC" $f | rev | cut -f1 -d ':' | rev | awk '{ gsub(/  /,""); print }' | rev | cut -d ':' -f1 | rev)
di=$(grep "DI" $f | rev | cut -f1 -d ';' | cut -f1 -d ',' | rev | awk '{ gsub(/  /,""); print }')
sx=$(grep "SX" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
ag=$(grep "AG" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
ca=$(grep "CA" $f | cut -f2- -d ' ' | awk '{ gsub(/  /,""); print }')
echo -e "${ac},${cc},${di},${sx},${ag},${ca}" >> ../celltype.csv
done
