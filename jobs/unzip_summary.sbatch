#!/bin/bash
#SBATCH --job-name=unzip_summaryfile
#SBATCH --partition=pe2
#SBATCH --nodes=1           # minimum number of nodes to be allocated
#SBATCH --ntasks=1          # number of tasks
#SBATCH --cpus-per-task=2   # number of cores on the CPU for the task
#SBATCH --mem=10G
#SBATCH --time=1-00:00:00
#SBATCH --output="%x.out"   # keep appending to the same output file
#SBATCH --error="%x.err"    # keep appending to the same error file

source ~/.bashrc
/gpfs/commons/home/sbanerjee/work/npd/UKBB/03_unzip_summaryfile.sh
