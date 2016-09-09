# Testing work-in-progress snapshot of `kubeadm`

You will need a few machine (2 or more), and install a recent version of Docker (1.11 is better support, but 1.12 is known to work also).

First you want to run this as root on each of the machines you have:
```console
sudo docker run -v /usr/local:/target gcr.io/kubeadm/installer
sudo systemctl daemon-reload && sudo systemctl enable kubelet && sudo systemctl start kubelet
```

Next, on the master run
```console
img="gcr.io/kubeadm/hyperkube:latest"
sudo env \
  KUBE_HYPERKUBE_IMAGE="${img}" \
  KUBE_DISCOVERY_IMAGE="${img}" \
      kubeadm init
```

Once `kubeadm` has exited, install Weave Net addon with
```console
kubectl apply -f "https://github.com/weaveworks/weave-kube/blob/master/weave-daemonset.yaml?raw=true"
```

Finally, on each of the nodes run
```console
sudo kubeadm join --token <BootsrapSecret> <master-ip-address>
```

If you don't have an app to install, try out microservices referece app
```console
kubectl apply -f "https://github.com/lukemarsden/microservices-demo/blob/master/deploy/kubernetes/definitions/wholeWeaveDemo-NodePort.yaml?raw=true"
kubectl describe svc front-end
```

To get an idea of how it all works, you can install Weave Scope probe and pass Weave Cloud token
```console
kubectl apply -f https://cloud.weave.works/launch/k8s/weavescope.json?token=<WeaveCloudToken>
```