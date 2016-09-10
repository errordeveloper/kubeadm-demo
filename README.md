# Testing work-in-progress snapshot of `kubeadm` _(pre-alpha)_

You will need a few machines (2 or more), and a recent version of Docker installed (idealy v1.11.2 or v1.10.3, but v1.12.1 is also known to work).

First you want to run this as root on each of the machines you have:
```console
(all-machines) # docker run -v /usr/local:/target gcr.io/kubeadm/installer:preview
(all-machines) # systemctl daemon-reload && systemctl enable kubelet && systemctl start kubelet
```

> Please note, the installer image is provided for this preview demo to work, soon we should have traditional packages for popular Linux distributions.

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

### Set up the master

Next, login to master and nodes with _`gcloud compute ssh kube-master-1-0`_ and become root with **`sudo su -`**.

Before running the commands shown above, you might need to wait for a while for statrup script to finish installing Docker and pulling container image, you can use _`journalctl | grep startup-script`_ to check if the startup script has finished.

<details>
Login to master and become root:
```
> gcloud compute ssh kube-master-1-0
Warning: Permanently added 'compute.1236589767647167447' (ECDSA) to the list of known hosts.
[ilya@kube-master-1-0 ~]$ sudo su -
```
Now run the commands shown above and this what you should see:
```
[root@kube-master-1-0 ~]# docker run -v /usr/local:/target gcr.io/kubeadm/installer:preview
Installing binaries for Kubernetes (git-b31dfaf) and systemd configuration...

created directory: '/target/lib/systemd/'
created directory: '/target/lib/systemd/system'
'/opt/kube-b31dfaf/kubelet' -> '/target/bin/kubelet'
'/opt/kube-b31dfaf/kubeadm' -> '/target/bin/kubeadm'
'/opt/kube-b31dfaf/kubectl' -> '/target/bin/kubectl'
'/opt/kube-b31dfaf/kubelet.service' -> '/target/lib/systemd/system/kubelet.service'

Installing generic CNI plugins and configuration...

created directory: '/target/lib/cni/'
created directory: '/target/lib/cni/bin'
created directory: '/target/etc/cni/'
created directory: '/target/etc/cni/net.d'
'/opt/kube-b31dfaf/cni/cnitool' -> '/target/lib/cni/bin/cnitool'
'/opt/kube-b31dfaf/cni/flannel' -> '/target/lib/cni/bin/flannel'
'/opt/kube-b31dfaf/cni/tuning' -> '/target/lib/cni/bin/tuning'
'/opt/kube-b31dfaf/cni/bridge' -> '/target/lib/cni/bin/bridge'
'/opt/kube-b31dfaf/cni/ipvlan' -> '/target/lib/cni/bin/ipvlan'
'/opt/kube-b31dfaf/cni/loopback' -> '/target/lib/cni/bin/loopback'
'/opt/kube-b31dfaf/cni/macvlan' -> '/target/lib/cni/bin/macvlan'
'/opt/kube-b31dfaf/cni/ptp' -> '/target/lib/cni/bin/ptp'
'/opt/kube-b31dfaf/cni/dhcp' -> '/target/lib/cni/bin/dhcp'
'/opt/kube-b31dfaf/cni/host-local' -> '/target/lib/cni/bin/host-local'

Binaries and configuration files had been installed, you can now start kubelet and run kubeadm.

> sudo systemctl daemon-reload && sudo systemctl enable kubelet && sudo systemctl start kubelet

If this host is going to be the master, run:

> sudo env KUBE_HYPERKUBE_IMAGE=gcr.io/kubeadm/hyperkube:latest KUBE_DISCOVERY_IMAGE=gcr.io/kubeadm/hyperkube:latest kubeadm init

If it's going to be a node, run:

> sudo kubeadm join --token=<...> <master-ip-address>

Have fun, and enjoy!
[root@kube-master-1-0 ~]# systemctl daemon-reload && systemctl enable kubelet && systemctl start kubelet
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/local/lib/systemd/system/kubelet.service.
[root@kube-master-1-0 ~]# img="gcr.io/kubeadm/hyperkube:preview"
[root@kube-master-1-0 ~]# env \
>   KUBE_HYPERKUBE_IMAGE="${img}" \
>   KUBE_DISCOVERY_IMAGE="${img}" \
>       kubeadm init
<master/tokens> generated token: "8f1120.76bb5536ee4d0027"
<master/pki> created keys and certificates in "/etc/kubernetes/pki"
<util/kubeconfig> created "/etc/kubernetes/kubelet.conf"
<util/kubeconfig> created "/etc/kubernetes/admin.conf"
<master/apiclient> created API client configuration
<master/apiclient> created API client, waiting for the control plane to become ready
<master/apiclient> all control plane components are healthy after 39.304626 seconds
<master/apiclient> waiting for at least one node to register and become ready
<master/apiclient> first node is ready after 5.002980 seconds
<master/discovery> created essential addon: kube-discovery
<master/addons> created essential addon: kube-proxy
<master/addons> created essential addon: kube-dns

Kubernetes master initialised successfully!

You can connect any number of nodes by running:

kubeadm join --token 8f1120.76bb5536ee4d0027 10.132.0.2
[root@kube-master-1-0 ~]#
```
</details>

