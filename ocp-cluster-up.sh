oc cluster down

ORIGIN_HOME=$HOME/origin

if [ "$1" = "clear" ] ; then
    echo "cleaning openshift installation"
    for i in $(mount | grep openshift | awk '{ print $3}'); do sudo umount "$i"; done && sudo rm -rf $ORIGIN_HOME
fi

if [ "$CLEAN_DOCKER" = true ] ; then
    docker stop $(docker ps -a -q) -f
    docker rm $(docker ps -a -q) -f
    docker rmi $(docker images -q) -f
fi

iptables -F

oc cluster up --base-dir $ORIGIN_HOME --insecure-skip-tls-verify=true --server-loglevel=5 --public-hostname=$(hostname -I | awk '{print $1}')

export KUBECONFIG="$ORIGIN_HOME/kube-apiserver/admin.kubeconfig"
oc login -u system:admin
oc --config ${KUBECONFIG} adm policy add-cluster-role-to-user cluster-admin developer
oc login -u developer -p developer
oc new-project famartinrh
oc policy add-role-to-group system:image-puller system:serviceaccounts:enmasse-infra -n famartinrh
oc policy add-role-to-user system:image-puller system:serviceaccount:enmasse-infra:default -n famartinrh
