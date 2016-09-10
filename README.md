# Testing work-in-progress snapshot of `kubeadm` _(pre-alpha)_

You will need a few machines (2 or more), and a recent version of Docker installed (idealy 1.11, but 1.12 is known to work also).

First you want to run this as root on each of the machines you have:
```console
(all-machines) # docker run -v /usr/local:/target gcr.io/kubeadm/installer:preview
(all-machines) # systemctl daemon-reload && systemctl enable kubelet && systemctl start kubelet
```

Next, on the master run
```console
(master) # img="gcr.io/kubeadm/hyperkube:preview"
(master) # env \
  KUBE_HYPERKUBE_IMAGE="${img}" \
  KUBE_DISCOVERY_IMAGE="${img}" \
      kubeadm init
```

Once `kubeadm` has exited, install Weave Net addon with
```console
(master) # kubectl apply -f "https://github.com/weaveworks/weave-kube/blob/master/weave-daemonset.yaml?raw=true"
```

Finally, on each of the nodes run
```console
(any-node) # kubeadm join --token <BootsrapSecret> <master-ip-address>
```

Now the cluster should be ready to use!

## Using GCE

If you want, you can use a simple script provided in this repo to get get yourself a few instances on GCE

```console
> git clone https://github.com/errordeveloper/kubeadm-demo
> cd test-cluster-gce
> ./create-cluster.sh
```

Next, login to master and nodes with `gcloud compute ssh kube-master-1-0` and become root with `sudo su -`.

Before running the commands shown above, you might need to wait for a while for statrup script to finish installing Docker and pulling container image, you can use `journalctl | grep startup-script` to check if the startup script has finished.

Now, list nodes with `gcloud compute instance-groups list-instances kube-node-group-1` and login to each, also make sure to become root with `sudo su -`.

## Demo App

If you don't have an app to install, try our microservices referece app
```console
(master) # kubectl apply -f "https://github.com/lukemarsden/microservices-demo/blob/master/deploy/kubernetes/definitions/wholeWeaveDemo-NodePort.yaml?raw=true"
(master) # kubectl describe svc front-end
```

To get an idea of how the app works, you can install Weave Scope probe and connect it to [Weave Cloud](https://cloud.weave.works) using the token you get when you signup
```console
(master) # kubectl apply -f https://cloud.weave.works/launch/k8s/weavescope.json?token=<WeaveCloudToken>
```

> TODO: External LoadBalancer and NodePort
