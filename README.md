# sigsci-nginx-ingress-controller
Dockerfile to add the Signal Sciences NGINX module into the stock Kubernetes NGINX ingress controller image (https://github.com/kubernetes/ingress-nginx)

Prebuilt images hosted here: https://hub.docker.com/repository/docker/signalsciences/sigsci-nginx-ingress-controller

Tags/Releases track image tags of the upstream docker repo.
These images work as drop-in replacements for:
* `k8s.gcr.io/ingress-nginx/controller` images with corresponding tags (0.43.0)
* `quay.io/kubernetes-ingress-controller/nginx-ingress-controller` images with corresponding tags (0.25.0-0.33.0)

## Helm install instructions with override file

The following are steps to install [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx) via helm using the sigsci-values.yaml override file. This adds the custom sigsci-nginx-ingress-controller and sigsci-agent.

1) Add the [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) repo  
`helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`

2) Add `SIGSCI_ACCESSKEYID` and `SIGSCI_SECRETACCESSKEY` to the [sigsci-values.yaml](sigsci-values.yaml) file.

3) Install with the release name `my-ingress` in the `default` namespace  
`helm install -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx`
* You can specify a namespace with `-n` flag:  
  `helm install -n NAMESPACE -f values-sigsci.yaml my-ingress ingress-nginx/ingress-nginx`

4) Create an Ingress resource. This step will vary depending on setup and supports a lot of configurations. Official documentation can be found regarding [Basic usage - host based routing](https://kubernetes.github.io/ingress-nginx/user-guide/basic-usage/)

Here is an example Ingress file:
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: hello-kubernetes-ingress
  #namespace: SET THIS IF NOT IN DEFAULT NAMESPACE
spec:
  rules:
  - host: example.com
    http:
      paths:
      - pathType: Prefix
        path: /testpath
        backend:
          service:
            name: NAME OF YOUR SERVICE
            port:
              number: 80
```

5) Now you are ready to setup rules, rate limits and more [using Signal Sciences](https://docs.fastly.com/signalsciences/using-signal-sciences/)

## Helm Upgrade with Override File
To update the [ingress-nginx charts](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) 

1. Update the sigsci-nginx-ingress-controller to the latest version in the [sigsci-values.yaml](https://github.com/signalsciences/sigsci-nginx-ingress-controller/blob/main/sigsci-values.yaml) file
```
controller:
    # Replaces the default nginx-controller image with a custom image that contains the Signal Sciences nginx Module
    image:
      repository: signalsciences/sigsci-nginx-ingress-controller
      tag: "0.47.0"
      pullPolicy: IfNotPresent
```

2. Then run helm upgrade with override file. This example is running helm upgrade against the `my-ingress` release created in step 3 of the previous section.  
`helm upgrade -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx`
* If ingress is not in default namespace use `-n` to specify namespace:  
`helm upgrade -n NAMESPACE -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx`


## Uninstall Release
Uninstall release `my-ingress` in `default` namespace:  
`helm uninstall my-ingress`

If not in default namespace use `-n` to specify namesapce:  
`helm uninstall -n NAMESPACE my-ingress`
