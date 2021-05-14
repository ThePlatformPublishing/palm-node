
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

variable "node_details" {
  type = map(string)
  default = {
    provisioning_path = "files/monitoring"
    ami_id = ""
    instance_type = "t3.micro"
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

variable "amzn2_base_packages" {
  default = "wget curl ntp bind-utils iproute vim-enhanced git libselinux-python python python-pip python-setuptools python-virtualenv python3-pip python3 python3-setuptools jq sysstat awslogs make automake gcc gcc-c++ kernel-devel java-11-amazon-corretto.x86_64"
}
