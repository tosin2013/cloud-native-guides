#!/bin/bash
# scripts for workshop management
if ! $(oc whoami &>/dev/null); then
 printf "%s\n" "###############################################################################"
 printf "%s\n" "#  MAKE SURE YOU ARE LOGGED IN TO AN OPENSHIFT CLUSTER:                       #"
 printf "%s\n" "#  $ oc login https://your-openshift-cluster:8443                             #"
 printf "%s\n" "###############################################################################"
 exit 1
fi

hostname=
password=openshift
username=user
begin=1
count=1
pause=5
projectname=coolstore

for (( i = $begin; i <= $count; i++ )); do
  oc login "$hostname" --insecure-skip-tls-verify -u "$username${i}" -p "$password"
  oc process -f playbooks/tasks/coolstore-template.yaml -n $projectname${i} | oc create -f -
done
