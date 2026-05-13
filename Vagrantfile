Vagrant.configure("2") do |config|
  
  # ==========================================
  # 1. FILSERVERN (Både Beyars och Jacobs del)
  # ==========================================
  config.vm.define "fileserver" do |server|
    server.vm.box = "ubuntu/jammy64"
    server.vm.hostname = "fileserver"
    server.vm.network "private_network", ip: "192.168.50.10"
    
    # STEG A: Kör Beyars grundinstallation (Installerar NFS och skapar mappar)
    server.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/fileserver.yml"
    end

    # STEG B: Kör Jacobs säkerhetskonfiguration (Användare, grupper och hänglås)
    server.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/server_sakerhet.yml"
    end
  end

  # ==========================================
  # 2. KLIENTEN (Både Beyars och Jacobs del)
  # ==========================================
  config.vm.define "client" do |client|
    client.vm.box = "ubuntu/jammy64"
    client.vm.hostname = "client"
    client.vm.network "private_network", ip: "192.168.50.11"

    # STEG C: Kör Jacobs monteringsskript (Kopplar ihop klienten med servern)
    client.vm.provision "ansible_local" do |ansible|
      ansible.playbook = "ansible/klient_montering.yml"
    end
  end

end