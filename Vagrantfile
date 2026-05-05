# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider "vmware_desktop" do |v|
    v.gui = false
  end

  # 1. Vùng LAN - Ubuntu 20.04
  config.vm.define "lan-ubuntu" do |lan|
    lan.vm.box = "bento/ubuntu-20.04"
    lan.vm.hostname = "lan-ubuntu"

    # LAN subnet: 192.168.10.0/24
    # OpenWRT LAN gateway: 192.168.10.1
    lan.vm.network "private_network", ip: "192.168.10.100"

    lan.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "LAN_Ubuntu_Nhom18"
      v.vmx["memsize"] = "1024"
      v.vmx["numvcpus"] = "1"
    end

    lan.vm.provision "shell", inline: <<-SHELL
      sudo apt-get -o Acquire::ForceIPv4=true update || true
      sudo apt-get -o Acquire::ForceIPv4=true install -y python3 || true

      sudo ip route del default || true
      sudo ip route add default via 192.168.10.1 dev eth1 || true
    SHELL
  end

  # 2. Vùng GUEST - Ubuntu 20.04
  config.vm.define "guest-ubuntu" do |guest|
    guest.vm.box = "bento/ubuntu-20.04"
    guest.vm.hostname = "guest-ubuntu"

    # GUEST subnet: 192.168.2.0/24
    # OpenWRT GUEST gateway: 192.168.2.1
    guest.vm.network "private_network", ip: "192.168.2.100"

    guest.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "GUEST_Ubuntu_Nhom18"
      v.vmx["memsize"] = "1024"
      v.vmx["numvcpus"] = "1"
    end

    guest.vm.provision "shell", inline: <<-SHELL
      sudo apt-get -o Acquire::ForceIPv4=true update || true
      sudo apt-get -o Acquire::ForceIPv4=true install -y python3 || true

      sudo ip route del default || true
      sudo ip route add default via 192.168.2.1 dev eth1 || true
    SHELL
  end

  # 3. Máy ảo WAN Attacker - Ubuntu 20.04
  config.vm.define "wan-attacker" do |wan|
    wan.vm.box = "bento/ubuntu-20.04"
    wan.vm.hostname = "wan-attacker"

    # WAN subnet: 192.168.0.0/24
    # Attacker IP: 192.168.0.10
    wan.vm.network "private_network", ip: "192.168.0.10"

    wan.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "WAN_Attacker_Nhom18"
      v.vmx["memsize"] = "1024"
      v.vmx["numvcpus"] = "1"
    end

    wan.vm.provision "shell", inline: <<-SHELL
      sudo apt-get -o Acquire::ForceIPv4=true update || true
      sudo apt-get -o Acquire::ForceIPv4=true install -y python3 nmap curl netcat-openbsd || true
    SHELL
  end

end
