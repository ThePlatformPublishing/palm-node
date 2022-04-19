

locals {
  resource_prefix = "palm-node-${var.node_details["palm_env"]}-${var.node_details["palm_node_type"]}"
}

data "template_file" "provision_data_volume" {
  template = "${file("${path.module}/templates/dataVolume.tpl")}"
  vars = {
    besu_data_volume_size = "${var.node_details["volume_size"]}"
  }
}

resource "aws_iam_role" "eth_nodes_role" {
  name               = "${local.resource_prefix}_eth_nodes_role"
  path               = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "eth_nodes_profile" {
  name = "${local.resource_prefix}_eth_nodes_profile"
  role = aws_iam_role.eth_nodes_role.name
}


resource "aws_security_group" "besu_discovery_sg" {
  name        = "${local.resource_prefix}-discovery-sg"
  description = "${local.resource_prefix}-discovery-sg"
  vpc_id      = var.vpc_details["vpc_id"]

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "tcp"
    cidr_blocks = var.ingress_ips.discovery_cidrs
  }

  ingress {
    from_port   = 30303
    to_port     = 30303
    protocol    = "udp"
    cidr_blocks = var.ingress_ips.discovery_cidrs
  } 

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    self      = true
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [ var.vpc_details["vpc_cidr"] ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "besu_rpc_sg" {
  name        = "${local.resource_prefix}-rpc-sg"
  description = "${local.resource_prefix}-rpc-sg"
  vpc_id      = var.vpc_details["vpc_id"]

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #8545= rpc, 8546=ws, 8547=graphql
  ingress {
    from_port   = 8545
    to_port     = 8547
    protocol    = "tcp"
    cidr_blocks = concat(var.ingress_ips.rpc_cidrs, [var.vpc_details["vpc_cidr"]])
  }
}

resource "aws_eip" "besu_node_eips" {
  vpc = true
  count = var.node_details["palm_node_count"]
  lifecycle {
    ignore_changes = all
  }
}

resource "aws_eip_association" "eip_palmnodes_associate" {
  instance_id   = aws_instance.besu_nodes[count.index].id
  allocation_id = aws_eip.besu_node_eips[count.index].id
  count   = var.node_details["palm_node_count"]
}

resource "aws_instance" "besu_nodes" {
  depends_on = [aws_eip.besu_node_eips]
  ami = var.node_details["ami_id"]
  instance_type = var.node_details["instance_type"]
  iam_instance_profile = aws_iam_instance_profile.eth_nodes_profile.name
  key_name = var.region_details["ssh_key"]
  subnet_id = var.vpc_details["public_subnet"]
  vpc_security_group_ids = [ aws_security_group.besu_discovery_sg.id, aws_security_group.besu_rpc_sg.id  ]
  associate_public_ip_address = true
  ebs_optimized = true
  root_block_device {
    volume_size = 100
  }
  # gp3 is current as at writing this, please update to any newer versions or variations of storage to suit your requirements
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_size = var.node_details["volume_size"]
    volume_type = "gp3"
    delete_on_termination = false
    tags = {
      Name = "${local.resource_prefix}-${count.index}-data"
      vpc = var.vpc_details["vpc_id"]
      projectName  = var.tags["project_name"]
      projectGroup = var.tags["project_group"]
      team         = var.tags["team"]
    }
  }
  count = var.node_details["palm_node_count"]
  tags = {
    Name = "${local.resource_prefix}-${count.index}"
    vpc = var.vpc_details["vpc_id"]
    projectName  = var.tags["project_name"]
    projectGroup = var.tags["project_group"]
    team         = var.tags["team"]
  }

  connection {
    type = "ssh"
    user = "ec2-user"
    host = "${self.public_ip}"
    private_key = "${file(pathexpand(var.region_details.ssh_key_path))}"
  }

  provisioner "file" {
    content = "${data.template_file.provision_data_volume.rendered}"
    destination = "/home/ec2-user/provision_volume.sh"
  }

  provisioner "file" {
    source = "${var.node_details["provisioning_path"]}/ansible"
    destination = "/home/ec2-user/besu"
  }

  provisioner "file" {
    source = "${var.node_details["provisioning_path"]}/${var.node_details["palm_env"]}/ansible/"
    destination = "/home/ec2-user/besu"
  }

  # WARNING:
  # amzn2 comes with python2.7 which is deprecated and installs for python3.8+ are via amzn extras only (as at time of writing this).
  # Symlinks are not created automatically so you need to do them here
  # 
  # 3.8 is not a recommended version and is just the current version as at writing this, please use the most recent version
  # that amzn2 provides. Also submit a PR to update the piece below.
  #
  # when the provisioner fires up, wait for the instance to signal its finished booting, before attempting to install packages
  provisioner "remote-exec" {
    inline = [
      "timeout 120 /bin/bash -c 'until stat /var/lib/cloud/instance/boot-finished 2>/dev/null; do echo waiting ...; sleep 5; done'",
      "sudo yum install -y ${var.amzn2_base_packages}",
      "sudo amazon-linux-extras install -y python${var.python_version}",
      "sudo ln --force --symbolic /usr/bin/python${var.python_version} /usr/bin/python3",
      "sudo ln --force --symbolic /usr/bin/pip${var.python_version} /usr/bin/pip3",
      "sudo sh $HOME/provision_volume.sh ",
      "wget -O $HOME/besu/genesis.json https://genesis-files.palm.io/${var.node_details["palm_env"]}/genesis.json",
      "sudo sh $HOME/besu/setup.sh '${aws_eip.besu_node_eips[count.index].public_ip}' '${var.node_details["palm_node_type"]}'",
      "sleep 30",
    ]
  }
  
  lifecycle {
    ignore_changes = all
  }
}



