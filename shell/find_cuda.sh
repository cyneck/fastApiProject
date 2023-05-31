#!/bin/bash

result="pip3_list.txt"

# 方法一
function get_all_pod_python() {
  for ns in $(kubectl get ns -o name | grep -E "/ns-|/project-"); do
    for pod in $(kubectl get pod -n ${ns#namespace/} -o name); do
      echo "pip3 packages in ${ns#namespace/} ${pod#pod/}:"
      kubectl exec -it -n ${ns#namespace/} ${pod#pod/} -- sh -c 'python3 --version && pip3 list --format=columns' >>$result
      if [ $? -eq 0 ]; then
        echo ${ns#namespace/} ${pod#pod/} >>$result
      else
        echo "失败"
      fi

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
    install_pip ${namespace} ${pod}
    kubectl exec -it -n ${namespace} ${pod} -- sh -c 'pip3 list --format=columns || echo "失败" ' >>${result}
    echo "${namespace} ${pod}" >>${result}
  done <$filename
}

read_pod_python
