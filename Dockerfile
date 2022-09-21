ARG NGINX_INGRESS_VERSION=${NGINX_INGRESS_VERSION:-v0.47.0}
FROM --platform=$BUILDPLATFORM k8s.gcr.io/ingress-nginx/controller:${NGINX_INGRESS_VERSION}

ARG BUILDPLATFORM
ARG PKGNAME=${PKGNAME:-nginx-module-sigsci-nxo}

# Change to the root user to update the container
USER root

# Install Signal Sciences dependencies and nginx native module
# NOTE: The nginx native module to be installed needs to be for
#       the correct version of nginx installed; this applies
#       to both nginx.org and openresty nginx distributions.
RUN apk -U upgrade && apk add --no-cache gnupg wget curl --virtual ./build_deps \
    # Figure out which alpine release this is
    && ALPINE_RELEASE=$(cat /etc/alpine-release) \
    && ALPINE_RELEASE=${ALPINE_RELEASE::-2} \
    # Figure out which nginx is installed in the container
    && NGXVERSION=$(nginx -v 2>&1 | sed 's%^[^/]*/\([0-9]*\.[0-9]*\.[0-9]*\).*%\1%') \
    # Get the latest version of the sigsci nginx native module
    && MODULE_VERSION=$(wget -O- -q https://dl.signalsciences.net/sigsci-module-nginx-native/VERSION) \
    # Get the correct sigsci nginx native module based on alpine version, nginx version, and module version
    && wget https://apk.signalsciences.net/sigsci_apk.pub && mv sigsci_apk.pub /etc/apk/keys \
    && echo "https://apk.signalsciences.net/${ALPINE_RELEASE}/main" | tee -a /etc/apk/repositories \
    && apk add ${PKGNAME}-${NGXVERSION} \
    && ln -s /usr/lib/nginx/modules/ngx_http_sigsci_module.so /etc/nginx/modules/ngx_http_sigsci_module.so \
    && sed -i 's@^pid.*@&\nload_module /usr/lib/nginx/modules/ngx_http_sigsci_module.so;\n@' /etc/nginx/nginx.conf \
    # cleanup
    && apk del --no-cache ./build_deps \
    && rm /etc/apk/keys/sigsci_apk.pub
# Change back to the www-data user for executing nginx at runtime
USER www-data
