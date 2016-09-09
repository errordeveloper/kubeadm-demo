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
> cd simple-gce-test-cluster
> ./create-cluster.sh
```

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
