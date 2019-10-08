#!/bin/bash
set -xe
if [[ -z $1 ]]; then
  echo "USAGE: $0 projectname"
fi

PROJECT=$1

oc new-project $PROJECT
apb bundle prepare
oc new-build --binary=true --name workshop -n $PROJECT
oc start-build --follow --from-dir . workshop -n $PROJECT
apb registry remove my-registry
apb registry add my-registry --type local_openshift --namespaces $PROJECT
apb bundle provision cloud-native-workshop-apb -n $PROJECT --follow

