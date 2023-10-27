#!/usr/bin/env bash

# Neale lab GWAS manifest
# Download CSV file of the manifest
# https://docs.google.com/spreadsheets/d/1kvPoupSzsSFBNSztMzl04xMoSC3Kcx3CrjVf4yBmESU/edit?usp=drive_link
# From the Excel file, download the spreadsheet titled "Manifest 201807"

manifest_filename="UKBB_GWAS_Imputed_v3_File_Manifest_Release_20180731.csv"

## =========================
## Setup directory structure
## =========================
datadir="/gpfs/commons/groups/knowles_lab/data/gwas/ukbb.imputed_v3.neale/1_raw"
workdir="/gpfs/commons/home/sbanerjee/work/npd/UKBB"
metadir="${workdir}/metadata"
## =========================
mkdir -p "${datadir}" "${metadir}"
manifest_filepath="${workdir}/${manifest_filename}"
manifest_nodos_filepath="${workdir}/${manifest_filename%.csv}_nodos.csv"

## =========================
## Meta information files
## =========================
phenotypes_filepath="${metadir}/phenotypes.both_sexes.v2.tsv.bgz"
variants_filepath="${metadir}/variants.tsv.bgz"
biomarkers_filepath="${metadir}/biomarkers.both_sexes.tsv.bgz"

## =========================
## Manually curated files
## =========================
npd_selection_infopath="${workdir}/wordlist/npd_include.txt"
npd_exclusion_infopath="${workdir}/wordlist/npd_exclude.txt"
selected_phenotypes_filepath="${workdir}/npd_phenotypes.tsv"

## =========================
## Source functions
## =========================
for srcfile in ${workdir}/utils/*.sh; do
    echo "Source ${srcfile}"
    source "${srcfile}"
done



# associative array to keep column IDs from header names
echo "Read UKBB manifest file."
eval declare -A header_cols=( \
    $( head -n 1 "${manifest_filepath}" | \
        sed 's///g' | sed 's/ //g' | \
        awk -F"," '{ for (i=1; i<=NF; i++) printf "[\"%s\"]=\"%d\" ", $i, i; printf "\n" }' ) )

echo "Number of headers: ${#header_cols[@]}"
echo "Header names: ${!header_cols[@]}"
echo ""

[[ ! -f "${manifest_nodos_filepath}" ]] && sed 's///g' "${manifest_filepath}" > "${manifest_nodos_filepath}"

# wget the metainfo summary files
for meta_filepath in \
    "${phenotypes_filepath}" \
    "${variants_filepath}" \
    "${biomarkers_filepath}";
do
    metafile=$( basename "${meta_filepath}" )
    echo "Get ${metafile}"
    if [[ ! -f "${meta_filepath}" ]]; then
        awsurl=$( awk -v FPAT='[^,]*|("([^"]|"")*")' \
                      -v fcol="${header_cols["File"]}" \
                      -v fname="${metafile}" \
                      -v awscol="${header_cols["AWSFile"]}" \
                      '{ if ($fcol == fname) print $awscol }' "${manifest_nodos_filepath}" )
        [[ ! -z "${awsurl}" ]] && wget -O "${meta_filepath}" ${awsurl} || \
            { echo "ERROR finding url of ${metafile}"; exit 1; }
    fi
    # TO-DO: Check MD5
    [[ -f "${meta_filepath%.bgz}" ]] || gunzip -c "${meta_filepath}" > "${meta_filepath%.bgz}"
done

# select phenotypes from metadata
_select_phenotypes_from_metadata \
    "${phenotypes_filepath}" \
    "${npd_selection_infopath}" \
    "${npd_exclusion_infopath}" \
    "${selected_phenotypes_filepath}"

# download phenotypes
tail -n +2 "${selected_phenotypes_filepath}" | cut -f1 | while read -r pcode
do
    awsinfo=$( awk -v FPAT='[^,]*|("([^"]|"")*")' \
                   -v icol="${header_cols["PhenotypeCode"]}" \
                   -v sexcol="${header_cols["Sex"]}" \
                   -v pcode="${pcode}" \
                   -v awscol="${header_cols["AWSFile"]}" \
                   -v md5col="${header_cols["md5s"]}" \
                   '{ if ($icol == pcode && $sexcol == "both_sexes" ) { printf "%s#%s", $awscol, $md5col } }' \
                   "${manifest_nodos_filepath}" )
                   #'BEGIN { count = 0 } 
                   #       { if ($icol == pcode && $sexcol == "both_sexes" ) { ++count; print $awscol } }
                   # END { print count }' \
    #urlcount=$( awk '{print $NF}' <<< "${awsinfo}" )
    urlcount=$( wc -w <<< "${awsinfo}" )
    [[ "${urlcount}" == 1 ]] && infoselect="${awsinfo}" || \
        infoselect=$( awk '{ for (i=1; i<=NF; i++) { if ( $i ~ /^http.*both_sexes\.v2.*$/ ) print $i} }' <<< "${awsinfo}" )
    awsurl=${infoselect%%\#*}
    md5hash=${infoselect##*\#}
    outfile="${datadir}/${pcode}.tsv.bgz"
    # getting md5s turned out not to be helpful
    # because md5s do not match.
    [[ ! -f ${outfile} ]] && wget -O "${outfile}" "${awsurl}"
done
