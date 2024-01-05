#!/bin/bash
echo "start..."

filename="test_nlp.txt"
result="result.txt"

while read line
do
  curl -XPOST  http://127.0.0.1/Call -H 'Content-Type: application/json'  -d '{"CallbackUrl":"http://word_seg_check","SubmitId":"ab5c6x2j4hl66d7v","RequestId":"p000087ht","Input":{"title":"'"$line"'"}}'
  sleep 10
  curl -XPOST  http://127.0.0.1/Get -H 'Content-Type: application/json' -d '{"SubmitId":"ab5c6x2j4hl66d7v","RequestId":"p000087ht"}' >> $result
  echo >> $result
done < $filename
echo "finish！"
