ECR_REGISTRY="898342295884.dkr.ecr.us-east-2.amazonaws.com"
aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin $ECR_REGISTRY
docker build -t bia .
docker tag bia:latest $ECR_REGISTRY/bia:latest
docker push $ECR_REGISTRY/bia:latest
