# extract the header
first_fn=$(ls results/sra/*.meta.major_columns.renamed.tsv | head -1)
combined_fn="results/sra/combined.meta.major_columns.renamed.tsv"
sed -n '1p' $first_fn > $combined_fn

# concat the rest of the files
#find results/sra/ -name "*.meta.major_columns.renamed.tsv" ! -name "combined*" -exec echo {} \;
find results/sra/individual_gse/ -name "*.meta.major_columns.renamed.tsv" ! -name "combined*" -exec sed '1d' {} >> $combined_fn \;
