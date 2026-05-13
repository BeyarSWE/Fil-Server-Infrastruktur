# 🛡️ Project 4: Secure File Server Infrastructure (IaC)

![Vagrant](https://img.shields.io/badge/Vagrant-2.3.4-1563FF?style=for-the-badge&logo=vagrant)
![Ansible](https://img.shields.io/badge/Ansible-2.17-EE0000?style=for-the-badge&logo=ansible)
![Ubuntu](https://img.shields.io/badge/Ubuntu-22.04-E95420?style=for-the-badge&logo=ubuntu)
![NFS](https://img.shields.io/badge/Protocol-NFS-brightgreen?style=for-the-badge)

This project is a fully automated, code-driven infrastructure (Infrastructure as Code) that sets up a secure file server system. Using Vagrant and Ansible, the project builds a private network with two virtual machines (a server and a client) and configures secure file sharing over the network.

## 🎯 Purpose and Goals
The purpose of the project was to design a digital "filing cabinet" for a fictional organization. The goal was to automate the creation of the environment, share folders over the network via NFS, and secure these folders with strict Linux permissions so that only authorized personnel (specific groups) have access.

---

## 👥 Division of Labor

The project was developed in close collaboration where we divided the infrastructure into two main areas of responsibility:

### 🧑‍💻 Beyar's Part (Network & Server)
* **Vagrant Environment:** Created the blueprint in `Vagrantfile` to automatically build and network-connect the file server (`192.168.50.10`) and the client (`192.168.50.11`).
* **Infrastructure & Delivery:** Developed Ansible code to install and configure the NFS service on the server.
* **Folder Structure:** Automated the creation of the underlying directories (e.g., `gemensam`, `avdelning-a`, `avdelning-b`) on the server.

### 🧑‍💻 Jacob's Part (Security & Client)
* **Identity Management:** Wrote Ansible code to create users (e.g., `jacob_a`) and security groups (`grupp_a`, `grupp_b`).
* **Digital Padlocks:** Implemented strict Linux permissions (Chmod `0770`) to ensure unauthorized users are denied access to specific departments.
* **Client Mounting:** Automated the NFS mount on the client side so users can smoothly access the network folders.
* **Security Inspection:** Developed an automated Bash script (`verifiering.sh`) that tests and proves the permissions work as intended.

---

## 🧗‍♂️ Challenges & What Was Hard

Building infrastructure as code wasn't a walk in the park. We ran into several frustrating roadblocks that required deep troubleshooting and patience:

### 1. The Windows vs. Ansible Wall 🧱
* **The Struggle:** We initially thought we could just run Ansible directly from our Windows computers. We kept getting errors saying Ansible couldn't be found. It took a lot of head-scratching and research to realize that Ansible natively *refuses* to run on Windows as a control node.
* **The Breakthrough:** We had to completely rethink our Vagrant provisioning logic. We discovered and implemented `ansible_local`, which brilliantly forces the virtual Ubuntu machines to install Ansible inside themselves and run the code locally. 

### 2. The Invisible Bug (CRLF vs. LF) 🐛
* **The Struggle:** Our security testing script (`verifiering.sh`) kept crashing on the Linux client with a bizarre `$'\r': command not found` error. We stared at the code for ages because the bash syntax was flawless.
* **The Breakthrough:** We learned the hard way about "Line Endings". Windows adds an invisible carriage return (CRLF) to the end of lines in text files, which completely breaks Linux scripts. We solved it by forcing VS Code to save the file in the Linux-native **LF** format.

### 3. The "Connection Refused" Race Condition ⏱️
* **The Struggle:** The client machine kept failing to mount the NFS share, throwing a "Connection refused" error. Our IP addresses and code were perfect, making it incredibly frustrating. 
* **The Breakthrough:** We realized it wasn't a code issue, but a *timing* issue. The client was knocking on the door before the server had fully finished setting up its NFS service. We fixed it by running `exportfs -ra` on the server and ensuring the server was 100% ready before running `vagrant provision client`.

### 4. Escaping the "Vim Trap" 🪤
* **The Struggle:** When combining Beyar's and Jacob's code on GitHub, we hit a Git merge conflict. The terminal suddenly threw us into the notorious Vim text editor. We were literally trapped and couldn't even figure out how to type or exit the screen.
* **The Breakthrough:** After some frantic searching, we learned the magic `:wq` command to safely escape Vim. We then moved over to VS Code's visual interface to systematically clean up the overlapping code and resolve the conflict.

### 5. Ghost Users in Security Testing 👻
* **The Struggle:** During our final security check, the test script kept failing because it said the user `jacob_a` didn't exist, even though Ansible had just created him!
* **The Breakthrough:** We realized that while Jacob existed on the *server* (the filing cabinet), he didn't exist on the *client* (the desk). We had to manually add the user profile to the client machine so the script could successfully "pretend" to be him and test the network locks.

---

## 🚀 Getting Started

To build and run the entire infrastructure, **VirtualBox** and **Vagrant** are required.

1. **Clone the repository:**
   ```bash
   git clone <https://github.com/BeyarSWE/Fil-Server-Infrastruktur>
   cd Fil-Server-Infrastruktur