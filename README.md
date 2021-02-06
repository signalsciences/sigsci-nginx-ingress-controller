# sigsci-nginx-ingress-controller
Dockerfile to add the Signal Sciences NGINX module into the stock Kubernetes NGINX ingress controller image (https://github.com/kubernetes/ingress-nginx)

Tags/Releases track image tags of the upstream docker repo:
https://quay.io/kubernetes-ingress-controller/nginx-ingress-controller

Prebuilt images hosted here: https://hub.docker.com/repository/docker/signalsciences/sigsci-nginx-ingress-controller

These images work as drop-in replacements for:
* `k8s.gcr.io/ingress-nginx/controller` images with corresponding tags (0.43.0)
* `quay.io/kubernetes-ingress-controller/nginx-ingress-controller` images with corresponding tags (0.25.0-0.33.0)
