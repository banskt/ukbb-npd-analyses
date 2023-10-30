#!/usr/bin/env bash

# Neale lab GWAS manifest
# Download CSV file of the manifest
# https://docs.google.com/spreadsheets/d/1kvPoupSzsSFBNSztMzl04xMoSC3Kcx3CrjVf4yBmESU/edit?usp=drive_link
# From the Excel file, download the spreadsheet titled "Manifest 201807"

manifest_filename="UKBB_GWAS_Imputed_v3_File_Manifest_Release_20180731.csv"

## =========================
## Setup directory structure
## =========================
datadir="/gpfs/commons/groups/knowles_lab/data/gwas/ukbb.imputed_v3.neale"
workdir="/gpfs/commons/home/sbanerjee/work/npd/UKBB"
metadir="${workdir}/metadata"
rawdata_dir="${datadir}/1_raw"
signif_snps_dir="${datadir}/2_signif"
all_assoc_dir="${datadir}/3_all_assoc"
unzip_dir="${datadir}/9_unzipped_summary"
## =========================
manifest_filepath="${workdir}/${manifest_filename}"
manifest_nodos_filepath="${workdir}/${manifest_filename%.csv}_nodos.csv"

# these files / directories are required for analysis
mkdir -p "${metadir}" "${rawdata_dir}" "${signif_snps_dir}" "${unzip_dir}" "${all_assoc_dir}"
[[ ! -f "${manifest_nodos_filepath}" ]] && sed 's///g' "${manifest_filepath}" > "${manifest_nodos_filepath}"

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
