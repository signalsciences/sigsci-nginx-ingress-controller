#!/bin/bash

# What should we output the latest version of: sigsci or upstream?
TARGET="${1:-upstream}"

GH_REPO="${GH_REPO:-https://api.github.com/repos/signalsciences/sigsci-nginx-ingress-controller}"

# Regex to restict to subset of semver tags (no pre-release versions)
VERSION_REGEX="v[0-9]+\.[0-9]+\.[0-9]+$"
CONTROLLER_REGEX="controller-${VERSION_REGEX}"


# Print out latest upstream controller version as bare version (1.2.3)
function outputLatestKubernetesUpstream () {
    # Grab list of full controller releases without any -alpha, -beta, -RC etc semver suffixes 
    ingress_controller_tags=$(curl -sL https://api.github.com/repos/kubernetes/ingress-nginx/releases\?per_page\=100 | jq -r '.[] | select( .tag_name | contains("controller")) | .tag_name' | grep -E "$CONTROLLER_REGEX")

    # Clean up the tags to be plain version numbers (1.2.3) and sort them in a version aware manner
    sorted_ingress_versions=$(echo "$ingress_controller_tags" | cut -d '-' -f2 | cut -d 'v' -f2 | sort --field-separator=. --key=1,1n --key=2,2n --key=3,3n)

    # Grab just the latest version and output
    echo "$sorted_ingress_versions" | tail -n1 
}

# Print out latest NGINX Inc upstream controller version as bare version (1.2.3)
function outputLatestNginxIncUpstream() {
     # Grab list of nginx inc controller releases without any -alpha, -beta, -RC etc semver suffixes 
    ingress_inc_controller_tags=$(curl -sL https://api.github.com/repos/nginxinc/kubernetes-ingress/releases\?per_page\=100 | jq -r '.[].tag_name' | grep -E "$VERSION_REGEX")

    # Clean up the tags to be plain version numbers (1.2.3) and sort them in a version aware manner
    sorted_ingress_inc_versions=$(echo "$ingress_inc_controller_tags" | cut -d '-' -f2 | cut -d 'v' -f2 | sort --field-separator=. --key=1,1n --key=2,2n --key=3,3n)

    # Grab just the latest version and output
    echo "$sorted_ingress_inc_versions" | tail -n1 
}

# Print out the latest sigsci controller version as a bare version (1.2.3)
function outputLatestSigsciVersion () {
    # Grab list of sigsci controller versions
    sigsci_tags=$(curl -sL ${GH_REPO}/releases\?per_page\=100 | jq -r '.[].tag_name')

    # Sort the tags in a version aware manner
    sorted_sigsci_tags=$(echo "$sigsci_tags" | sort --field-separator=. --key=1,1n --key=2,2n --key=3,3n)

    # Grab just the latest verison and output
    echo "$sorted_sigsci_tags" | tail -n1
}

case "$TARGET" in
    upstream)
        outputLatestKubernetesUpstream
        ;;
    nginxinc)
        outputLatestNginxIncUpstream
        ;;
    sigsci | fastly)
        outputLatestSigsciVersion
        ;;
    *)
        echo "Unknown target argument: specify 'upstream', 'sigsci' or 'nginxinc'"
        exit 1
        ;;
esac
