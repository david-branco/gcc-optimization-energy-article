#!/bin/bash

declare -a progs=("bzip" "bzip2" "grades" "oggenc" "pbrt" "mmc")
declare -a flags=("-O0" "-O1" "-O2" "-O3" "-Ofast")

gcc -O2 -Wall -o rapl-read rapl-read.c -lm

for PROG in "${progs[@]}"
do
	echo "Analysing: $PROG"
	rm -rf outputs/$PROG
	mkdir outputs/$PROG

	for FLAG in "${flags[@]}"
	do
		mkdir outputs/$PROG/$FLAG
		perl -pi -e "s/^CFLAGS.*/CFLAGS = $FLAG/" source_files/$PROG/Makefile

		echo -e "\t$FLAG"
		if [ "$1" == "-e" ]; then 
			echo -e "\tCompiling $PROG"
			make -C source_files/$PROG/ &> outputs/$PROG/compilation$FLAG.txt
		fi

		for i in {1..100}
		do 
			printf "$i "
			if [ "$1" == "-e" ]
				then
					sudo ./rapl-read -c 1 -t -e source_files/$PROG/$PROG &> outputs/$PROG/$FLAG/output$i.txt
				else 
					sudo ./rapl-read -c 1 -t -m source_files/$PROG -s source_files/$PROG/$PROG.c &> outputs/$PROG/$FLAG/output$i.txt
			fi			
		done
		echo
	done
	echo
done

#perl charts.pl