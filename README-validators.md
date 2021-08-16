## Validators 

### Create a validator node:
The validator nodes are responsible for creating blocks on the chain and need to be available always. 

2. Edit the [variables.tf](./variables.tf) and add:
  - The appropriate vpc and region settings. 
  - Please **uncomment** the `palm besu node - validator` section in the [main.tf](./main.tf) file.
  - You also need to add any IP's that you wish to whitelist to make RPC calls from to the `rpc_whitelist_cidrs` var. Otherwise you can make RPC calls only within the VPC or after you've ssh'd into the instance.
  - `create_monitoring_node` by default will create a small instance which will collect metrics from one ore more palm nodes that you deploy. You only need one of these for 'n' palm nodes.

3. Run `terrafrom apply` 

4. If you enabled the monitoring_node, once provisioning is complete, go to http://<MONITOING_INSTANCE_IP>:3000 and login with `admin:password`, and change the password details. Where possible we reccommend using one of the auth mechanisms that grafana [supports](https://grafana.com/docs/grafana/latest/auth/). Open the `Besu dashboard` to see stats of your node

5. To view logs of the Besu node, ssh into the palm node instance and navigate to `/var/log/besu/`

6. Update the inventory file so that you can update versions of Besu in time. Navigate to playbooks/inventories/prd.yml and add your node IP's to the file, if you created a validator node, please uncomment the validator section.


These are extra steps you need to do when running a validator after the node is provisioned.
1. The validator node you own is identified by its private key in the /data folder. To keep this file safe, ssh into the box and copy the node's private key to /etc/besu/key in the event of the data directory not being right or failing like so:
```
sudo cp /data/key /etc/besu/ && chown besu:besu /etc/besu/key
```
**Additionally we recommend copying the contents of the key file to something secure that stores secrets eg 1Password, Lastpass etc**

2. Get the enode of you Palm node and send its details to the Palm.io administrators so that your node can be allowed into the validator pool. This can be found in the first few lines of your log file at `/var/log/besu/besu.log`

3. All validators run a local permissions file to ensure they only communicate with known peers. ssh into your node and add your enode to the file `/etc/besu/permissions_config.toml` **as well as** the enode of your Transaction node. Restart the besu service so it uses the updated settings with `sudo systemctl restart besu.service`

**NOTE: Each time there is a new validator that is added/removed from the pool you need to perform step 3 on your node**


### Process for Adding/Removing Validators to the Palm Validator Pool:
In this scenario lets say MemberA is adding a validator to the existing pool, MemberA would the do the following:
1. MemberA creates a Validator node and a Transaction node as outlined above.
2. MemberA then gets the enode of their validator as well as the address. Hint: To obtain the address from the enode, please use the [pubKeyToAddress](./utilites/pubkeyToAddress.js) script.
3. MemberA would then fill up a [form](https://share.hsforms.com/1_sBreu7XTMWZtH9n1xTP3g2urwb) with some user details. If the link does not work, please go to  https://docs.palm.io/Concepts/Validators/ and click on 'Contact Us'.
4. Once completed and accepted, Palm.io will communicate with the admins of the existing validaotors with MemberA's enode address
5. Every existing member of the validator pool would the make an API call proposing that MemberA's node's address be added as a validator like so:

```
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["<ADDRESS_OF_MEMBERA>", true], "id":1}' http://127.0.0.1:8545
```

When more than half the existing validator pool have made that request, the new validator from MemberA is added to the pool.
6. Every existing member must also add MemberA's enode to their own validator's permissions_config.toml and restart their validator. 

To remove a node from the pool, the same process from above is followed, with the exception that you specify **false** in the API call in step5 like so:

```
curl -X POST --data '{"jsonrpc":"2.0","method":"ibft_proposeValidatorVote","params":["<ADDRESS_OF_MEMBERA>", false], "id":1}' http://127.0.0.1:8545
```

### Credits
The code in this repository was developed by ConsenSys Software Inc.
  
![Image logo](images/consensys-logo.png)

