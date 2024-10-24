versao=$(git rev-parse HEAD | cut -c 1-7)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 864981753284.dkr.ecr.us-east-1.amazonaws.com
docker build -t meddiflux .
docker tag meddiflux:latest 864981753284.dkr.ecr.us-east-1.amazonaws.com/meddiflux:$versao
docker push 864981753284.dkr.ecr.us-east-1.amazonaws.com/meddiflux:$versao
rm .env 2> /dev/null
./gerar-compose.sh
rm meddiflux.zip
zip -r meddiflux.zip docker-compose.yml
