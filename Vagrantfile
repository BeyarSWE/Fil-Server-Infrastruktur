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