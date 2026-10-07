#!/bin/bash

#Running one command in background
echo "for loop demo";
for i in {1..10}
do
  echo $i;
  echo 
done

echo "now while loop demo"
#assigning a counter
counter=1
while [ $counter -le 10 ];
do
  echo $counter;
  (( counter++ )) ;
done

#creating an array as input from file
echo "creating an array as input from file"
while IFS= read -r line; 
do echo $line; 
  empty_arr+=($line); 
  echo "line added in array"; 
done <file.txt

#viewing the array contents
echo "viewing the array contents"
for line in "${empty_arr[@]}"; do echo $line; done

