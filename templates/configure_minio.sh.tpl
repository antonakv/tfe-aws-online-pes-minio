#!/usr/bin/env bash
mkdir -p /home/ubuntu/install

IPADDR=$(hostname -I | awk '{print $1}')

echo "
MINIO_ACCESS_KEY=\"${minio_access_key}\"
MINIO_VOLUMES=\"/usr/local/share/minio/\"
MINIO_OPTS=\"-C /etc/minio --address $IPADDR:9000\"
MINIO_SECRET_KEY=\"${minio_secret_key}\"
" > /etc/default/minio

sudo chown -R minio-user: /usr/local/share/minio

sudo systemctl enable minio
sudo systemctl start minio

mkdir ~/.aws

echo "
[default]
aws_access_key_id = \"${minio_access_key}\"
aws_secret_access_key = \"${minio_secret_key}\"
" > /home/ubuntu/.aws/credentials

aws s3api create-bucket --acl private --bucket $s3bucket  --endpoint-url $s3endpoint
