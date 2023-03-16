#!/bin/bash
echo "Project '${1}' computer during ${2}~${3}"
sql="select count(id) from tione.ti_train_job where ti_project_id='${1}' and status='Completed' and start_time>='${2} 00:00:00' and end_time<='${3} 23:59:59'"
mysql -utibase -p'iv:O_o>8uLkM' -h10.238.15.150 -BA -e "${sql}"  > tione-ti_train_job.txt

cat tione-ti_train_job.txt
rm tione-ti_train_job.txt
echo "End!"
