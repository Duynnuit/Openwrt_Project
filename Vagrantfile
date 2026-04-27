# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.provider "vmware_desktop" do |v|
    v.gui = false
  end

  # 1. Router OpenWRT (Soft-Router
  config.vm.define "openwrt" do |router|
    router.vm.box = "generic/openwrt"
    router.vm.hostname = "OpenWrt"

    # eth0 mặc định là NAT (ra Internet qua host)
    
    # eth1: Vùng LAN (Vagrant tự động map các IP cùng dải vào chung một VMnet ẩn)
    router.vm.network "private_network", ip: "192.168.1.1"

    # eth2: Vùng GUEST
    router.vm.network "private_network", ip: "192.168.2.1"

    router.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "OpenWRT_Router_Nhom18"
      v.vmx["memsize"] = "512"
      v.vmx["numvcpus"] = "1"
    end
  end


  # 2. Vùng LAN - Ubuntu 20.04

  config.vm.define "lan-ubuntu" do |lan|
    lan.vm.box = "bento/ubuntu-20.04"
    lan.vm.hostname = "lan-ubuntu"

    lan.vm.network "private_network", ip: "192.168.1.100"

    lan.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "LAN_Ubuntu_Nhom18"
      v.vmx["memsize"] = "1024"
      v.vmx["numvcpus"] = "1"
    end

    # Trỏ Gateway về OpenWRT và cài Python3 cho Ansible
    lan.vm.provision "shell", inline: <<-SHELL
      sudo ip route del default
      sudo ip route add default via 192.168.1.1
      sudo apt-get update && sudo apt-get install -y python3
    SHELL
  end


  # 3. Vùng GUEST - Ubuntu 20.04
  config.vm.define "guest-ubuntu" do |guest|
    guest.vm.box = "bento/ubuntu-20.04"
    guest.vm.hostname = "guest-ubuntu"

    guest.vm.network "private_network", ip: "192.168.2.100"

    guest.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "GUEST_Ubuntu_Nhom18"
      v.vmx["memsize"] = "1024"
      v.vmx["numvcpus"] = "1"
    end

    # Trỏ Gateway về OpenWRT và cài Python3
    guest.vm.provision "shell", inline: <<-SHELL
      sudo ip route del default
      sudo ip route add default via 192.168.2.1
      sudo apt-get update && sudo apt-get install -y python3
    SHELL
  end

  # 4. Máy ảo WAN Attacker - Ubuntu 20.04
  config.vm.define "wan-attacker" do |wan|
    wan.vm.box = "bento/ubuntu-20.04"
    wan.vm.hostname = "wan-attacker"

    # Nằm ở dải mạng mô phỏng WAN
    wan.vm.network "private_network", ip: "192.168.0.10"

    wan.vm.provider "vmware_desktop" do |v|
      v.vmx["displayname"] = "WAN_Attacker_Nhom18"
      v.vmx["memsize"] = "1024"
      v.vmx["numvcpus"] = "1"
    end
    
    # Cài Python3 và nmap để test
    wan.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update && sudo apt-get install -y python3 nmap
    SHELL
  end

end