#!/bin/bash
#PBS -N calref
#PBS -e calref.err
#PBS -o calref.out
#PBS -l nodes=1:ppn=40
#PBS -l mem=120gb
#PBS -l walltime=8:00:00

work="/home/projects/ku_10024/people/zelili/xmler"
data="/home/projects/ku_10024/people/zelili/xmler/refdata"

cat $data/sorted_*.tsv | sort -u -t$'\t' -k 1,1 | awk -F '\t' '{print $3}' | tr " " "\n" | sed '/^$/d' > $data/references.txt
split -l$((`wc -l < ${data}/references.txt`/31)) $data/references.txt $data/references.split -d
ls $data/references.split* > $work/list.txt
$work/calref $work/list.txt $work/citation_counts.tsv
#rm -rf $data/references.* $work/list.txt
