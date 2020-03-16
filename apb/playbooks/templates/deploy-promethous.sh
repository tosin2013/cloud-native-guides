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


cat >prometheus-additional.yaml<<EOF
- job_name: "throntail-inventory"
  static_configs:
      - targets: ["inventory.${projectname}.svc.cluster.local:8080"]
EOF

oc create secret generic additional-scrape-configs --from-file=prometheus-additional.yaml --dry-run -oyaml > additional-scrape-configs.yaml
oc create -f additional-scrape-configs.yaml 

cat <<EOF | oc create -f -
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  creationTimestamp: null
  labels:
    prometheus: server
    role: alert-rules
  name: prometheus-server-rules
spec:
  groups:
  - name: CPU Load Average Alert
    rules:
    - alert: "CPU Load Average able 0.1"
      expr: (base:cpu_system_load_average) > 0.1
      annotations:
        miqTarget: "LoadAverage"
        severity: "WARNING"
        url: "https://www.example.com/node_average_alerting"
        message: "Node {{$labels.instance}} is high"
EOF


cat <<EOF  |  oc create -f -
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  name: server
  labels:
    prometheus: k8s
  namespace: ${infraprojectname}
spec:
  securityContext: {}
  replicas: 1
EOF

cat >alertmanager.yaml<<EOF
global:
  resolve_timeout: 5m
route:
  group_by: ['job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 12h
  receiver: 'alert-buffer-wh'
receivers:
  - name: alert-buffer-wh
    webhook_configs:
    - url: http://localhost:9099/topics/alerts
EOF

oc create secret generic alertmanager-server --from-file=alertmanager.yaml

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
  alerting:
    alertmanagers:
      - namespace: ${infraprojectname}
        name: alertmanager-operated
        port: web
  version: v2.3.2
  serviceAccountName: prometheus-k8s
  securityContext: {}
  serviceMonitorSelector:
    matchExpressions:
      - key: k8s-app
        operator: Exists
  ruleSelector:
    matchLabels:
      role: alert-rules
      prometheus: server
  additionalScrapeConfigs:
    name: additional-scrape-configs
    key: prometheus-additional.yaml
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
cat <<EOF |  oc create  -n "${infraprojectname}"  -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  creationTimestamp: null
  labels:
    component: grafana
  name: grafana-claim
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
EOF

if [  ! -f grafana-configmap.yml  ]; then 
  curl -OL https://raw.githubusercontent.com/tosin2013/cloud-native-guides/82cf435c635aa5a96a32ea5f07361e2e3c25afd3/apb/playbooks/templates/grafana/grafana-configmap.yml
fi 
sed -i 's/    namespace:.*/    namespace: "'${infraprojectname}'"/g' grafana-configmap.yml
oc create configmap grafana-config --from-file=grafana-configmap.yml -n "${infraprojectname}"


cat <<EOF |  oc create  -n "${infraprojectname}"  -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: grafana
  name: grafana-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      component: grafana
  template:
    metadata:
      labels:
        component: grafana
    spec:
      volumes:
      - name: grafanaconfig
        configMap:
          name: grafana-config
      - name: grafana-claim
        persistentVolumeClaim:
          claimName: grafana-claim
      containers:
      - name: grafana
        image: grafana/grafana:latest
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 3000
        resources:
          limits:
            cpu: 500m
            memory: 2500Mi
          requests:
            cpu: 100m
            memory: 100Mi
        volumeMounts:
        - mountPath: /var/lib/grafana
          name: grafana-claim

EOF

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

oc adm pod-network join-projects --to=