#!/bin/bash

#SBATCH --job-name=primer_removal
#SBATCH --output=primer_removal_%j.log
#SBATCH --error=primer_removal_%j_error.log
#SBATCH --account=xxxxXXXXXX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=2
#SBATCH --mem-per-cpu=16GB
#SBATCH --time=24:00:00

usage="$(basename "$0") [-D directory of raw data] [-F length of forward primer] [-R length of reverse primer] [-E email] \n
The user MUST supply the directory of raw data, and both the lengths of the forward and reverse primers. Optionally, the user
can provide an email address to receive a notification of completion.
Where:
    -D  directory containing raw data files
    -F  length of forward primer or sequence to be trimmed
    -R  length of reverse primer or sequence to be trimmed
    -E  email address"


## parse arguments
while getopts D:F:R:E: flag
do
  	case "${flag}" in
		D) directory=${OPTARG};;
                F) Flength=${OPTARG};;
                R) Rlength=${OPTARG};;
		E) email=${OPTARG};;
	esac
done

## build up arg string to pass to R script
ARGS=""
if [ "$directory" ]; then ARGS="$ARGS -D $directory"; fi
if [ "$Flength" ]; then ARGS="$ARGS -F $Flength"; fi
if [ "$Rlength" ]; then ARGS="$ARGS -R $Rlength"; fi
if [ "$email" ]; then ARGS="$ARGS -E $email"; fi

## load R and call Rscript
source ~/.bash_profile
conda activate metabarcoding
Rscript $PWD/scripts/primer_removal_by_length.R $ARGS
