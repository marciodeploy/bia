ambientedeploy=$1

echo 'export PATH="/home/ec2-user/.ebcli-virtual-env/executables:$PATH"' >> ~/.bash_profile && source ~/.bash_profile

if [ "$ambientedeploy" = "dev" ]; then
    echo "Ambiente de Desenvolvimento Detectado"
    API_URL="meddifluxd.hardcloud.com.br"
    ./build.sh $API_URL
    ./deploy_front.sh $API_URL $ambientedeploy
    eb deploy meddiflux-d --staged
elif [ "$ambientedeploy" = "prod" ]; then
    echo "Ambiente de Produção Detectado"
    API_URL="meddifluxp.hardcloud.com.br"
    ./build.sh $API_URL
    ./deploy_front.sh $API_URL $ambientedeploy
    eb deploy meddiflux-p --staged
else
    echo "Ambiente desconhecido. Saindo..."
    exit 1
fi