### Setup the nodes

Now, list nodes with _`gcloud compute instance-groups list-instances kube-node-group-1`_ and login to _each node_, and also make sure to become root using **`sudo su -`**.

<details>
List GCE node group, login to one of them and become root:
```
> gcloud compute instance-groups list-instances kube-node-group-1
NAME              STATUS
kube-node-1-9kqt  RUNNING
kube-node-1-iqmm  RUNNING
kube-node-1-le1l  RUNNING
> gcloud compute ssh kube-node-1-9kqt
Warning: Permanently added 'compute.8178251147077616560' (ECDSA) to the list of known hosts.
[ilya@kube-node-1-9kqt ~]$ sudo su -
[root@kube-node-1-9kqt ~]# journalctl | grep startup-script | tail -1
Sep 10 08:02:33 kube-node-1-9kqt startup-script[1367]: INFO Finished running startup scripts.
[root@kube-node-1-9kqt ~]# docker run -v /usr/local:/target gcr.io/kubeadm/installer:preview
Installing binaries for Kubernetes (git-b31dfaf) and systemd configuration...

created directory: '/target/lib/systemd/'
created directory: '/target/lib/systemd/system'
'/opt/kube-b31dfaf/kubelet' -> '/target/bin/kubelet'
'/opt/kube-b31dfaf/kubeadm' -> '/target/bin/kubeadm'
'/opt/kube-b31dfaf/kubectl' -> '/target/bin/kubectl'
'/opt/kube-b31dfaf/kubelet.service' -> '/target/lib/systemd/system/kubelet.service'

Installing generic CNI plugins and configuration...

created directory: '/target/lib/cni/'
created directory: '/target/lib/cni/bin'
created directory: '/target/etc/cni/'
created directory: '/target/etc/cni/net.d'
'/opt/kube-b31dfaf/cni/cnitool' -> '/target/lib/cni/bin/cnitool'
'/opt/kube-b31dfaf/cni/flannel' -> '/target/lib/cni/bin/flannel'
'/opt/kube-b31dfaf/cni/tuning' -> '/target/lib/cni/bin/tuning'
'/opt/kube-b31dfaf/cni/bridge' -> '/target/lib/cni/bin/bridge'
'/opt/kube-b31dfaf/cni/ipvlan' -> '/target/lib/cni/bin/ipvlan'
'/opt/kube-b31dfaf/cni/loopback' -> '/target/lib/cni/bin/loopback'
'/opt/kube-b31dfaf/cni/macvlan' -> '/target/lib/cni/bin/macvlan'
'/opt/kube-b31dfaf/cni/ptp' -> '/target/lib/cni/bin/ptp'
'/opt/kube-b31dfaf/cni/dhcp' -> '/target/lib/cni/bin/dhcp'
'/opt/kube-b31dfaf/cni/host-local' -> '/target/lib/cni/bin/host-local'

Binaries and configuration files had been installed, you can now start kubelet and run kubeadm.

> sudo systemctl daemon-reload && sudo systemctl enable kubelet && sudo systemctl start kubelet

If this host is going to be the master, run:

> sudo env KUBE_HYPERKUBE_IMAGE=gcr.io/kubeadm/hyperkube:latest KUBE_DISCOVERY_IMAGE=gcr.io/kubeadm/hyperkube:latest kubeadm init

If it's going to be a node, run:

> sudo kubeadm join --token=<...> <master-ip-address>

Have fun, and enjoy!
```
Run `kubeadm join` with arguments which `kubeadm init` printed on the master:
```
[root@kube-node-1-9kqt ~]# systemctl daemon-reload && systemctl enable kubelet && systemctl start kubelet
Created symlink from /etc/systemd/system/multi-user.target.wants/kubelet.service to /usr/local/lib/systemd/system/kubelet.service.
[root@kube-node-1-9kqt ~]# kubeadm join --token 8f1120.76bb5536ee4d0027 10.132.0.2
<util/tokens> validating provided token
<node/discovery> created cluster info discovery client, requesting info from "http://10.132.0.2:9898/cluster-info/v1/?token-id=8f1120"
<node/discovery> cluster info object received, verifying signature using given token
<node/discovery> cluster info signature and contents are valid, will use API endpoints [https://10.132.0.2:443]
<node/csr> created API client to obtain unique certificate for this node, generating keys and certificate signing request
<node/csr> received signed certificate from the API server, generating kubelet configuration
<util/kubeconfig> created "/etc/kubernetes/kubelet.conf"

Node join complete:
* Certificate signing request sent to master and response
  received.
* Kubelet informed of new secure connection details.

Run 'kubectl get nodes' on the master to see this node join.
[root@kube-node-1-9kqt ~]# logout
[ilya@kube-node-1-9kqt ~]$ logout
Connection to 146.148.113.59 closed.
```
Now do the same on other two nodes...
</details>

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
