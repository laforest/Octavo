#! /bin/bash

for i in $* 
do
    echo $i
    j=`basename $i .eps`.png
    convert -density 600 -alpha off -depth 1 $i $j
done

