#!/bin/bash
if [[ -z $1 ]]; then
  echo "USAGE: $0 projectname"
  exit 1
fi

if ! $(oc whoami &>/dev/null); then
 printf "%s\n" "###############################################################################"
 printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER:                       #"
 printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
 printf "%s\n" "###############################################################################"
 exit 1
fi

function deleteallprojects(){
  for i in {1..5}
  do
  if $( oc project coolstore${i} &>/dev/null); then
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
   fi 

   if  $( oc project infra${i} &>/dev/null); then
    echo  "oc project infra${i}"
    oc  project infra${i}
    oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector app=guides-codeready -n infra${i}
    oc delete  all,configmap,pvc,serviceaccount,rolebinding  --selector k8s-app=prometheus-operator -n infra${i}
    oc delete project infra${i}
   fi
    for i in $( kubectl get ns | grep Terminating | awk '{print $1}'); do echo $i; kubectl get ns $i -o json| jq "del(.spec.finalizers[0])"> "$i.json"; curl -k -H "Authorization: Bearer $(oc whoami -t)" -H "Content-Type: application/json" -X PUT --data-binary @"$i.json" "$(oc config view --minify -o jsonpath='{.clusters[0].cluster.server}')/api/v1/namespaces/$i/finalize"; done
  done

}

function cleanmain(){
  PROJECT=$1
  oc project ${PROJECT}
  ansible-playbook -vvv playbooks/deprovision.yml        -e namespace=$(oc project -q)        -e openshift_token=$(oc whoami -t)        -e openshift_master_url=$(oc whoami --show-server)
  oc delete project ${PROJECT}
}

deleteallprojects
cleanmain  $1