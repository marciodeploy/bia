ambientedeploy=$1

echo 'export PATH="/home/ec2-user/.ebcli-virtual-env/executables:$PATH"' >> ~/.bash_profile && source ~/.bash_profile

if [ "$ambientedeploy" = "dev" ]; then
    echo "Ambiente de Desenvolvimento Detectado"
    API_URL="http://d2yjzk3xfigg2e.cloudfront.net"
    ./build.sh $API_URL
    ./deploy_front.sh $API_URL $ambientedeploy
    eb deploy meddiflux-d --staged
elif [ "$ambientedeploy" = "prod" ]; then
    echo "Ambiente de Produção Detectado"
    API_URL="http://d5n84nhjdekrp.cloudfront.net"
    ./build.sh $API_URL
    ./deploy_front.sh $API_URL $ambientedeploy
    eb deploy meddiflux-p --staged
else
    echo "Ambiente desconhecido. Saindo..."
    exit 1
fi
