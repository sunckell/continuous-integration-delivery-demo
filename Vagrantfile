# -*- mode: ruby -*-
# vi: set ft=ruby :
$script = <<SCRIPT

echo "custom >> updating system and installing dependencies..."
sudo apt-get update > /dev/null
sudo apt-get -y upgrade > /dev/null
sudo apt-get install -y unzip curl awscli
sudo apt-get clean

echo
echo "custom >> installing Hashicorp tooling..."
echo

echo "custom >> fetching terraform..."
cd /tmp/
curl -s https://releases.hashicorp.com/terraform/0.6.16/terraform_0.6.16_linux_amd64.zip -o terraform.zip

echo "custom >> installing terraform..."
unzip terraform.zip
sudo chmod +x terraform* 
sudo mv terraform* /usr/bin/

echo "custom >> fetching packer..."
cd /tmp/
curl -s https://releases.hashicorp.com/packer/0.10.1/packer_0.10.1_linux_amd64.zip -o packer.zip

echo "custom >> installing packer..."
unzip packer.zip
sudo chmod +x packer 
sudo mv packer /usr/bin/

SCRIPT

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "concourse/lite"

  config.vm.provision "shell", inline: $script

  config.vm.define "n1" do |n1|
      n1.vm.hostname = "n1"

      post_up_message = %q{
        ****************************************************************
           access the concourse server via: http://192.168.100.4:8080

           you will need to download fly, the concourse client and
           add it to your path. The download link is available at
           the url above.

        ****************************************************************
      }

      n1.vm.post_up_message = post_up_message
      
  end
  
end
