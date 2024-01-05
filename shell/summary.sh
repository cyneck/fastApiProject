#!/bin/bash

echo "Project OCR summary during ${1}~${2}"

json="{\"RequestId\":\"1286bc2b-c1c3-f5f6-ab04-1f62568562b2\",\"Uin\":\"y0104189\",\"TiBusinessId\":22,\"TiProjectId\":62,\"BusinessId\":\"22\",\"AppGroupId\":\"62\",\"ServiceName\":\"youtu-private-general-vtx-ocr\",\"MetricName\":[\"apicall-total\"],\"StartTime\":\"${1}T00:00:00+08:00\",\"EndTime\":\"${2}T00:00:00+08:00\",\"Period\":43200}"

response=$(curl -s -X POST http://ti-ems-server.ti-base/DescribeAPICallerData -d "$json")

total=$(jq -r '.Response.DataPoints[0].Values|add' <<< "$response")

echo "OCR summary: $total"
