ARG NGINX_INGRESS_VERSION=${NGINX_INGRESS_VERSION:-latest}
FROM quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION}
ARG PKGNAME=${PKGNAME:-nginx-module-sigsci-nxo}

# Change to the root user to update the container
USER root

# Install Signal Sciences dependencies and nginx native module
# NOTE: The nginx native module to be installed needs to be for
#       the correct version of nginx installed; this applies
#       to both nginx.org and openresty nginx distributions.
RUN apt-get update && apt-get install -y apt-transport-https gnupg lsb-release \
    # Figure out which debian release/codename this is
    && CODENAME=$(lsb_release -c | sed 's/^Codename:\s*//') \
    # The sid (unstable) codname is not supported, but buster (previous stable) will work
    && if [ "${CODENAME}" = "sid" ]; then CODENAME="buster"; fi \
    # Figure out which nginx is installed in the container
    && NGXVERSION=$(nginx -v 2>&1 | sed 's%^[^/]*/\([0-9]*\.[0-9]*\.[0-9]*\).*%\1%') \
    # Add the signal sciences apt repo
    && (curl -s -S -L https://apt.signalsciences.net/release/gpgkey | apt-key add -) \
    && (echo "deb https://apt.signalsciences.net/release/debian/ ${CODENAME} main" > /etc/apt/sources.list.d/sigsci-release.list) \
    && apt-get update \
    # Download and force install the package as nginx was installed from source not package
    && apt-get download nginx-module-sigsci-nxo=${NGXVERSION}\* \
    && (dpkg --force-all -i nginx-module-sigsci-nxo_${NGXVERSION}*.deb || true) \
    && rm -f nginx-module-sigsci-nxo_${NGXVERSION}*.deb \
    && sed -i 's@^#pid.*@&\nload_module /usr/lib/nginx/modules/ngx_http_sigsci_nxo_module-${NGXVERSION}.so;\n@' /usr/local/openresty/nginx/conf/nginx.conf \
    && rm -rf /var/lib/apt/lists/*

# Change back to the www-data user for executing nginx at runtime
USER www-data
