kubectl get pods --all-namespaces | grep Evicted | awk '{print $2}' | xargs kubectl delete pod