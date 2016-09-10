#!/bin/bash -x

# Copyright 2016 The Kubernetes Authors All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

yum -q -y update

curl -fsSL https://get.docker.com/ | sh

#yum -q -y install docker

systemctl start docker

/usr/bin/docker version

if ! [ -x /usr/bin/weave ] ; then
  echo "Installing current version of Weave Net"
  curl --silent --location http://git.io/weave --output /usr/bin/weave
  chmod +x /usr/bin/weave
  /usr/bin/weave setup
fi

/usr/bin/weave version

docker pull gcr.io/kubeadm/installer:preview
docker pull gcr.io/kubeadm/hyperkube:preview

case "$(hostname)" in
  kube-master-0)
    ;;
  ## kube-[5..N] are the cluster nodes
  kube-node-*)
    ;;
esac
