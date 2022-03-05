#!/bin/bash

split -l$((`wc -l < more_1to20.txt`/31)) more_1to20.txt more_1to20.split -d
ls more_1to20.split* > more_1to20.split.filelist
./calref more_1to20.split.filelist more
rm -rf more_1to20.split*
