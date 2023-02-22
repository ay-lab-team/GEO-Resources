# define command line arguments
input_fn="results/cellosaurus/accessions.txt"
output_fn="results/cellosaurus/cellosaurus_info.tsv"
cs_dir="results/cellosaurus/"

scripts/cellosaurus/parsing_cellosaurus_samples.sh \
    $input_fn \
    $output_fn \
    $cs_dir 