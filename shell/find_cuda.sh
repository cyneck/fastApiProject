#!/bin/bash

# 方法一
function get_all_pod_python() {
  result="pip3_list.txt"
  for ns in $(kubectl get ns -o name | grep -E "/ns-|/project-"); do
    for pod in $(kubectl get pod -n ${ns#namespace/} -o name); do
      set -e
      kubectl exec -it -n ${ns#namespace/} ${pod#pod/} -- bash -c 'pip3 list --format=columns' >> ${result}
      set +e
      echo ${ns#namespace/} ${pod#pod/} >>${result}
    done
  done
}

# 方法二

function read_pod_python() {
  filename="ns_pod.txt"
  result="pip3_list.txt"
  while read -r ns_pod; do
    namespace=$(echo $ns_pod | cut -d' ' -f1)
    pod=$(echo ${ns_pod} | cut -d' ' -f2)
    kubectl exec -n ${namespace} ${pod} -- sh -c 'pip3 list --format=columns|| echo "Pip not found!" ' >>${result}
    echo "${namespace} ${pod}" >>${result}
  done <$filename
}

read_pod_python
