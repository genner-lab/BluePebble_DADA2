#!/bin/bash

#SBATCH --job-name=06_DADA2
#SBATCH --output=06_DADA2_%j.log
#SBATCH --error=06_DADA2_%j_error.log
#SBATCH --account=xxxxXXXXXX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=8GB
#SBATCH --time=24:00:00

## parse arguments
while getopts E:C:M:L: flag
do
	case "${flag}" in
		E) email=${OPTARG};;
		C) marker=${OPTARG};;
		M) minimum=${OPTARG};;
		L) maximum=${OPTARG};;
	esac
done

## build up arg string to pass to R script
ARGS=""
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi
if [ "$marker" ]; then ARGS="$ARGS -C $marker"; fi
if [ "$minimum" ]; then ARGS="$ARGS -M $minimum"; fi
if [ "$maximum" ]; then ARGS="$ARGS -L $maximum"; fi

## load R and call Rscript
source ~/.bash_profile
conda activate metabarcoding
Rscript $PWD/scripts/06_derep_dada2_merge_remove_chimeras.R $ARGS

echo "" >> working_data/06_*_lengths.tsv
cut -f 3 working_data/06_*_lengths.tsv | grep -v "Length" | sort | uniq -c >> working_data/06_ASV_lengths.tsv 
