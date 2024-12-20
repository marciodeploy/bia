source utils.sh
MEDDIFLUX_API_URL=$1

versao=$(git rev-parse HEAD | cut -c 1-7)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 864981753284.dkr.ecr.us-east-1.amazonaws.com
checar_ultimo_comando
MEDDIFLUX_API_URL=$MEDDIFLUX_API_URL docker compose -f docker-compose-build-eb.yml build meddiflux
docker tag meddiflux:latest 864981753284.dkr.ecr.us-east-1.amazonaws.com/meddiflux:$versao
docker push 864981753284.dkr.ecr.us-east-1.amazonaws.com/meddiflux:$versao
rm .env 2> /dev/null
./gerar-compose.sh
rm meddiflux.zip
zip -r meddiflux.zip docker-compose.yml
git checkout docker-compose.yml
