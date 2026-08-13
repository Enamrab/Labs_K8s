#!/bin/bash

#Author: Enam Rab
#Date created: 28/04
#Last modified: 28/04

#Description:
#Converts Fahrenheit to Celcius and vice-versa

#Usage:
#Demonstrate the use of getopts command using while loop in bash

echo "Welcome to Temp converter!"

while getopts "f:c:" opt; do
	case "$opt" in
		f) result=$(echo "scale=2; ($OPTARG - 32) * (5/9)" | bc );;
		c) result=$(echo "scale=2; ($OPTARG * (9/5)) + 32" | bc );;
		\?) echo "You entered in valid option" ;;
	esac
done
echo "result is: $result"
