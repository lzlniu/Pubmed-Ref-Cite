#!/bin/bash
g++ calref.cpp -o calref -std=c++11 -pthread
for i in `seq 1 1000`; do
	#./calref filelist.txt xxx >> testtime.txt
	./calref 1to20.txt xxx >> testtime.txt
done
awk -F ':' '{sum+=$2}END{print "mean time among 1000 tests:",sum/NR}' testtime.txt
rm -rf testtime.txt
#cat xxx
#rm -rf xxx
