#!/bin/bash
IMAGE_NAME=$1
GENERATE_PASSWORDS=${2:true}

if [[ -z $IMAGE_NAME ]]
then
  echo 'Missing env-var IMAGE_NAME'
  exit 4
fi

source ./prepare_env.sh "$GENERATE_PASSWORDS"

echo Creating Template with name $TEMPLATE_NAME

if [[ -z "$SUBNET" ]]
then
  SUBNET_COMMAND=""
else
  SUBNET_COMMAND="--subnet=$SUBNET"
fi

gcloud beta compute instance-templates create-with-container $TEMPLATE_NAME \
  --tags=$TAGS --container-image=$IMAGE_NAME --machine-type=$INSTANCE_TYPE \
  --no-boot-disk-auto-delete --boot-disk-size=$DISK_SIZE --boot-disk-type=pd-ssd \
  --scopes=$SCOPES --network=$NETWORK  $SUBNET_COMMAND \
  --container-mount-host-path host-path=/mnt/stateful_partition/es-data,mount-path=/elasticsearch/data \
  --container-mount-host-path host-path=/mnt/stateful_partition/es-logs,mount-path=/elasticsearch/logs \
  --container-env-file=elastic.env \
  --metadata-from-file startup-script=instance-startup.sh \
  --project=$PROJECT_ID

echo Creating Instance Group

gcloud compute instance-groups managed create $TEMPLATE_NAME \
  --template=$TEMPLATE_NAME --size=$CLUSTER_SIZE --zone=$ZONE \
  --project=$PROJECT_ID
