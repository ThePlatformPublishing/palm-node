# Palm-node

This repo contains terrafrom scripts to create either a Palm node/s that runs [Hyperledger Besu](https://consensys.net/quorum/developers/) on AWS. 

In addition it also has ansible scripts that let you perfrom routine updates to the Palm node once it is up and running.

| ⚠️ **WARNING**: We use terraform to provision infrastructure (ie ec2 instances) and ansible to provision HLF Besu on the instances. When you deploy things via terraform, if you have any changes in the file and re run it with `terraform apply` it could destroy existing instances and bring new ones up. Please do not run `terraform apply` twice, instead use `terraform plan` to get a list of changes and then apply if required. To make updates to the instances once they are up, such as edits to the permissions_config.toml file or to update versions of Besu, please use ansible only. Refer to the section titled *Update versions of Besu on your palm node* |
| --- |

### Glossary of terms:
* Enode: A method to identify a node comprising a node's public key and ip of the form "enode://<public_key>@<ip>:30303" where 30303 is the default discovery port
* Boot node: An ethereum node that starts the network off. This is essentially a node that is identical to a TX node but the enode's are known across the network. Every other node first connects to these nodes to obtain a list of peers (other nodes) and then the respective node will attempt to connect to each of those peers.
* Validator node: A ethereum node participating in a POA network that is repsonsible for proposing blocks and need to be available always.
* TX node: A ethereum node that accepts transactions. This is also sometimes refered to as a 'Reader node', 'Writer node', 'Observer node'


### Architecture:

Members joining the Palm network will normally create a normal 'Transaction node'. Some members will create a 'Validator node' - please note that when you opt to create a Validator node, the scripts in this repo will also create an Transaction node for you. When the network goes live there will be an initial pool of 5 validators. Any further validators have to be added/removed in via [voting](https://besu.hyperledger.org/en/latest/Tutorials/Private-Network/Adding-removing-IBFT-validators/). Please refer to the section on 'Process to add or remove Validators' below for more details.


### Testing:
Members are encouraged to test things on the Palm Dev and UAT test networks, and can do so by connecting to the Infura addresses. Members can optionally spin up a Transaction node to connect to the test network but are not required to do so - if you wish to create one, please set the `env_type` var to `uat` or `dev` and follow the steps below to create a Transaction node.


### Pre requisites:
- [Terraform](https://www.terraform.io/) v 0.15 or greater
- [Ansible](https://www.ansible.com/)
- OS (Ubuntu) packages:
```bash
sudo apt-get install git libselinux-python python python-pip python-setuptools python-virtualenv python3-pip python3 python3-setuptools jq"
```

### Create 
1. Decide whether you are running a Palm Transaction node or a Palm Validator node. The validator nodes are responsible for creating blocks on the chain
and need to be available always. There are a couple of extra steps to perform if you are a validator as well, see the section titled 'Validators only'.
2. Edit the [variables.tf](./variables.tf) and add:
  - The appropriate vpc and region settings. 
  - If you choose to be a validator, please uncomment the `palm besu node - validator` section in the [main.tf](./main.tf) file.
  - You also need to add any IP's that you wish to whitelist to make RPC calls from to the `rpc_whitelist_cidrs` var. Otherwise you can make RPC calls only within the VPC or after you've ssh'd into the instance.
  - `create_monitoring_node` by default will create a small instance which will collect metrics from one ore more palm nodes that you deploy. You only need one of these for 'n' palm nodes.

3. Run `terrafrom apply` 

4. If you enabled the monitoring_node, once provisioning is complete, go to http://<MONITOING_INSTANCE_IP>:3000 and login with `admin:password`, and change the password details. Where possible we reccommend using one of the auth mechanisms that grafana [supports](https://grafana.com/docs/grafana/latest/auth/). Open the `Besu dashboard` to see stats of your node

5. To view logs of the Besu node, ssh into the palm node instance and navigate to `/var/log/besu/`

6. Update the inventory file so that you can update versions of Besu in time. Navigate to playbooks/inventories/prd.yml and add your node IP's to the file, if you created a validator node, please uncomment the validator section.


### Validators only
These are extra steps you need to do when running a validator after the node is provisioned.
1. The validator node you own is identified by its private key in the /data folder. To keep this file safe, ssh into the box and copy the node's private key to /etc/besu/key in the event of the data directory not being right or failing like so:
```
sudo cp /data/key /etc/besu/ && chown besu:besu /etc/besu/key
```
**Additionally we recommend copying the contents of the key file to something secure that stores secrets eg 1Password, Lastpass etc**

2. Get the enode of you Palm node and send its details to the Palm.io administrators so that your node can be allowed into the validator pool. This can be found in the first few lines of your log file at `/var/log/besu/besu.log`

3. All validators run a local permissions file to ensure they only communicate with known peers. ssh into your node and add your enode to the file `/etc/besu/permissions_config.toml` **as well as** the enode of your Transaction node. Restart the besu service so it uses the updated settings with `sudo systemctl restart besu.service`

**NOTE: Each time there is a new validator that is added/removed from the pool you need to perform step 3 on your node**


### Update versions of Besu on your palm node:
1. Navigate to the `playbooks` directory
```
cd playbooks
```

Update the [inventory](./playbooks/inventories) and add the IP of the palm node you spun up. 
2. Run and pick an up to date Besu [release](https://github.com/hyperledger/besu/releases) (21.1.7 as of writing this doc)
```
./update_nodes.sh prd 21.1.7
```
3. TIP: if you add more palm nodes please remember to add them to the inventory ie `inventories/<env>`


### Process for Adding/Removing Validators:
In this scenario lets say MemberA is adding a validator to the existing pool, so the steps are:
1. MemberA creates a Validator node and a Transaction node as outlined above.
2. MemberA then gets the enode of their validator as well as the address and sends it to `daniel.heyman@palm.io` via email requesting their enode be added. To obtain the address from the enode, please use the [pubKeyToAddress](./utilites/pubkeyToAddress.js) script.
3. Every existing member of the validator pool must then:
- make an API call proposing that proposes MemberA's node's address be added as a validator like so:

```
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["<ADDRESS_OF_MEMBERA>", true], "id":1}' http://127.0.0.1:8545
```

When more than half the existing validator pool have made that request, the new validator from MemberA is added to the pool.
4. Every existing member must also add MemberA's enode to their own validator's permissions_config.toml and restart their validator. 

To remove a node from the pool, the same process from above is followed, with the exception that you specify **false** in the API call in step3 like so:

```
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["<ADDRESS_OF_MEMBERA>", false], "id":1}' http://127.0.0.1:8545
```



