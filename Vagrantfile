Vagrant.configure("2") do |config|
    # Sätt upp Filservern
  config.vm.define "fileserver" do |server|
    server.vm.box = "ubuntu/SAKNAS"
    server.vm.hostname = "fileserver"
    server.vm.network "private_network", ip: "192.168.50.10"

    server.vm.provision "ansible" do |ansible|
        ansible.playbook = "asnible/filserver.yml"
    end
end

# Sätt upp Klienten (som Jacob ska använda senare)
  config.vm.define "client" do |client|
    client.vm.box = "ubuntu/jammy64"
    client.vm.hostname = "client"
    client.vm.network "private_network", ip: "192.168.50.11"
  end
end