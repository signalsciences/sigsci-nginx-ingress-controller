# sigsci-nginx-ingress-controller
Dockerfile to add the Signal Sciences NGINX module into the stock Kubernetes NGINX ingress controller image (https://github.com/kubernetes/ingress-nginx)

Prebuilt images hosted here: https://hub.docker.com/repository/docker/signalsciences/sigsci-nginx-ingress-controller

Tags/Releases track image tags of the upstream docker repo.
These images work as drop-in replacements for:
* `k8s.gcr.io/ingress-nginx/controller` images with corresponding tags (0.43.0)
* `quay.io/kubernetes-ingress-controller/nginx-ingress-controller` images with corresponding tags (0.25.0-0.33.0)

### Helm install instructions with override file

The following are steps to install [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx) via helm using the sigsci-values.yaml override file. This adds the custom sigsci-nginx-ingress-controller and sigsci-agent.

1) Add the [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) repo  
`helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`

2) Add `SIGSCI_ACCESSKEYID` and `SIGSCI_SECRETACCESSKEY` to the [sigsci-values.yaml](sigsci-values.yml) file

3) Install ingress-nginx with override file  
`helm install -f values-sigsci.yaml my-ingress ingress-nginx/ingress-nginx`

4) Here is an example Ingress template to test the controller. This file will vary based on indiviudal needs
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: hello-kubernetes-ingress
  #namespace:
spec:
  rules:
  - http:
      paths:
      - pathType: Prefix
        path: /testpath
        backend:
          service:
            name: NAME OF YOUR SERVICE
            port:
              number: 80
```

5) To upgrade the helm chart with override file  
`helm upgrade -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx`
