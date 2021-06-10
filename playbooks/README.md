
## Validators only!
If you are running a reader node, please proceed directly to the next step.

If you are running a validator node, please uncomment the line so it reads
```
      besu_permissions_nodes_config_file: /etc/besu/permissions_config.toml
```
in the `inventories/<dev/uat/prd>.yaml` file.


## Update existing nodes with:

1. Update the path of the ssh pem key in the update_nodes.sh line 24 and then run
```
./update_nodes.sh <dev/uat/prd> 21.1.7
```


## Add new nodes:
If you add new nodes to any env, please add them to the inventory ie `inventories/<env>.yaml`. If you have created a validator node
please see the section above titled 'Validators only!'

