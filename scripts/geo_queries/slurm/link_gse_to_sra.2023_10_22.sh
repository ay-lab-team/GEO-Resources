#!/bin/bash

#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --mem=4G
#SBATCH --cpus-per-task=1
#SBATCH --time=01:00:00
#SBATCH --wait-all-nodes=1
#SBATCH --job-name="linking_gse_to_sra"

#SBATCH --output=results/logs/linking_gse_to_sra.%j.out
#SBATCH --error=results/logs/linking_gse_to_sra.%j.err
#SBATCH --array=1-166

# set samplesheet
samplesheet="results/sra/geo.samplesheet.2023_10_22.txt"

# load shared vars
source scripts/source.sh

# get the curr geo id
if [[ ! -v "SLURM_ARRAY_TASK_ID" ]];
then
    SLURM_ARRAY_TASK_ID=$1
fi
geo_id=$(sed -n "${SLURM_ARRAY_TASK_ID}p" $samplesheet)

# run the script 
outdir="results/sra/individual_gse/"
$python scripts/geo_queries/Linking_GSE_to_SRA.py $geo_id $outdir
