#!/bin/bash
echo "start..."

filename="ns_pod.txt"
result="ns_pod_qos.txt"

kubectl get pod -A |awk '{print $1,$2}'|grep -vi "namespaces*" > $filename

while read line
do
  qos=`kubectl get pod -n $line -o jsonpath='{$.status.qosClass}'`
  echo $line  ${qos} >> $result
done < $filename
rm $filename -f
