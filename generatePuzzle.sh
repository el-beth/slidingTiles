#!/bin/bash

# this sorta works, but when shuffling, it goes backwards so high iteration counts are necessary.

# declare -a init;
# for i in {0..8};
# do
# 	init[$i]=$((i+1));
# done;
# init[8]=0;
declare -a init=([0]="1" [1]="2" [2]="3" [3]="4" [4]="5" [5]="6" [6]="7" [7]="8" [8]="0");
declare tileIndex=8 iterationCount=40;
function flattenCoordinate(){
	if ( [ "${1}" -ge 0 ] && [ "${1}" -le 8 ] && [ "${2}" -ge 0 ] && [ "${1}" -le 8 ] );
	then
		declare i="${1}" j="${2}";
		echo "$((i*3+j))";
	fi
}

function foldCoordinate(){
	if ( [ "${1}" -ge 0 ] && [ "${1}" -le 8 ] );
	then
		declare i="${1}";
		echo "$((i/3)) $((i%3))";
	fi;
}


function generateNeighbours(){
	# start work here, if i=2, number of neighbours is 2
	# input is a vector index, outout are vector indices
	declare b=0 I=${1} a i j;
	a=$(foldCoordinate "${I}");
	i=$(cut -c 1 <<< "${a}");
	j=$(cut -c 3 <<< "${a}");
	declare -a neighs

	[ $((j-1)) -ge 0 ] && neighs[b]=$(flattenCoordinate "${i}" "$((j-1))") && b=$((b+1));
	[ $((j+1)) -le 2 ] && neighs[b]=$(flattenCoordinate "${i}" "$((j+1))") && b=$((b+1));
	[ $((i-1)) -ge 0 ] && neighs[b]=$(flattenCoordinate "$((i-1))" "${j}") && b=$((b+1));
	[ $((i+1)) -le 2 ] && neighs[b]=$(flattenCoordinate "$((i+1))" "${j}") && b=$((b+1));

	for i in `seq 0 ${b}`;
	do
		printf "${neighs[i]} ";
	done
	printf '\n';
}

function countNeighbours(){
	local neighbours=$(generateNeighbours "${1}");
	echo "$(($(wc -c <<< `sed -Ee 's/ //g' <<< "${neighbours}"`)-1))";
}

function printGameState(){
	for i in {0..2}
	do
		printf "+---+---+---+\n| ${init[$((i*3))]} | ${init[$((i*3+1))]} | ${init[$((i*3+2))]} |\n";
	done
	printf "+---+---+---+\n";
}

function shuffle(){
	local neighbours=$(generateNeighbours "${tileIndex}");
	local numberOfNeighbours="$(countNeighbours "${tileIndex}")";
	local neighbourPickIndex=$((RANDOM%numberOfNeighbours+1));
	local slideChoice=$(cut -c "${neighbourPickIndex}" <<< `sed -Ee 's/ //g' <<< "${neighbours}"`);
	init[${tileIndex}]=${init[${slideChoice}]};
	init[${slideChoice}]=0;
	tileIndex="${slideChoice}";
}

function iterate(){
	for i in `seq ${iterationCount}`
	do
		shuffle;
	done
}

iterate;
printGameState;