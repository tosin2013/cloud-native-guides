#!/bin/bash
set -xe
if [[ -z $1 ]]; then
  echo "USAGE: $0 projectname"
  exit 1
fi

PROJECT=$1

oc new-project $PROJECT && oc project $PROJECT
 ansible-playbook -vvv playbooks/provision.yml        -e namespace=$(oc project -q)        -e openshift_token=$(oc whoami -t)        -e openshift_master_url=$(oc whoami --show-server)
#apb bundle prepare
#oc new-build --binary=true --name workshop -n $PROJECT
#oc start-build --follow --from-dir . workshop -n $PROJECT
#apb registry remove my-registry
#apb registry add my-registry --type local_openshift --namespaces $PROJECT
#apb bundle provision cloud-native-workshop-apb -n $PROJECT --follow


ansible-playbook -vvv playbooks/provision.yml        -e namespace=$(oc project -q)        -e openshift_token=$(oc whoami -t)        -e openshift_master_url=$(oc whoami --show-server) \
  --start-at-task="preconfigure projects for logging and monitoring"
