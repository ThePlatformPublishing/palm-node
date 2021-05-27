
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
    provisioning_path = "files/besu"
    ami_id = ""
    instance_type = "m5.large"
    volume_size = "500"
    palm_env = "null"
    palm_node_type = "reader" # reader or validator
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

# make sure the besu_version and download_url match in the number
# eg: 1.3.8 for version is used for anything that contains 1.3.8-rc.. or 1.3.8-snapshot.. etc
variable "besu_version" {
  default = "21.1.4"
}

variable "amzn2_base_packages" {
  default = "wget curl ntp bind-utils iproute vim-enhanced git libselinux-python python python-pip python-setuptools python-virtualenv python3-pip python3 python3-setuptools jq sysstat awslogs make automake gcc gcc-c++ jq nvme-cli kernel-devel java-11-amazon-corretto.x86_64"
}

