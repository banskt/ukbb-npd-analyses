#!/usr/bin/env bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Common initialization for all scripts.
source "${script_dir}/initialize_config.sh"

# Select significant SNPs
tail -n +2 "${selected_phenotypes_filepath}" | cut -f1 | while read -r pcode
do
    rawfile="${rawdata_dir}/${pcode}.tsv.bgz"
    summaryfile="${signif_snps_dir}/${pcode}.tsv"
    # header columns
    eval declare -A header_cols=( \
        $( zcat "${rawfile}" | head -n 1 | \
            sed 's///g' | sed 's/ //g' | \
            awk -F"\t" '{ for (i=1; i<=NF; i++) printf "[\"%s\"]=\"%d\" ", $i, i; printf "\n" }' ) )
    # select high confidence variants 
    # p-val < 5e-8
    echo "Process ${rawfile}"
    zcat "${rawfile}" | head -n 1 | sed 's///g' > "${summaryfile}"
    zcat "${rawfile}" | sed 's///g' | \
        awk -F"\t" \
            -v low_conf_col="${header_cols["low_confidence_variant"]}" \
            -v pval_col="${header_cols["pval"]}" \
            '{ if ($low_conf_col == "false" && $pval_col <= 5e-8 ) { print $0 } }' >> "${summaryfile}"
done
