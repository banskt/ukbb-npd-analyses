#!/usr/bin/env bash

_select_phenotypes_from_metadata() {
    local phenotypefile
    local selectionfile
    local exclusionfile
    local outfile
    phenotypefile=$( realpath "${1}" )
    selectionfile=$( realpath "${2}" )
    exclusionfile=$( realpath "${3}" )
    outfile=$( realpath "${4}" )
    # create a temporary file for phenotype description
    basedir=$( dirname "${phenotypefile}" )
    tempdir=$( mktemp --tmpdir="${basedir}" -d tmp.phenotype.selection.XXX )
    trap "rm -rf ${tempdir}" EXIT INT QUIT TERM

    _tsvfile="${tempdir}/phenotypes.tsv"
    _descfile="${tempdir}/phenotypes_description.tsv"
    _pass01="${tempdir}/phenotypes_selection_pass01.tsv"
    _pass02="${tempdir}/phenotypes_selection_pass02.tsv"
    _intemp="${tempdir}/phenotypes_selection_tmp.tsv"

    # create tsv | dos2unix at source
    gunzip -c "${phenotypefile}" | sed 's///g' > "${_tsvfile}"
    # we need only the first 2 columns for selection
    cut -f1,2 "${_tsvfile}" > "${_descfile}"
    # select phenotypes using selectionfile
    while read -r mtext
    do 
        grep -i "${mtext}" "${_descfile}"
    done < "${selectionfile}" | sort | uniq > "${_pass01}"
    # exclude lines using exclusionfile
    cp "${_pass01}" "${_pass02}"
    while read -r mtext
    do
        grep -i -v "${mtext}" "${_pass02}" > "${_intemp}"
        mv "${_intemp}" "${_pass02}"
    done < "${exclusionfile}"
    # now, we have the selection, let us get back the full tsv
    head -n 1 "${_tsvfile}" > "${outfile}"
    cut -f1 "${_pass02}" | \
        while read -r -d$'\n' mtext
        do
            grep -w "^${mtext}" "${_tsvfile}"
        done >> "${outfile}"
    rm -rf "${tempdir}"
}
