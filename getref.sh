#!/bin/bash
#PBS -N getref

pubmed="/home/projects/ku_10024/data/databases/pubmed"
work="/home/projects/ku_10024/people/zelili/xmler"

cd $work
if [ ! -d $work/refdata ];then mkdir $work/refdata; fi
#if [ -f sorted.tmp ]; then rm -rf sorted.tmp; fi
#if [ -f sort.tmp ]; then rm -rf sort.tmp; fi
#if [ -f references.txt ]; then rm -rf references.txt; fi
#touch sorted.tmp
for i in $(ls ${pubmed}/pubmed21*.xml.gz | awk -F '/' '{print $NF}' | awk -F '.' '{print $1}' | awk -F 'n' '{print $NF}' | sort -rn); do
#mv sorted.tmp sort.tmp
#zcat ${pubmed}/pubmed21n${i}.xml.gz | perl pubmed.pl - | cat sort.tmp - | sed 's/|/\t|/g' | sort -u -t$'\t' -k 1,1 | sed 's/\t|/|/g' > sorted.tmp
echo "#!/bin/bash
#PBS -N parse${i}
#PBS -e parse_xml.err
#PBS -o parse_xml.out
#PBS -l walltime=4:00:00
cd ${work}
zcat ${pubmed}/pubmed21n${i}.xml.gz | perl ${work}/pubmed.pl - | sort -u -t$'\t' -k 1,1 > ${work}/refdata/sorted_${i}.tsv
" > $work/parse_xml.sh
qsub < $work/parse_xml.sh
done
rm -rf parse_xml.sh
#rm -rf sort.tmp
#sed 's/|/\t|/g' sorted.tmp | sort -u -t$'\t' -k 1,1 | sed 's/\t|/|/g' | sed -E 's/\S+\(.+?\)\s//g' | sed -E 's/ \n/\n/g' | awk -F '\t' '{print $3}' | sed '/^$/d' | tr " " "\n" > references.txt
#sed -i '/^$/d' | grep "^[0-9]*$" references.txt

#awk -F '\t' '{print $3}' | sed '/^$/d' | tr " " "\n" | sed '/^$/d' > references.txt

#grep "^[0-9]*$" references.txt > ref1.txt

#split -l$((`wc -l < references.txt`/31)) references.txt references.split -d
#ls ref1.split* > list.txt
#./calref list1.txt citation_counts.tsv
#rm -rf references.split* list.txt

