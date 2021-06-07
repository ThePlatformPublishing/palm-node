
locals {
  resource_prefix = "palm-node"
}

data "aws_ami" "ami_amzn2" {
  most_recent = true
  owners      = ["137112412989"] # amzn
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0*"]
  }
}


###########################
# monitoring
###########################
module "monitoring" {
  create_monitoring_node = var.create_monitoring_node
  source = "./modules/monitoring"
  region_details = var.region_details
  vpc_details = var.vpc_details
  node_details = {
    provisioning_path = "./files/monitoring"
    ami_id = data.aws_ami.ami_amzn2.id 
    instance_type = "t3.micro"
  }
  tags = var.tags
}


# ###########################
# # palm besu node
# ###########################
module "palmnodes" {
  source = "./modules/palm_node"
  region_details = var.region_details
  vpc_details = var.vpc_details
  ingress_ips = {
    discovery_cidrs = ["0.0.0.0/0"]
    rpc_cidrs = var.rpc_whitelist_cidrs
  }
  node_details = {
    provisioning_path = "./files/palmnode"
    ami_id = data.aws_ami.ami_amzn2.id 
    instance_type = var.node_details.instance_type
    volume_size = var.node_details.instance_volume_size
    palm_env = var.env_type
    palm_node_type = var.palm_node_type
  }
  tags = var.tags
}


