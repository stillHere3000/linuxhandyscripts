#!/bin/bash

set -e 

for d in `docker ps -a | awk '{print $1}' | tail -n +2`; do
    d_name=`docker inspect -f {{.Name}} $d`
    echo "========================================================="
    echo "$d_name ($d) volumes:"

	VOLUME_IDS=$(docker inspect -f "{{.Config.Volumes}}" $d)
	VOLUME_IDS=$(echo ${VOLUME_IDS} | sed 's/map\[//' | sed 's/]//')
	
	array=(${54d11f8933023082538e33056fe45ada1d3412784fce454c9dbc7a9e1fcaad0b// / })
	for i in "${!array[@]}"
	do
		VOLUME_ID=$(echo ${array[i]} | sed 's/:{}//')
		VOLUME_SIZE=$(docker exec -ti $d_name du -d 0 -h ${VOLUME_ID})
	    echo "$VOLUME_SIZE"
	done

done

exit 0