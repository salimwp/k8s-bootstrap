# k8s-bootstrap

This repo is intended to help setup a Kubernetes (K8s) for practicing concepts. There are two bootstraping tools that are used to help bring upthe K8s cluster. Both will configure the basic infrastructure then use cloud-init to install the K8s controlplane and 2 worker nodes. The libvirt is recommended but for Windows users Vagrant/VirtualBox is available.

## Libvirt 

This K8s libvirt methoid requires the following:
* terraform
* libvirt/KVM installation either local or remote

https://github.com/dmacvicar/terraform-provider-libvirt/issues/886#issuecomment-1038676645
ssh -nNT -L localhost:5000:/run/libvirt/libvirt-sock <username>@<libvirt_server>
export LIBVIRT_DEFAULT_URI=qemu+tcp://localhost:5000/system

Set the environment variable LIBVIRT_DEFAULT_URI to
qemu+ssh://<username>:<password>@<libvirt-ip>/system?sshauth-password

Ensure that you have configured SSH key login to prevent password prompts during the SSH connection phase.

Go into the terraform-libvirt folder and run terraform init, plan then apply

After 10 minutes (depending on your network connection), you can log into the controlplane at 10.17.3.2 . Run kubectl get nodes to verify everything has been set up.

## Vagrant

This setup will require the Windows ADK to be download and install. You can get the package at the following URL https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install . Ensure that oscdimg.exe is in the path. 

Install Vagrant and VirtualBox on the Windows box (refer to the vendors instruction on how).

Install the vagrant-env plugin using the command below:
vagrant plugin install vagrant-env

Finally run vagrant up

