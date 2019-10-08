# Configure Prometheus for Workshop


### Confgiure grafana
oc create -f apb/playbooks/tasks/grafana-claim-persistentvolumeclaim.yaml
oc create -f apb/playbooks/tasks/grafana.yaml
oc create -f apb/playbooks/tasks/grafana-ip-service.yaml
oc expose service/grafana-ip-service

Service Monitor for throntail-inventory
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: throntail-inventory
  labels:
    k8s-app:  throntail-inventory
  namespace: monitoring
spec:
  namespaceSelector:
    matchNames:
      - coolstore1
      - coolstore2
      - coolstore++
  endpoints:
    - interval: 30s
      path: /metrics
      port: 8080/tcp
  selector:
    matchLabels:
    app: inventory

```


Service Monitor for vert.x gateway
```
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: vertx-gateway
  labels:
    k8s-app: vertx-gateway
  namespace: monitoring
spec:
  namespaceSelector:
    matchNames:
      - coolstore1
      - coolstore2
      - coolstore++
  endpoints:
    - interval: 30s
      path: /metrics
      port: 8080/tcp
  selector:
    matchLabels:
    app: gatewway

```
