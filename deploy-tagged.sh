#!/bin/bash

set -e

# Configurações
ECR_REGISTRY="898342295884.dkr.ecr.us-east-2.amazonaws.com"
REGION="us-east-2"
CLUSTER="bia"
SERVICE="service-bia"
TASK_FAMILY="bia-tf"

# Obter tag do Git
GIT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "")
GIT_COMMIT=$(git rev-parse --short HEAD)

if [ -z "$GIT_TAG" ]; then
    echo "❌ Nenhuma tag encontrada no commit atual"
    echo "💡 Crie uma tag primeiro: git tag v1.0.0 && git push origin v1.0.0"
    exit 1
fi

echo "🏷️  Tag encontrada: $GIT_TAG"
echo "📦 Commit: $GIT_COMMIT"

# Login no ECR
echo "🔐 Fazendo login no ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

# Build da imagem
echo "🔨 Construindo imagem..."
docker build -t bia:$GIT_TAG .

# Tag e push
echo "📤 Enviando imagem para ECR..."
docker tag bia:$GIT_TAG $ECR_REGISTRY/bia:$GIT_TAG
docker tag bia:$GIT_TAG $ECR_REGISTRY/bia:latest
docker push $ECR_REGISTRY/bia:$GIT_TAG
docker push $ECR_REGISTRY/bia:latest

# Obter task definition atual
echo "📋 Obtendo task definition atual..."
TASK_DEF=$(aws ecs describe-task-definition --task-definition $TASK_FAMILY --region $REGION)

# Criar nova task definition com a imagem taggeada
echo "🔄 Criando nova task definition..."
NEW_TASK_DEF=$(echo $TASK_DEF | jq --arg IMAGE "$ECR_REGISTRY/bia:$GIT_TAG" '.taskDefinition | .containerDefinitions[0].image = $IMAGE | del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.requiresAttributes) | del(.placementConstraints) | del(.compatibilities) | del(.registeredAt) | del(.registeredBy)')

# Registrar nova task definition
NEW_REVISION=$(aws ecs register-task-definition --region $REGION --cli-input-json "$NEW_TASK_DEF" --query 'taskDefinition.revision' --output text)

echo "✅ Nova task definition registrada: $TASK_FAMILY:$NEW_REVISION"

# Atualizar serviço
echo "🚀 Atualizando serviço ECS..."
aws ecs update-service \
    --cluster $CLUSTER \
    --service $SERVICE \
    --task-definition $TASK_FAMILY:$NEW_REVISION \
    --region $REGION

# Aguardar estabilização
echo "⏳ Aguardando estabilização do serviço..."
aws ecs wait services-stable --cluster $CLUSTER --services $SERVICE --region $REGION

echo "🎉 Deploy concluído com sucesso!"
echo "📊 Tag: $GIT_TAG"
echo "🔢 Revision: $NEW_REVISION"
echo "🖼️  Imagem: $ECR_REGISTRY/bia:$GIT_TAG"
