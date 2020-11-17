#!/bin/bash
#this script converts MAME exported Galaksija memory dumps into gtp files used to store Galaksija tapes and for use in emulators
#requires xxd to convert to hex bin
#hexdump is exported from MAME using command: "dump $filename,$startaddress (2C36),$programlength(in hex),1 (byte grouping),0 (no ASCII interpretation)"
D2B=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}) #for binary conversion
dump=$1 #grabs the file
temp=/tmp/temp.hex
temp_chksum=/tmp/temp.chksum
temp_chksum2=/tmp/temp.chksum2
output=/tmp/output
name=`echo "$1" | cut -d'.' -f1` #removes file extension for name
gtp="$name.gtp" #defines output file name
hexname=`echo -n $name | od -A n -t x1` #converts file name to hex
namelength=${#name} #calculates length of name
length=$(($namelength +1)) #adds 1 to length of name
a='10' #first byte of gtp
b="$(printf '%02x\n' $length)" #file name length (+1) in hex. Second byte (b) is number of letters in name +1
sed 's/^.....//' $dump > $temp #removes addresses from MAME generated dump because they mess with xxd
tempextract=`cat $temp`
echo "${mem}"
c='000000' #follows file name length and preceeds file name
d='0000'
f='FC01' #need to grab automatically, length of program?
e='0000'
g='A5362C' #follows file name and preceeds code. Not sure yet how you calculate.
h="${tempextract:8:5}" #need to grab automatically
j="FF"
chksum="${g}${h}"
echo "$chksum $(cat $temp)" > $temp_chksum
cat $temp_chksum | tr -d '\040\011\012\015' > $temp_chksum2 #removes spaces from chksum
#cat $temp_chksum2
sed -e "s/.\{2\}/&\n/g" $temp_chksum2 > $temp_chksum #newlines to chksum
sed -i -e 's/^/0x/' $temp_chksum # adding 0x to hex in prep for conversion
cat $temp_chksum
./decimal.sh $temp_chksum > $temp_chksum2 #decimal conversion
cat $temp_chksum2
sum=`awk '{ sum += $1 } END { print sum }' $temp_chksum2 ` #summation
echo $sum
#expr $sum % 256 > $temp_chksum
mod=`expr $sum % 256`
echo $mod
binary=`echo ${D2B[$mod]}`
echo $binary
binary2=`python 2s.py $binary`
hexchksm=`printf '%x\n' "$((2#$binary2))"`
i=`expr $hexchksm - 1`
echo $i
gtpaddon="${a}${b}${c}${hexname}${d}${f}${e}${g}${h}`cat ${temp}`${i}${j}" #combines hex to add before dump for gtp compatibility
echo $gtpaddon > $output
#echo "$gtpaddon $(cat $output)" > $output
cat $output
xxd -r -p $output $gtp #exports dump to gtp file


