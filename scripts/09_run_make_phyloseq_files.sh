#!/bin/bash

#SBATCH --job-name=09_make_phyloseq
#SBATCH --output=09_make_phyloseq_%j.log
#SBATCH --error=09_make_phyloseq__%j_error. log
#SBATCH --account=xxxxXXXXXX
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --mem-per-cpu=4GB
#SBATCH --time=72:00:00
#SBATCH --mail-type=END

## load profile. Conda environment required to run Rscript command
source ~/.bash_profile
conda activate metabarcoding

USAGE=printf "
####################################################
## Using the 09_run_make_phyloseq_files.sh script ##
####################################################
\n09_run_make_phyloseq_files.sh -E [email address] \n
This script calls an R script that takes the taxonomic assignments generated using DADA2 assignTaxonomy and assignSpecies and the
'06' files from DADA2 to produce a final summary file combining the taxon path, taxonomic assignment, sequence information and count data.
This file is saved to the working_data directory and also sent to the user's email address (-E). The R script also creates three additional 
files that can be used as input for the popular R package phyloseq, and saves them to the working_data directory. These are not emailed to the user.
These include the taxon and count matrices that form the main phyloseq inputs. It also uses MAFFT to align ASV sequences and IQTREE to construct a 
phylogeny of the ASV sequences. This is saved as an R data file for use in phyloseq for the calculation of phylogenetically aware diversity indices.  
\n
These are the files required for the script to run: \n
- working_data/06_ASV_seqs.fasta 
- working_data/06_ASV_counts.tsv 
- working_data/08_
- working_data/08_ \n
These are the files created by the script (with brief description): \n
- working_data/ASV_taxa_seq_counts.tsv (taxa, sequence and count data): sent to user's email address (-E)
- working_data/ps_taxamat.tsv (taxon path in phyloseq format)
- working_data/ps_countmat.tsv (count data in phyloseq format)
- working_data/ps_phylogeny.rds (sequence phylogeny in phyloseq format) \n
Here is an example of how you might run the script on BluePebble:\n
sbatch scripts/09_run_make_phyloseq_files.sh -E user@university.ac.uk \n\n\n"

## parse arguments
while getopts E: flag; do
    case "${flag}" in
        E) email=${OPTARG};;
    esac
done

## Check mandatory arguments
shift $((OPTIND-1))
if  [ -z "${email}" ]; then
   printf "An email address needs to be provided using the -E flag" >&2; exit 1
fi

# Run the R script to combine the taxonomy, sequence and counts into a single summary file and create phyloseq-ready files
Rscript $PWD/scripts/09_make_phyloseq_files.R
