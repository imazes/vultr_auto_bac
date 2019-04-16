#!/bin/sh
echo ''

# 在这里设置密钥信息
key='xxx'
ip='xxx'

#根据ip获取 SUBID
# $key $ip
getsubid() {
curl -s -H \
"API-Key: $1" \
https://api.vultr.com/v1/server/list \
|sed -e 's/[{}]/\n/g' \
|grep $2 \
|grep -o "\"SUBID\"\:\"[0-9]*\"" \
|grep -o "[0-9]*"
}

#根据SUBID创建Snapshot
# $key $SUBID
createsnapshot() {
curl -s -H \
"API-Key: $1" \
https://api.vultr.com/v1/snapshot/create \
--data "SUBID=$2" \
--data "description="$ip"-daily"
}

#获取n天前的自动备份的 镜像ID
# $key $day
getsnapshotid() {
curl -s -H \
"API-Key: $1" \
https://api.vultr.com/v1/snapshot/list \
|sed -e 's/[{}]/\n/g' \
|grep $(date --date="$2 day ago" "+%Y-%m-%d") \
|grep ""$ip"-daily" \
|grep -o "\"SNAPSHOTID\"\:\"[0-9a-z]*\"\," \
|grep -o "\:\"[0-9a-z]*\"" \
|grep -o "[0-9a-z]*"
}

#根据镜像ID 删除镜像
# $key $snapshotid
delsnapshot() {
curl -s -H \
"API-Key: $1" \
https://api.vultr.com/v1/snapshot/destroy \
--data "SNAPSHOTID=$2"
}

subid=$(getsubid $key $ip)
createsnapshot $key $subid
# 删除四天前的镜像
snapshotid=$(getsnapshotid $key 4)
delsnapshot $key $snapshotid

echo ''
exit 0