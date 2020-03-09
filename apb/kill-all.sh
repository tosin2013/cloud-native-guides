#!/bin/bash
if [[ -z $1 ]]; then
  echo "USAGE: $0 projectname"
  exit 1
fi

PROJECT=$1

for i in {1..5}
do
  echo  "oc project coolstore${i}"
  oc project coolstore${i}
  oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=catalog -n coolstore${i}
  sleep 3s
  oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=gateway -n coolstore${i}
  sleep 3s
  oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=inventory -n coolstore${i}
  sleep 3s
  oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=jenkins-ephemeral -n coolstore${i}
  sleep 3s
  oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=web -n coolstore${i}
  sleep 3s
  oc delete secret catalog -n coolstore${i}
  oc delete secret inventory -n coolstore${i}
  oc delete project coolstore${i}
  sleep 3s
  echo  "oc project infra${i}"
  oc  project infra${i}
  oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=guides-codeready -n infra${i}
  oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector k8s-app=prometheus-operator -n infra${i}
  oc delete project infra${i}
done

ansible-playbook -vvv playbooks/deprovision.yml        -e namespace=$(oc project -q)        -e openshift_token=$(oc whoami -t)        -e openshift_master_url=$(oc whoami --show-server)


/*
sleep 3s
oc delete project coolstore1-monitoring
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=codeready -n ${PROJECT}
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=codeready-operator -n ${PROJECT}
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=etherpad -n ${PROJECT}
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=gogs -n ${PROJECT}
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=nexus -n ${PROJECT}
apb bundle deprovision cloud-native-workshop-apb -n ${PROJECT} --follow
oc project istio-system
oc delete servicemeshcontrolplanes -n istio-system controlplanes.istio.openshift.com
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=elasticsearch -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=galley -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=grafana -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=istio-egressgateway
 -n istio-system
 sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=istio-ingressgateway
 -n istio-system
 sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=istio-mixer -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=jaeger -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=kiali -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=pilot -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=prometheus -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=security -n istio-system
sleep 3s
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=sidecarInjectorWebhook -n istio-system
sleep 60s
oc delete project istio-system
oc project  istio-operator
oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector name=istio-operator -n istio-operator
sleep 60s
oc delete project  istio-operator
*/
