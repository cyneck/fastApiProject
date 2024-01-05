#!/bin/bash

# 清空输出文件
> deployments.txt

# 获取所有命名空间
namespaces=$(kubectl get namespaces -o=jsonpath='{.items[*].metadata.name}')

# 遍历命名空间
for namespace in $namespaces; do
  # 获取当前命名空间下的Deployment
  deployments=$(kubectl get deployment -n "$namespace" -o=jsonpath='{.items[*].metadata.name}')
  for deployment in $deployments; do
    # 获取Deployment的Volumes配置
    volumes=$(kubectl get deployment "$deployment" -n "$namespace" -o=jsonpath='{.spec.template.spec.volumes[?(@.hostPath)]}')
    # 检查是否有Volumes配置
    if [ -n "$volumes" ]; then
      # 遍历Volumes配置
      while read -r volume; do
        # 检查Volume的类型是否为hostPath
        if echo "$volume" | grep -q '"hostPath":'; then
          # 提取hostPath类型的path值
          path=$(echo "$volume" | jq -r '.hostPath.path')
          # 检查 path 是否为空，如果为空，则尝试提取
          if [ -z "$path" ]; then
            # 提取 path 的值
            path=$(echo "$volume" | jq -r '.hostPath')
          fi
          path=$(echo "$path" | sed ':a;N;$!ba;s/\n/;/g')
          # 调试输出，检查变量的值
          # 检查 path 是否包含"/ti-platform-fs"字符串且非空
          if [[ -n "$path" ]] && [[ "$path" == *"/ti-platform-fs"* ]]; then
            # 如果包含有效路径，则将Deployment名称和路径写入输出文件
            echo "$namespace  $deployment $path-----$volume"
            echo "$namespace  $deployment $path" >> deployments.txt
          fi
        fi
      done <<< "$volumes"
    fi
  done
done

# 移除输出文件中的空行
#sed -i '/^[[:space:]]*$/d' deployments.txt

echo "查找完成，结果已保存在deployments.txt文件中"

