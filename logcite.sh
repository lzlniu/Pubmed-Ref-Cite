#!/bin/bash
#PBS -N logcite
#PBS -e logcite.err
#PBS -o logcite.out
#PBS -l walltime=8:00:00

echo Working directory is $PBS_O_WORKDIR
cd $PBS_O_WORKDIR

input="/home/projects/ku_10024/people/zelili/xmler/sorted_citation_counts.tsv"
#alpha="1"
for alpha in 1 1.718282 3 5 10; do
output="/home/projects/ku_10024/people/zelili/xmler/sorted_alllogalpha${alpha}_citation_counts.tsv"
python logcite.py $input $output $alpha
done

