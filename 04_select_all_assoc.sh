#!/usr/bin/env bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Common initialization for all scripts.
source "${script_dir}/initialize_config.sh"

# Combine all significant SNPs
for summaryfile in "${signif_snps_dir}"/*.tsv
do 
    tail -n +2 "${summaryfile}" | cut -f1
done | sort -n | uniq | grep -v -e "^X:" > "${metadir}/significant_variants.txt"


# Cache unzipped short summary for all phenotypes
tail -n +2 "${selected_phenotypes_filepath}" | cut -f1 | while read -r pcode
do
    unzipfile="${unzip_dir}/${pcode}.tsv"
    assocfile="${all_assoc_dir}/${pcode}.tsv"
    grep -Fw -f "${metadir}/significant_variants.txt" "${unzipfile}" > "${assocfile}"
done

## use GNU Parallel
## find ../9_unzipped_summary -name "12*.tsv" -print0 | parallel -0 grep -f /gpfs/commons/home/sbanerjee/work/npd/UKBB/metadata/significant_variants.txt {}  ">" {/}.selected.txt
