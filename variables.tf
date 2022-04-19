
# which of the palm networks to use
variable "env_type" {
  default = "uat"
}

variable "create_monitoring_node" {
  description = "create a monitoring instance to monitor the health of the palm node"
  type        = bool
  default     = true
}

variable "region_details" {
  type = map(string)
  default = { 
    region = "ap-southeast-2"
    ssh_key = "my-pem-key"
    ssh_key_path = "~/.ssh/my-pem-key.pem"
  }
}

variable "vpc_details" {
  type = map(string)
  default = {
    vpc_id = "vpc-00...."
    vpc_cidr = "10.0.0.0/16"
    public_subnet = "subnet-00........."
  }
}

# NOTE: Palm-mainnet is not the ethereum mainnet, so you do not need to provide 5TB of space, rather 
# grow the volume as required https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/recognize-expanded-volume-linux.html
variable "node_details" {
  type = map(string)
  default = {
    provisioning_path = "./files/palmnode"
    instance_type = "m5.large"
    instance_volume_size = "1000"
  }
}

variable "tags" {
  type = map(string)
  default = {
    project_name = "palm"
    project_group = "ops"
    team = "devops"
  }
}

variable "rpc_whitelist_cidrs" {
  type = list(string)
  default = [] 
}

variable "amzn2_base_packages" {
  default = "wget curl ntp bind-utils iproute vim-enhanced git libselinux-python jq sysstat awslogs make automake gcc gcc-c++ kernel-devel java-11-amazon-corretto.x86_64"
}


variable "validator_node_count" {
  default = "1"
}

variable "tx_node_count" {
  default = "1"
}

# NOTE: the version below is not a recommendation of any sort and is just the current version as of writing this comment
# Please use the most up to date release of Besu which can be found on https://github.com/hyperledger/besu/releases
#
variable "besu_version" {
  default = "22.1.3"
}

# WARNING:
# amzn2 comes with python2.7 which is deprecated and installs for python3.8+ are via amzn extras only (as at time of writing this).
# Symlinks are not created automatically so you need to do them here
# 
# 3.8 is not a recommended version and is just the current version as at writing this. We recommend you use the most recent version
# that amzn2 provides. Also submit a PR to update the piece below.
#
variable "python_version" {
  default = "3.8"
}
