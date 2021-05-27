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
1. Decide whether you are running a Palm validator node or a Palm reader node. The validator nodes are responsible for creating blocks on the chain
and need to be available always. There are a couple of extra steps to perform if you are a validator as well, see the section titled 'Validators only'.
2. Edit the [variables.tf](./variables.tf) and add:
  - The appropriate vpc and region settings. 
  - The `env_type` that you pick selects the appropriate bootnode enodes to connect to for the Palm prod network or the dev/test networks
  - If you choose to be a validator, please set the variable `palm_node_type` to 'validator'
  - You also need to add any IP's that you wish to whitelist to make RPC calls from to the `rpc_whitelist_cidrs` var. Otherwise you can make RPC calls only within the VPC or after you've ssh'd into the instance.
  - `create_monitoring_node` by default will create a small instance which will collect metrics from one ore more palm nodes that you deploy. You only need one of these for 'n' palm nodes.

3. Run `terrafrom apply` 

4. If you enabled the monitoring_node, once provisioning is complete, go to http://<MONITOING_INSTANCE_IP>:3000 and login with `admin:password`, and change the password details. Where possible we reccommend using one of the auth mechanisms that grafana [supports](https://grafana.com/docs/grafana/latest/auth/). Open the `Besu dashboard` to see stats of your node

5. To view logs of the Besu node, ssh into the palm node instance and navigate to `/var/log/besu/`



### Validators only
These are extra steps you need to do when running a validator after the node is provisioned.
1. Get the enode of you Palm node and send its details to the Palm.io administrators so that your node can be allowed into the validator pool.
2. ssh into your node and add your enode to the file `/etc/besu/permissions_config.toml` 
3. Restart the service so it uses the updated settings with `sudo systemctl restart besu.service`
NOTE: Each time there is a new validator that is added/removed from the pool you need to perform steps 2 and 3 on your node


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

