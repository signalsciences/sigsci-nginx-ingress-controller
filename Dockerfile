ARG NGINX_INGRESS_VERSION=${NGINX_INGRESS_VERSION:-latest}
FROM quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION}
ARG PKGNAME=${PKGNAME:-nginx-module-sigsci-nxo}
ARG JENKINS_BUILD_NUMBER=146

# Change to the root user to update the container
USER root

# Install Signal Sciences dependencies and nginx native module
# NOTE: The nginx native module to be installed needs to be for
#       the correct version of nginx installed; this applies
#       to both nginx.org and openresty nginx distributions.
RUN apk update && apk add --no-cache gnupg wget --virtual ./build_deps \
    # Figure out which alpine release this is
    && ALPINE_RELEASE=$(cat /etc/alpine-release | sed 's/\./\_/g') \
    && ALPINE_RELEASE=${ALPINE_RELEASE::-2} \
    # Figure out which nginx is installed in the container
    && NGXVERSION=$(nginx -v 2>&1 | sed 's%^[^/]*/\([0-9]*\.[0-9]*\.[0-9]*\).*%\1%') \
    # Get the latest version of the sigsci nginx native module
    && MODULE_VERSION=$(wget -O- -q https://dl.signalsciences.net/sigsci-module-nginx-native/VERSION) \
    # Get the correct sigsci nginx native module based on alpine version, nginx version, and module version
    && wget -O /tmp/nginx-module-sigsci-nxo_${NGXVERSION}-${JENKINS_BUILD_NUMBER}-alpine${ALPINE_RELEASE}.tar.gz https://dl.signalsciences.net/sigsci-module-nginx-native/${MODULE_VERSION}/alpine/alpine${ALPINE_RELEASE}/nginx-module-sigsci-nxo_${NGXVERSION}-${JENKINS_BUILD_NUMBER}-alpine${ALPINE_RELEASE}.tar.gz \
    # Manually install the sigsci native nginx module and update nginx.conf
    && tar xvfz /tmp/nginx-module-sigsci-nxo_${NGXVERSION}-${JENKINS_BUILD_NUMBER}-alpine${ALPINE_RELEASE}.tar.gz -C /tmp || : \
    && mkdir -p /usr/lib/nginx/modules \
    && mv /tmp/ngx_http_sigsci_nxo_module-${NGXVERSION}.so /usr/lib/nginx/modules/ngx_http_sigsci_module.so \
    && ln -s /usr/lib/nginx/modules/ngx_http_sigsci_module.so /etc/nginx/modules/ngx_http_sigsci_module.so \
    && sed -i 's@^pid.*@&\nload_module /usr/lib/nginx/modules/ngx_http_sigsci_module.so;\n@' /etc/nginx/nginx.conf \
    # cleanup
    && rm /tmp/nginx-module-sigsci-nxo_${NGXVERSION}-${JENKINS_BUILD_NUMBER}-alpine${ALPINE_RELEASE}.tar.gz /tmp/*.so \
    && apk del --no-cache ./build_deps
# Change back to the www-data user for executing nginx at runtime
USER www-data
