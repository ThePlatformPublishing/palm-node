#!/bin/bash

echo $@ > /tmp/args.txt

BESU_HOST_IP=$1
sed -i "s/PARAM_BESU_HOST_IP/$BESU_HOST_IP/g" /home/ec2-user/besu/besu.yml

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


