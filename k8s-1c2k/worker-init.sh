#!/bin/bash

until curl -k https://k8s-controlplane:6443
do
    echo "Waiting for k8s controller"
    sleep 5
done

kubeadm join k8s-controlplane:6443 --token 123456.1234567890123456 --discovery-token-unsafe-skip-ca-verification