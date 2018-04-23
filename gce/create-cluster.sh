#!/bin/bash
IMAGE_NAME=$1

source ./prepare_env.sh

echo Creating Template with name $TEMPLATE_NAME

gcloud beta compute instance-templates create-with-container $TEMPLATE_NAME \
--tags=$TAGS --container-image=$IMAGE_NAME --machine-type=$INSTANCE_TYPE \
--no-boot-disk-auto-delete --boot-disk-size=$DISK_SIZE --boot-disk-type=pd-ssd \
--scopes=$SCOPES --network=$NETWORK  \
--container-mount-host-path host-path=/mnt/stateful_partition/es-data,mount-path=/elasticsearch/data \
--container-mount-host-path host-path=/mnt/stateful_partition/es-logs,mount-path=/elasticsearch/logs \
--container-env-file=elastic.env \
--metadata-from-file startup-script=../instance-startup.sh \
--project=$PROJECT_ID

echo Creating Instance Group

gcloud compute instance-groups managed create $TEMPLATE_NAME \
--template=$TEMPLATE_NAME --size=$CLUSTER_SIZE --zone=$ZONE \
--project=$PROJECT_ID