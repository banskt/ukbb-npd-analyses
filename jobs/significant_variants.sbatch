#!/bin/bash
#SBATCH --job-name=ukbb_significant_variants
#SBATCH --partition=pe2
#SBATCH --nodes=1           # minimum number of nodes to be allocated
#SBATCH --ntasks=1          # number of tasks
#SBATCH --cpus-per-task=8   # number of cores on the CPU for the task
#SBATCH --mem=50G
#SBATCH --time=1-00:00:00
#SBATCH --output="%x.out"   # keep appending to the same output file
#SBATCH --error="%x.err"    # keep appending to the same error file

source ~/.bashrc
/gpfs/commons/home/sbanerjee/work/npd/UKBB/02_select_significant_variants.sh
