# Palm-node

This repo contains terrafrom scripts to create a Palm node that runs [Hyperledger Besu](https://consensys.net/quorum/developers/) on AWS. 

In addition it also has ansible scripts that let you perfrom routine updates to the Palm node once it is up and running.


### Pre requisites:
- [Terraform](https://www.terraform.io/)
- [Ansible](https://www.ansible.com/)
- OS (Ubuntu) packages:
```bash
sudo apt-get install git libselinux-python python python-pip python-setuptools python-virtualenv python3-pip python3 python3-setuptools jq"
```

### Create 
1. Edit the [variables.tf](./variables.tf) and add:
  - the appropriate vpc and region settings. 
  - the `env_type` that you pick selects the appropriate bootnode enodes to connect to for the Palm prod network or the dev/test networks
  - you also need to add any IP's that you wish to whitelist to make RPC calls from to the `rpc_whitelist_cidrs` var. Otherwise you can make RPC calls only within the VPC or after you've ssh'd into the instance.
  - `create_monitoring_node` by default will create a small instance which will collect metrics from one ore more palm nodes that you deploy. You only need one of these for 'n' palm nodes.

2. Run `terrafrom apply` 

3. If you enabled the monitoring_node, once provisioning is complete, go to http://<MONITOING_INSTANCE_IP>:3000 and login with `admin:password`, and change the password details. Where possible we reccommend using one of the auth mechanisms that grafana [supports](https://grafana.com/docs/grafana/latest/auth/). Open the `Besu dashboard` to see stats of your node

4. To view logs of the Besu node, ssh into the palm node instance and navigate to `/var/log/besu/`




### Update versions of Besu on your palm node:
1. Navigate to the `playbooks` directory
```
cd playbooks
```

Update the [inventory](./playbooks/inventories) and add the IP of the palm node you spun up. 
2. Run and pick an up to date Besu [release](https://github.com/hyperledger/besu/releases)
```
./update_nodes.sh <dev/uat/prd> 21.1.5
```
3. TIP: if you add more palm nodes please remember to add them to the inventory ie `inventories/<env>`

