# sigsci-nginx-ingress-controller
Dockerfile to add the Signal Sciences NGINX module into the stock Kubernetes NGINX ingress controller image (https://github.com/kubernetes/ingress-nginx)

Prebuilt images hosted here: https://hub.docker.com/repository/docker/signalsciences/sigsci-nginx-ingress-controller

Tags/Releases track image tags of the upstream docker repo.
These images work as drop-in replacements for:
* `registry.k8s.io/ingress-nginx/controller` images with corresponding tags

***NGINX, Inc.***
Use `Dockerfile.nginxinc` if you want to add the Signal Sciences NGINX module into the stock nginxinc/kubernetes-ingress image (https://github.com/nginxinc/kubernetes-ingress)

Prebuilt images are hosted here: https://hub.docker.com/repository/docker/signalsciences/sigsci-nginxinc-ingress-controller

***Chainguard fork***
`kubernetes/ingress-nginx` was archived on March 24, 2026. `Dockerfile.chainguard` builds against the Chainguard fork (https://github.com/chainguard-forks/ingress-nginx) instead.

Prebuilt images are hosted here: https://hub.docker.com/repository/docker/signalsciences/sigsci-nginx-ingress-controller-chainguard

## ModSecurity is not available in the Chainguard image

The upstream NGINX base image ships ModSecurity, the OWASP Core Rule Set and the
`ngx_http_modsecurity_module` NGINX module. `Dockerfile.chainguard` deletes all of
them: the Fastly Next-Gen WAF module provides WAF functionality in this image, and
carrying a second WAF only adds size and vulnerability reports for code that nothing
uses.

As a result, ModSecurity cannot be turned on in this image. Either of these will
stop NGINX from starting:

* `enable-modsecurity: "true"` in the controller ConfigMap
* the `nginx.ingress.kubernetes.io/enable-modsecurity: "true"` Ingress annotation

The remaining ModSecurity settings (`enable-owasp-modsecurity-crs`,
`nginx.ingress.kubernetes.io/enable-owasp-core-rules`, `modsecurity-snippet`,
`modsecurity-transaction-id`) only take effect once ModSecurity is enabled, so on
their own they are ignored exactly as they were before.

If ModSecurity is enabled, NGINX fails its configuration check with:

```
nginx: [emerg] open() "/etc/nginx/MODSECURITY-REMOVED-FROM-THIS-IMAGE-unset-enable-modsecurity.conf" failed (2: No such file or directory)
```

Unset the setting to start NGINX. All of these default to off, so an installation
that has not deliberately enabled ModSecurity is unaffected.

## Helm install instructions with override file

The following are steps to install [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx) via helm using the sigsci-values.yaml override file. This adds the custom sigsci-nginx-ingress-controller and sigsci-agent.

1) Add the [kubernetes/ingress-nginx](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) repo  
`helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx`

2) Add `SIGSCI_ACCESSKEYID` and `SIGSCI_SECRETACCESSKEY` to the [sigsci-values.yaml](sigsci-values.yaml) file.

3) Install with the release name `my-ingress` in the `default` namespace  
`helm install -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx`
* You can specify a namespace with `-n` flag:  
  `helm install -n NAMESPACE -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx`

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

Follow these steps to install [nginxinc/kubernetes-ingress](https://github.com/nginxinc/kubernetes-ingress) with the sigsci-nginxinc-values.yaml override file. This will add the custom sigsci-nginx-ingress-controller and sigsci-agent.

1) Add the [nginxinc/kubernetes-ingress](https://github.com/nginxinc/kubernetes-ingress/tree/main/deployments/helm-chart) repo  
   `helm repo add nginx-stable https://helm.nginx.com/stable`

2) Add `SIGSCI_ACCESSKEYID` and `SIGSCI_SECRETACCESSKEY` to the [sigsci-nginxinc-values.yaml](sigsci-nginxinc-values.yaml) file.

3) Install with helm  
   `helm install -f sigsci-nginxinc-values.yaml my-ingress nginx-stable/nginx-ingress`
* You can specify a namespace with `-n` flag:  
  `helm install -n NAMESPACE -f sigsci-nginxinc-values.yaml my-ingress nginx-stable/nginx-ingress`

4) Create an Ingress resource. This step will vary depending on setup and supports a lot of configurations. Official documentation can be found regarding [Basic usage - host based routing](https://kubernetes.github.io/ingress-nginx/user-guide/basic-usage/)

Here is an example Ingress file for the nginxinc/kubernetes-ingress controller:
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: cafe-ingress
spec:
  tls:
  - hosts:
    - cafe.example.com
    secretName: cafe-secret
  rules:
  - host: cafe.example.com
    http:
      paths:
      - path: /tea
        pathType: Prefix
        backend:
          service:
            name: tea-svc
            port:
              number: 80
      - path: /coffee
        pathType: Prefix
        backend:
          service:
            name: coffee-svc
            port:
              number: 80
```

5) Now you are ready to setup rules, rate limits and more [using Signal Sciences](https://docs.fastly.com/signalsciences/using-signal-sciences/)

## Helm Upgrade with Override File
To update the [ingress-nginx charts](https://github.com/kubernetes/ingress-nginx/tree/master/charts/ingress-nginx) or [kubernetes-ingress charts](https://github.com/nginxinc/kubernetes-ingress/tree/main/deployments/helm-chart)

1. Update the sigsci-nginx-ingress-controller to the latest version in the [sigsci-values.yaml](https://github.com/signalsciences/sigsci-nginx-ingress-controller/blob/main/sigsci-values.yaml) or [sigsci-nginxinc-values.yaml](https://github.com/signalsciences/sigsci-nginx-ingress-controller/blob/main/sigsci-nginxinc-values.yaml) file
```
controller:
    # Replaces the default nginx-controller image with a custom image that contains the Signal Sciences nginx Module
    image:
      repository: signalsciences/sigsci-nginx-ingress-controller
      tag: "1.10.0"
      pullPolicy: IfNotPresent
```

2. Then run helm upgrade with override file. This example is running helm upgrade against the `my-ingress` release created in step 3 of the previous section.  
`helm upgrade -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx` or
`helm upgrade -f sigsci-nginxinc-values.yaml my-ingress nginx-stable/nginx-ingress` depending on your upstream ingress controller
* If ingress is not in default namespace use `-n` to specify namespace:  
`helm upgrade -n NAMESPACE -f sigsci-values.yaml my-ingress ingress-nginx/ingress-nginx` or
`helm upgrade -n NAMESPACE -f sigsci-nginxinc-values.yaml my-ingress nginx-stable/nginx-ingress`


## Uninstall Release
Uninstall release `my-ingress` in `default` namespace:  
`helm uninstall my-ingress`

If not in default namespace use `-n` to specify namesapce:  
`helm uninstall -n NAMESPACE my-ingress`
