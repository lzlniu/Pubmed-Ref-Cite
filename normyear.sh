#!/bin/bash
#PBS -N normyear
#PBS -e normyear.err
#PBS -o normyear.out
#PBS -l walltime=24:00:00

work="/home/projects/ku_10024/people/zelili/xmler"
pmid_year="pmid_year.tsv"
citations="sorted_all_citation_counts.tsv"
output="normalized_citation_counts.tsv"

cd $work
python ${work}/normyear.py ${work}/${pmid_year} ${work}/${citations} ${work}/${output}

#for year in $(awk -F '\t' '{print $2}' ${work}/sorted.tmp | sort | uniq | sed '/^$/d'); do
#	let citesum=0
#	for pmid in $(grep -P "\t${year}\t" ${work}/sorted.tmp | awk '{print $1}'); do
#		cite=`grep -P "^${pmid}\t" ${work}/sorted_all_citation_counts.tsv | awk '{print $NF}'`
#		if [ -z "$cite" ]; then let cite=0; fi
#		((citesum=citesum + cite))
#	done
#done

