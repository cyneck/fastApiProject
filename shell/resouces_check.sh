#!/bin/bash
echo "start..."

filename="ns.txt"
result="ns_resource.txt"

kubectl get ns -A |awk '{print $1}'|grep -vi "NAME" > $filename

while read line
do
  labels=`kubectl get ns $line -o jsonpath='{$.metadata.labels}'`
  echo $line  ${labels} >> $result
done < $filename
rm $filename -f