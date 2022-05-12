
variable "region_details" {
  type = map(string)
  default = {
    region = "default"
    ssh_key = "default"
    ssh_key_path = "~/.ssh/default.pem"
  }
}

variable "vpc_details" {
  type = map(string)
  default = {
    id = "vpc-123"
    vpc_cidr = "0.0.0.0/16"
    public_subnet = "subnet-123"
  }
}

# discovery open to all to allow p2p traffic and let the nodes connect to other nodes
# RPC calls restricted to a whitelisted IPs
variable "ingress_ips" {
  type = map(any)
  default = {
    discovery_cidrs = ["0.0.0.0/0"]
    rpc_cidrs = []
  }
}


variable "node_details" {
  type = map(string)
  default = {
    provisioning_path = "./files/besu"
    ami_id = ""
    instance_type = "m5.large"
    volume_size = "500"
    palm_env = "null"
    palm_node_type = "tx" # tx or validator
    palm_node_count = 1
  }
}

variable "tags" {
  type = map(string)
  default = {
    project_name = "palm"
    project_group = "default"
    team = "ops"
  }
}

variable "amzn2_base_packages" {
  default = "wget curl ntp bind-utils iproute vim-enhanced git libselinux-python jq sysstat awslogs make automake gcc gcc-c++ jq nvme-cli kernel-devel java-11-amazon-corretto.x86_64"
}

# WARNING:
# amzn2 comes with python2.7 which is deprecated and installs for python3.8+ are via amzn extras only (as at time of writing this).
# Symlinks are not created automatically so you need to do them here
# 
# 3.8 is not a recommended version and is just the current version as at writing this, please use the most recent version
# that amzn2 provides. Also submit a PR to update the piece below.
#
variable "python_version" {
  default = "3.8"
}

# NOTE: the version below is not a recommendation of any sort and is just the current version as of writing this comment
# Please use the most up to date release of Besu which can be found on https://github.com/hyperledger/besu/releases
#
variable "besu_version" {
  default = "22.4.0"
}
