#!/bin/bash
set -euo pipefail

PALM_ENV=${1:-dev}
BESU_VERSION=${2:?Must specify the besu version to update to}

if [ -z "${VIRTUAL_ENV:-}" ] ; then
    if [[ -d ./env ]] ; then
        source ./env/bin/activate
    else
        python3 -m venv env
        source ./env/bin/activate
    fi
fi

if ! command -v ansible-playbook &>/dev/null ; then
    python3 -m pip install --requirement requirements.txt
fi

ansible-galaxy install --force --role-file requirements.yaml

AWS_PROFILE=palm ansible-playbook -vvv besu_nodes.yaml \
    --inventory="inventories/${PALM_ENV}.yaml" \
    --extra-vars="ansible_ssh_private_key_file=~/.ssh/palm.pem" \
    --extra-vars="besu_version=${BESU_VERSION}"

