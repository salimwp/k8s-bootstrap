# k8s-bootstrap

This repo is intended to help setup a Kubernetes (K8s) for practicing concepts. This K8s requires the following:

* terraform
* libvirt/KVM installation either local or remote

Set the environment variable LIBVIRT_DEFAULT_URI to
qemu+ssh://<username>:<password>@<libvirt-ip>/system?sshauth-password

Ensure that you have configured SSH key login to prevent password prompts during the SSH connection phase.

