#!/bin/bash

# Specify the desired volume size in GiB as a command-line argument. If not specified, default to 50 GiB.
SIZE=50

# Install necessary packages.
sudo apt-get update
sudo apt-get install -y jq awscli cloud-guest-utils

# Get the ID of the environment host Amazon EC2 instance.
INSTANCEID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Get the ID of the Amazon EBS volume associated with the instance.
VOLUMEID=$(aws ec2 describe-instances --instance-ids $INSTANCEID --query "Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId" --output text)

# Resize the EBS volume.
aws ec2 modify-volume --volume-id $VOLUMEID --size $SIZE

# Wait for the resize to finish.
echo "Waiting for volume modification to complete..."
while true; do
    STATUS=$(aws ec2 describe-volumes-modifications --volume-id $VOLUMEID --query "VolumesModifications[0].ModificationState" --output text)
    if [ "$STATUS" == "completed" ] || [ "$STATUS" == "optimizing" ]; then
        echo "Volume modification completed."
        break
    fi
    echo "Waiting for volume to be resized..."
    sleep 5
done

# Rewrite the partition table so that the partition takes up all the space that it can.
sudo lsblk
sudo growpart /dev/xvda 1

# Expand the size of the file system.
sudo resize2fs /dev/xvda1
