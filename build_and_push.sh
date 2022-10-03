#!/bin/bash
set -x

# The name of our algorithm
algorithm_name=yolov7-gpu
#cd ../../Container

#ls
account=$(aws sts get-caller-identity --query Account --output text)
# Get the region defined in the current configuration (default to us-west-2 if none defined)
region=$(aws configure get region)
region=${region:-us-west-2}
fullname="${account}.dkr.ecr.${region}.amazonaws.com/${algorithm_name}:latest"
# If the repository doesn't exist in ECR, create it.
aws ecr describe-repositories --repository-names "${algorithm_name}" > /dev/null 2>&1
if [ $? -ne 0 ]
then
    aws ecr create-repository --repository-name "${algorithm_name}" > /dev/null
fi
# Get the login command from ECR and execute it directly
#$(aws ecr get-login-password --region ${region})
$(aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${account}.dkr.ecr.${region}.amazonaws.com)
# Get the login command from ECR in order to pull down the SageMaker PyTorch image
$(aws ecr get-login-password --registry-ids 520713654638 --region ${region})
# Build the docker image locally with the image name and then push it to ECR
# with the full name.
echo "Building $algorithm_name"
docker build  -t ${algorithm_name} . --build-arg REGION=${region} --shm-size=64g
docker tag ${algorithm_name} ${fullname}


#echo "Pushing ${fullname} to ECR..."
#docker push ${fullname}
