#!/bin/bash

DEBIAN_FRONTEND=noninteractive
UCF_FORCE_CONFFNEW=true
export UCF_FORCE_CONFFNEW DEBIAN_FRONTEND

echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
add-apt-repository -y ppa:webupd8team/java
apt-get update
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" dist-upgrade
apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" install ruby grub unzip kpartx oracle-java7-installer ant ant-contrib subversion git
apt-get clean

# Maven
MAVEN_VERSION="3.2.5"
cd /var/tmp
wget http://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
mkdir -p /opt/lib
tar -xf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/lib
ln -s /opt/lib/apache-maven-${MAVEN_VERSION}/bin/mvn /usr/bin/mvn

# Docker
wget -qO- https://get.docker.com/ | sh
usermod -aG docker ubuntu

# Packer
PACKER_VERSION="0.8.5"
mkdir -p /opt/lib/packer
cd /opt/lib/packer
wget https://dl.bintray.com/mitchellh/packer/packer_${PACKER_VERSION}_linux_amd64.zip
unzip packer_${PACKER_VERSION}_linux_amd64.zip
rm packer_${PACKER_VERSION}_linux_amd64.zip
ln -s /opt/lib/packer/* /usr/bin

# ec2-bundle-vol requires legacy grub and there should be no console setting
sed -i 's/console=hvc0/console=ttyS0/' /boot/grub/menu.lst
# the above is sufficient to fix 12.04 but 14.04 also needs the following
sed -i 's/LABEL=UEFI.*//' /etc/fstab

cd /var/tmp
mkdir ami_tools api_tools ec2
mkdir ec2/bin ec2/lib ec2/etc
export EC2_HOME=/var/tmp/ec2/bin
export PATH=$PATH:$EC2_HOME

cd /var/tmp/ami_tools
wget http://s3.amazonaws.com/ec2-downloads/ec2-ami-tools-1.5.7.zip
unzip ec2-ami-tools-1.5.7.zip

cd /var/tmp/api_tools
wget http://s3.amazonaws.com/ec2-downloads/ec2-api-tools.zip
unzip ec2-api-tools.zip

cd /var/tmp
mv ami_tools/ec2-ami-tools*/bin/* api_tools/ec2-api-tools*/bin/* ec2/bin/
mv ami_tools/ec2-ami-tools*/lib/* api_tools/ec2-api-tools*/lib/* ec2/lib/
mv ami_tools/ec2-ami-tools*/etc/* api_tools/ec2-api-tools*/etc/* ec2/etc/

passwd -d ubuntu
rm /home/ubuntu/.ssh/authorized_keys
