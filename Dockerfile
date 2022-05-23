FROM ubuntu:22.04

WORKDIR /root

# Base dependencies

ENV DEBIAN_FRONTEND=noninteractive TZ=Europe/London
RUN apt-get -y update && apt-get -y upgrade
RUN apt-get install -y gnupg software-properties-common \ 
    curl git python3-pip python3 python3-setuptools jq \
    wget unzip

# Terraform installation (from source)

ARG TERRAFORM_VERSION=1.2.0 PLATFORM=linux_amd64
RUN wget https://releases.hashicorp.com/terraform/$TERRAFORM_VERSION/terraform_${TERRAFORM_VERSION}_$PLATFORM.zip
RUN unzip terraform_${TERRAFORM_VERSION}_$PLATFORM.zip
RUN mv ~/terraform /usr/bin/

# Ansible installation

RUN add-apt-repository -y --update ppa:ansible/ansible
RUN apt update -y && apt install -y ansible

WORKDIR /palm-node

COPY . .
