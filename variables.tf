
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
    ssh_key = "pegasys-sydney"
    ssh_key_path = "~/.ssh/consensys/pegasys-sydney.pem"
  }
}

variable "vpc_details" {
  type = map(string)
  default = {
    vpc_id = "vpc-00a3a16d98f58571d"
    vpc_cidr = "10.2.0.0/16"
    public_subnet = "subnet-05c5829d52b97ded4"
  }
}

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
  default = "wget curl ntp bind-utils iproute vim-enhanced git libselinux-python python python-pip python-setuptools python-virtualenv python3-pip python3 python3-setuptools jq sysstat awslogs make automake gcc gcc-c++ kernel-devel java-11-amazon-corretto.x86_64"
}


variable "validator_node_count" {
  default = "1"
}

variable "tx_node_count" {
  default = "1"
}
