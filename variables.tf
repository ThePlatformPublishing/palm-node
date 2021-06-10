
# which of the palm networks to use
variable "env_type" {
  default = "prd"
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
    ssh_key = "palm"
    ssh_key_path = "~/.ssh/palm.pem"
  }
}

variable "vpc_details" {
  type = map(string)
  default = {
    vpc_id = "vpc-012"
    vpc_cidr = "0.0.0.0/16"
    public_subnet = "subnet-012"
  }
}

variable "node_details" {
  type = map(string)
  default = {
    provisioning_path = "files/palmnode"
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

