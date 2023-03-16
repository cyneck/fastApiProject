#!/bin/bash
echo "start..."

filename="ns_pod.txt"
result="ns_pod_qos.txt"

kubectl get pod -A -owide|grep -E "^ns-|^project-|^ai-media"|grep -v "filebeat"|awk '{print $1,$2}' > $filename

while read line
do
  volumes=`kubectl get pod -n $line -o jsonpath='{$.spec.volumes[*].hostPath.path}'`
  echo $line  ${volumes} >> $result
done < $filename
rm $filename -f
