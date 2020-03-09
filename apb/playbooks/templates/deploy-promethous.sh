#!/bin/bash
# scripts for workshop management
#set -xe

projectname=${1}
infraprojectname=${2}

oc project ${infraprojectname} || exit 1
cat <<EOF |  oc create -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  generateName: prometheus-
  namespace: ${infraprojectname}
spec:
  source: rh-operators
  name: prometheus
  startingCSV: prometheusoperator.0.22.2
  channel: preview
EOF

cat <<EOF |  oc create -f -
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  name: server
  labels:
    prometheus: k8s
  namespace: ${infraprojectname}
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
      - namespace: ${infraprojectname}
        name: alertmanager-main
        port: web
EOF

cat << EOF | oc create -n "${projectname}" -f -
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



oc adm policy add-role-to-user view system:serviceaccount:${infraprojectname}:prometheus-k8s -n ${projectname}


cat <<EOF |  oc create -f -
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: throntail-inventory
  labels:
    k8s-app: throntail-inventory
  namespace: ${infraprojectname}
spec:
  namespaceSelector:
    matchNames:
      - ${projectname}
  endpoints:
    - interval: 30s
      path: /metrics
      port: 8080/tcp
  selector:
    matchLabels:
      app: inventory
EOF


SVC_UP=$(oc get svc -n ${infraprojectname})
while true; do
  if [[ -z $SVC_UP ]]; then
    echo "waiting for prometheus service to be created"
  else
    oc get svc -n ${infraprojectname}
    break
  fi
  sleep 15s
  SVC_UP=$(oc get svc -n ${infraprojectname})
done
oc expose svc/prometheus-operated -n ${infraprojectname}

### Confgiure grafana
oc create -f grafana/grafana-claim-persistentvolumeclaim.yaml -n ${infraprojectname}
sed -i 's/    namespace:.*/    namespace: "'${infraprojectname}'"/g' grafana/grafana-configmap.yml
oc create configmap grafana-config --from-file=grafana/grafana-configmap.yml -n ${infraprojectname}
oc create -f grafana/grafana.yaml -n ${infraprojectname}
cat <<EOF |  oc create -f -
apiVersion: v1
kind: Service
metadata:
  name: grafana-ip-service
  namespace: ${infraprojectname}
  annotations:
      prometheus.io/scrape: 'true'
      prometheus.io/path:   /metrics
      prometheus.io/port:   '3000'
spec:
  type: ClusterIP
  selector:
    component: grafana
  ports:
  - port: 3000
    targetPort: 3000
EOF

oc expose service/grafana-ip-service -n ${infraprojectname}
