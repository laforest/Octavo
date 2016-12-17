#! /bin/bash

for i in $* 
do
    echo $i
    convert -density 600 -alpha off -depth 1 $i `basename $i .eps`.png
done

