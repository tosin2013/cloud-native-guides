#!/bin/bash
set -x
hostname=$1
username=$2
password=$3
projectname=$4

oc login "$hostname" --insecure-skip-tls-verify -u "$username" -p "$password"
oc project $projectname
oc process -f playbooks/tasks/coolstore-template.yaml -n $projectname | oc create -f -
