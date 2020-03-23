# ARG NGINX_INGRESS_VERSION=${NGINX_INGRESS_VERSION:-latest}
ARG NGINX_INGRESS_VERSION="0.27.1"
FROM quay.io/kubernetes-ingress-controller/nginx-ingress-controller:${NGINX_INGRESS_VERSION}
ARG PKGNAME=${PKGNAME:-nginx-module-sigsci-nxo}

# Change to the root user to update the container
USER root

# Install Signal Sciences dependencies and nginx native module
# NOTE: The nginx native module to be installed needs to be for
#       the correct version of nginx installed; this applies
#       to both nginx.org and openresty nginx distributions.
RUN apk update && apk add --no-cache gnupg \
    # Figure out which alpine release this is
    && ALPINE_RELEASE=$(cat /etc/os-release | grep 'VERSION_ID=\s*' | sed 's/^VERSION_ID=\s*//' | sed 's/\./\_/g') \
    && echo "${ALPINE_RELEASE::-2}" \
    # Figure out which nginx is installed in the container
    && NGXVERSION=$(nginx -v 2>&1 | sed 's%^[^/]*/\([0-9]*\.[0-9]*\.[0-9]*\).*%\1%') \
    && echo 'hosts: files dns' > /etc/nsswitch.conf \
    && apk --no-cache add ca-certificates libcap \
    && addgroup -S sigsci && adduser -h /sigsci -S -G sigsci sigsci \
    && mkdir -m 0500 -p /sigsci/bin && mkdir -m 0700 -p /sigsci/tmp && chown -R sigsci:sigsci /sigsci \
    && cd /sigsci/bin \
    && wget -O ./sigsci-agent_latest.tar.gz https://dl.signalsciences.net/sigsci-agent/sigsci-agent_latest.tar.gz \
    && tar xvfz ./sigsci-agent_latest.tar.gz \
    && chmod 0500 /sigsci /sigsci/bin/* \
    && chown sigsci:sigsci /sigsci/bin/sigsci-agent

ENV PATH="/sigsci/bin:${PATH}"
# RUN apt-get update && apt-get install -y apt-transport-https gnupg lsb-release \
#     # Figure out which debian release/codename this is
#     && CODENAME=$(lsb_release -c | sed 's/^Codename:\s*//') \
#     # The sid (unstable) codname is not supported, but buster (previous stable) will work
#     && if [ "${CODENAME}" = "sid" ]; then CODENAME="buster"; fi \
     # Figure out which nginx is installed in the container
#     && NGXVERSION=$(nginx -v 2>&1 | sed 's%^[^/]*/\([0-9]*\.[0-9]*\.[0-9]*\).*%\1%') \
     # Add the signal sciences apt repo
#     && (curl -s -S -L https://apt.signalsciences.net/release/gpgkey | apt-key add -) \
#     && (echo "deb https://apt.signalsciences.net/release/debian/ ${CODENAME} main" > /etc/apt/sources.list.d/sigsci-release.list) \
#     && apt-get update \
#     # Download and force install the package as nginx was installed from source not package
#     && apt-get download nginx-module-sigsci-nxo=${NGXVERSION}\* \
#     && (dpkg --force-all -i nginx-module-sigsci-nxo_${NGXVERSION}*.deb || true) \
#     && rm -f nginx-module-sigsci-nxo_${NGXVERSION}*.deb \
#     && sed -i "s@^#pid.*@&\nload_module /usr/lib/nginx/modules/ngx_http_sigsci_nxo_module-${NGXVERSION}.so;\n@" /usr/local/openresty/nginx/conf/nginx.conf \
#     && rm -rf /var/lib/apt/lists/*

# # Change back to the www-data user for executing nginx at runtime
# USER www-data
