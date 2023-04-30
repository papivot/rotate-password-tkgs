#!/usr/bin/bash

while getopts ":n:c:" opt; do
    case $opt in
        n)
            arg1="$OPTARG"
            ;;
        c)
            arg2="$OPTARG"
            ;;
        h)
            echo "Usage: rotate-passsord.sh [-h|--help] [-c <workload cluster name>] [-n <vsphere namespace>]"
            exit 1
            ;;
        \?)
            echo "Usage: rotate-passsord.sh [-h|--help] [-c <workload cluster name>] [-n <vsphere namespace>]"
            exit 1
            ;;
        :)
            echo "Usage: rotate-passsord.sh [-h|--help] [-c <workload cluster name>] [-n <vsphere namespace>]"
            exit 1
            ;;
    esac
done

if [[ -z "$arg1" ]]; then
    echo "Missing argument -n"
    echo "Usage: rotate-passsord.sh [-h|--help] [-c <workload cluster name>] [-n <vsphere namespace>]"
    exit 1
fi

if [[ -z "$arg2" ]]; then
    echo "Missing argument -c"
    echo "Usage: rotate-passsord.sh [-h|--help] [-c <workload cluster name>] [-n <vsphere namespace>]"
    exit 1
fi

###################################################
# Enter temp variables here
###################################################
NAMESPACE=$arg1
CLUSTERNAME=$arg2

if ! command -v openssl >/dev/null 2>&1 ; then
  echo "openssl not installed. Exiting..."
  exit
fi

if ! command -v kubectl >/dev/null 2>&1 ; then
  echo "kubectl not installed. Exiting..."
  exit
fi

kubectl get deployment -n vmware-system-tkg vmware-system-tkg-controller-manager > /dev/null 2>&1
if [[ ! $? ]]; then
   echo 'KUBECONFIG context not set to Supervisor. Please login to the Supervisor cluster and/or fix the current context. Exiting...'
   exit
fi

echo "Patching Supervisor objects to rotate password for ${CLUSTERNAME} ..."
###################################################
# Main processing starts here
###################################################
PASSWD=$(openssl rand -base64 32)
HPASSWD=$(openssl passwd -6 ${PASSWD})
B64PASSWD=$(echo ${PASSWD}|base64 -w0)
B64HPASSWD=$(echo ${HPASSWD}|base64 -w0)

kubectl -n ${NAMESPACE} patch secret ${CLUSTERNAME}-ssh-password -p '{"data":{"ssh-passwordkey":"'${B64PASSWD}'"}}'
kubectl -n ${NAMESPACE} patch secret ${CLUSTERNAME}-ssh-password-hashed -p '{"data":{"ssh-passwordkey":"'${B64HPASSWD}'"}}'

echo
echo "Requried password secrets updated. Repave your ${CLUSTERNAME} cluster ..."
echo

kubectl -n ${NAMESPACE} patch cluster ${CLUSTERNAME} --type merge -p '{"spec": {"topology": {"controlPlane": {"metadata": {"annotations":{"passwd-modified-on-'"$(date +%Y-%m-%d)"'":""}}}}}}'
sleep 5
kubectl -n ${NAMESPACE} get   cluster ${CLUSTERNAME} -o json | jq '.spec.topology.workers.machineDeployments[].metadata.annotations += {"passwd-modified-on-'"$(date +%Y-%m-%d)"'":""}'| jq 'del(.metadata.creationTimestamp, .metadata.resourceVersion, .metadata.uid, .metadata.generation)' | kubectl apply -f -
