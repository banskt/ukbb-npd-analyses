#!/usr/bin/env bash

script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Common initialization for all scripts.
source "${script_dir}/initialize_config.sh"

# Unzip short summary for all phenotypes
tail -n +2 "${selected_phenotypes_filepath}" | cut -f1 | while read -r pcode
do
    rawfile="${rawdata_dir}/${pcode}.tsv.bgz"
    unzipfile="${unzip_dir}/${pcode}.tsv"
    # select columns
    eval declare -A header_cols=( \
        $( zcat "${rawfile}" | head -n 1 | \
            sed 's///g' | sed 's/ //g' | \
            awk -F"\t" '{ for (i=1; i<=NF; i++) printf "[\"%s\"]=\"%d\" ", $i, i; printf "\n" }' ) )
    select_cols="${header_cols["variant"]},${header_cols["low_confidence_variant"]},${header_cols["beta"]},${header_cols["se"]},${header_cols["tstat"]},${header_cols["pval"]}"
    # I have checked cut is faster than awk for large files
    if [[ ! -f "${unzipfile}" ]]; then
        zcat "${rawfile}" | sed 's///g' | tail -n +2 | cut -f"${select_cols}" > "${unzipfile}"
    fi
    #if [[ ! -f "${unzipfile}" ]]; then
    #        awk -F"\t" \
    #            -v variant_col="${header_cols["variant"]}" \
    #            -v low_conf_col="${header_cols["low_confidence_variant"]}" \
    #            -v beta_col="${header_cols["beta"]}" \
    #            -v se_col="${header_cols["se"]}" \
    #            -v tstat_col="${header_cols["tstat"]}" \
    #            -v pval_col="${header_cols["pval"]}" \
    #            '{ printf ("%s\t%s\t%s\t%s\t%s\t%s\n", $variant_col, $low_conf_col, $beta_col, $se_col, $tstat_col, $pval_col) }' > "${unzipfile}"
    #fi
done
