#! /bin/bash

for i in $* 
do
    echo $i
    epstopdf $i
done

