./build.sh
rm .env 2> /dev/null
rm docker-compose.yml
git status
eb deploy --staged
