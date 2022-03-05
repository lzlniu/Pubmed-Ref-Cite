#!/bin/bash
#PBS -N sel_pmid
#PBS -e sel_pmid.err
#PBS -o sel_pmid.out
#PBS -l walltime=24:00:00

work="/home/projects/ku_10024/people/zelili/xmler"
pmid="/home/projects/ku_10024/people/zelili/tagger_test/all_pmid.txt"
cd $work

for i in $(cat $pmid); do
grep "^${i}\b" $work/sorted_citation_counts.tsv >> $work/sameasSJR_citation_counts.tsv #awk '{print $2}'
done

