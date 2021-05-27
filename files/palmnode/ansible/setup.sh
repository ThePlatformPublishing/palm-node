#!/bin/bash

echo $@ > /tmp/args.txt

BESU_HOST_IP=$1
BESU_NODE_TYPE=$2
sed -i "s/PARAM_BESU_HOST_IP/$BESU_HOST_IP/g" /home/ec2-user/besu/besu.yml

# if its a validator; then make sure it uses local permissions so validators can only talk to trusted nodes
# WARNING: Once your node starts up, you must also add your palm node's enode to `/etc/besu/permissions_config.toml` 
# and notify the Palm.io admins of your enode so it can be allowed into the validator pool
if [ "$BESU_NODE_TYPE" == "validator" ]; then
    echo "Using permissions for validator node" >> /tmp/args.txt;
    mkdir -p /etc/besu;
    mv /home/ec2-user/besu/permissions_config.toml /etc/besu/permissions_config.toml
else 
    echo "No permissions for this node" >> /tmp/args.txt;
    # remove the permissions line so your node can talk to any peer 
    sed -ie '/besu_permissions_nodes_config_file.*/d' /home/ec2-user/besu/besu.yml
fi

cd /home/ec2-user/besu/
python3 -m venv env
source env/bin/activate
pip3 install wheel
pip3 install -r requirements.txt

# 2x becuase of some random git timeouts
ansible-galaxy install -r requirements.yml --force --ignore-errors
ansible-galaxy install -r requirements.yml --force --ignore-errors

# start in stopped state so paths and config are created
ansible-playbook -v besu.yml --extra-vars="besu_systemd_state=stopped"

# copy config across
cp genesis.json /etc/besu/genesis.json
mv keys/ /etc/besu/
chown -R besu:besu /etc/besu/
chown -R besu:besu /opt/besu/
chown -R besu:besu /data/

# wait for the eip's to latch
sleep 60
# fire up the service
systemctl restart besu.service
shutdown -r +1 "Rebooting in 1 minute" &


