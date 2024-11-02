ambientedeploy=$1

echo 'export PATH="/home/ec2-user/.ebcli-virtual-env/executables:$PATH"' >> ~/.bash_profile && source ~/.bash_profile

if [ "$ambientedeploy" = "dev" ]; then
    echo "Ambiente de Desenvolvimento Detectado"
    ./build.sh "http://meddiflux-d.us-east-1.elasticbeanstalk.com"
    eb deploy meddiflux-d --staged
elif [ "$ambientedeploy" = "prod" ]; then
    echo "Ambiente de Produção Detectado"
    ./build.sh "http://meddiflux-p.us-east-1.elasticbeanstalk.com"
    eb deploy meddiflux-p --staged
else
    echo "Ambiente desconhecido. Saindo..."
    exit 1
fi
