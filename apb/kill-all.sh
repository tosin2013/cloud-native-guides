#!/bin/bash
if [[ -z $1 ]]; then
  echo "USAGE: $0 projectname"
  exit 1
fi

PROJECT=$1

oc project coolstore1
oc delete all,configmap,pvc,serviceaccount,rolebinding  --selector app=catalog -n coolstore1
sleep 3s
oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=gateway -n coolstore1
sleep 3s
oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=inventory -n coolstore1
sleep 3s
oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=jenkins-ephemeral -n coolstore1
sleep 3s
oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=web -n coolstore1
sleep 3s
oc delete secret catalog -n coolstore1
oc delete secret inventory -n coolstore1
oc project ${PROJECT} -n coolstore1
oc project coolstore1-monitoring
oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=grafana -n coolstore1-monitoring
sleep 3s
oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector k8s-app=prometheus-operator -n coolstore1-monitoring
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
oc delete project ${PROJECT}
