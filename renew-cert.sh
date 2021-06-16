#!/bin/bash
set -e

# with the cluster/cert-manager running, this script extracts a renewed certificate
# usage: ./renew-cert.sh certificate-file.yaml

export KUBECONFIG="kubectl.config"

[ $# != 1 ] && echo "need certificate file as parameter" && exit 1
[ -z "`which jq`" ] && echo "jq is needed, see https://stedolan.github.io/jq/download/" && exit 1
[ -z "`which yq`" ] && echo "yq is needed, see https://mikefarah.gitbook.io/yq/" && exit 1
[ ! -f "${1}" ] && echo "certificate yaml file ${1} does not exist" && exit 1
[ -f "${1}.renewed" ] && echo "renewed certificate yaml file ${1}.renewed already exist" && exit 1

NAMESPACE=$(yq e ${1} -j | jq -r '.metadata.namespace')
TLSNAME=$(yq e ${1} -j | jq -r '.metadata.name')

[ -z "${NAMESPACE}" ] && echo "certificate file ${1} has no namespace... " && exit 1
[ -z "${TLSNAME}" ] && echo "certificate file ${1} has no secret name... " && exit 1

today=$(date '+%Y-%m-%d')
valid=$(date --date "`yq e ${1} -j | jq -r '.data."tls.crt"' | base64 -d | openssl x509 -noout -dates | grep 'notAfter=' | cut -d= -f 2 `" +'%Y-%m-%d')
date_diff=$(( ($(date -d "$valid" +%s) - $(date -d "$today" +%s) )/(60*60*24) ))

if [[ "$date_diff" -gt 29 ]]; then
  echo "Existing certificate ${1} is vaild another ${date_diff} days until ${valid}, no need to renew."
  exit 0
fi

echo "Waiting for cert-manager to renew the certificate ${1}, valid until ${valid}."
echo "  secret name: ${TLSNAME}  namespace: ${NAMESPACE}"
echo "  checking for renewal every 5 minutes for 10 hours"
i=0
while [ true ] 
do

  new_valid=$(date --date "`kubectl -n ${NAMESPACE} get -o json secret ${TLSNAME} | jq -r '.data."tls.crt"' | base64 -d | openssl x509 -noout -dates | grep 'notAfter=' | cut -d= -f 2 `" +'%Y-%m-%d')

  if [[ "${new_valid}" != "${valid}" ]]; then
    kubectl -n ${NAMESPACE} get -o yaml secret ${TLSNAME} > ${1}.renewed
    echo "renewed certificate file is available here: ${1}.renewed"
    exit 0
  fi

  [ ${i} -gt 120 ] && break
  i=$[$i+1]
  echo "Waiting 5 minutes ${1}/120..."
  sleep 300 # 5 minutes
done

echo "Could not renew within 24 hours... :-(    exiting"
exit 1
