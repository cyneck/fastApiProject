#!/bin/bash
## day为需要备份的天数
day=3
time=$(date "+%Y%m%d_%H%M%S")
echo $time
es_backup(){
curl -X PUT -u elastic:elastic "localhost:8200/_snapshot/ti_datarepo_backup_repository/snapshot_${time}?wait_for_completion=true&pretty" -H 'Content-Type: application/json' -d'
{
  "indices": "tag_template,dataset_info_index,dataset_*"
}
'
}
es_backup_delete(){
bkday=`curl -X GET -u elastic:elastic "localhost:8200/_snapshot/ti_datarepo_backup_repository/_all?pretty"  |grep -w "sna
pshot" |awk -F"\"" '{print$4}' |wc -l`
if [ "$bkday" -gt "$day" ];then
    bkday=$(expr $bkday - $day)
   echo $bkday
   for i in `curl -X GET -u elastic:elastic "localhost:8200/_snapshot/ti_datarepo_backup_repository/_all?pretty"  |grep -
w "snapshot" |awk -F"\"" '{print$4}' |head -n +$bkday`
   do  curl -X DELETE -u elastic:elastic "localhost:8200/_snapshot/ti_datarepo_backup_repository/$i"
   done
else
    exit 0
fi
}
case $1 in
    esbk)
           es_backup
           ;;
    esdel)
           es_backup_delete
           ;;
       *)
        echo "usage: $0 <esbk|esdel>"
          ;;
esac