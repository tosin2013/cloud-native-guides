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
oc adm policy add-cluster-role-to-user cluster-admin $username${i}

cat > prometheus-subscription.yml<<YAML
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  generateName: prometheus-
  namespace: $projectname${i}-monitoring
spec:
  source: rh-operators
  name: prometheus
  startingCSV: prometheusoperator.0.22.2
  channel: preview
YAML

cat >prometheus-deployment.yml<<YAML
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: server
  labels:
    prometheus: k8s
  namespace: $projectname${i}-monitoring
spec:
  replicas: 2
  version: v2.3.2
  serviceAccountName: prometheus-k8s
  securityContext: {}
  serviceMonitorSelector:
    matchExpressions:
      - key: k8s-app
        operator: Exists
  ruleSelector:
    matchLabels:
      role: prometheus-rulefiles
      prometheus: k8s
  alerting:
    alertmanagers:
      - namespace: $projectname${i}-monitoring
        name: alertmanager-main
        port: web
YAML

cat << EOF | oc create -n "$projectname${i}" -f -
kind: Service
apiVersion: v1
metadata:
  name: throntail-inventory
  labels:
    app: throntail-inventory
    team: backend
spec:
  selector:
    app: inventory
  ports:
  - name: web
    port: 8080
EOF

cat >backend-monitor.yml<<YAML
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: throntail-inventory
  labels:
    k8s-app: throntail-inventory
  namespace: $projectname${i}-monitoring
spec:
  namespaceSelector:
    matchNames:
      - $projectname${i}
  endpoints:
    - interval: 30s
      path: /metrics
      port: 8080/tcp
  selector:
    matchLabels:
      app: inventory
YAML

oc create -f prometheus-subscription.yml
oc create -f prometheus-deployment.yml


cat >tmp.sh<<EOF
#!/bin/bash
oc adm policy add-role-to-user view system:serviceaccount:$projectname${i}-monitoring:prometheus-k8s -n $projectname${i}
EOF

bash -x tmp.sh
oc create -f backend-monitor.yml
rm prometheus-subscription.yml
rm prometheus-deployment.yml
rm tmp.sh

SVC_UP=$(oc get svc -n $projectname${i}-monitoring)
while true; do
  if [[ -z $SVC_UP ]]; then
    echo "waiting for prometheus service to be created"
  else
    oc get svc -n $projectname${i}-monitoring
    break
  fi
  sleep 15s
  SVC_UP=$(oc get svc -n $projectname${i}-monitoring)
done
oc expose svc/prometheus-operated -n $projectname${i}-monitoring



### Confgiure grafana
oc create -f apb/playbooks/tasks/grafana-claim-persistentvolumeclaim.yaml -n $projectname${i}-monitoring
oc create -f apb/playbooks/tasks/grafana.yaml -n $projectname${i}-monitoring
oc create -f apb/playbooks/tasks/grafana-ip-service.yaml -n $projectname${i}-monitoring
oc expose service/grafana-ip-service -n $projectname${i}-monitoring

```
done

for (( i = $begin; i <= $count; i++ )); do
  oc login "$hostname" --insecure-skip-tls-verify -u "$username${i}" -p "$password"
  oc process -f playbooks/tasks/coolstore-template.yaml  -e APPLICATION_NAME=$projectname${i}-monitoring -n $projectname${i} | oc create -f -
done
