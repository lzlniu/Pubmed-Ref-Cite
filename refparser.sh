#!/bin/bash

pubmed_path="/home/projects/ku_10024/data/databases/pubmed"
work_path="/home/projects/ku_10024/people/zelili/xmler"

cd $work_path

for i in $(ls ${pubmed_path}/pubmed21n*.xml.gz | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}'); do
echo "#!/bin/bash
#PBS -N refpar
#PBS -e refpar.err
#PBS -o refpar.out
#PBS -l walltime=8:00:00

cd $work_path
zgrep \"            <ArticleId IdType=\\\"pubmed\\\">\" ${pubmed_path}/${i}.xml.gz | grep -o '\\b[0-9]*\\b' > ${work_path}/data/${i}_reflist.txt
" > $work_path/refpar.sh
qsub < $work_path/refpar.sh
done

