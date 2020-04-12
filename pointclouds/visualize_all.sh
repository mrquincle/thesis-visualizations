#!/bin/bash

#algorithm=algorithm8
algorithm=jain_neal_split
#algorithm=triadic

path=../simulation-output/icmv/$algorithm

for dir in $path/*/; do
	for subdir in $dir/*/; do
		dname=$(basename "${subdir}")
		if [[ "$dname" != 'LATEST' ]]; then
			echo ${subdir}
			./visualize_single_fit.R ${subdir} $algorithm regression
		fi
	done	
done
