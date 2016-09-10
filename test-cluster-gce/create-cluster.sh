#!/bin/bash -ex

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

i="${1:-"1"}"

gcloud compute networks create "kube-net-${i}" \
  --mode 'auto'

gcloud compute firewall-rules create "kube-extfw-${i}" \
  --network "kube-net-${i}" \
  --allow 'tcp:22,tcp:4040' \
  --target-tags "kube-ext-${i}" \
  --description 'External access only for SSH'

gcloud compute firewall-rules create "kube-intfw-${i}" \
  --network "kube-net-${i}" \
  --allow 'tcp:443,tcp:9898,tcp:6783,udp:6783-6784' \
  --source-tags "kube-int-${i}" \
  --target-tags "kube-int-${i}" \
  --description 'Internal access for the API & Weave Net ports'

gcloud compute firewall-rules create "kube-nodefw-${i}" \
  --network "kube-net-${i}" \
  --allow 'tcp,udp,icmp,esp,ah,sctp' \
  --source-tags "kube-node-${i}" \
  --target-tags "kube-node-${i}" \
  --description 'Internal access to all ports on the nodes'

gcloud compute instance-groups unmanaged create "kube-master-group-${i}"

common_instace_flags=(
  --network kube-net-${i}
  --image-family centos-7
  --image-project centos-cloud
  --metadata-from-file startup-script=provision.sh
  --boot-disk-type pd-ssd
  --machine-type n1-standard-8
  --can-ip-forward
)

gcloud compute instances create "kube-master-${i}-0" \
  "${common_instace_flags[@]}" \
  --tags "kube-int-${i},kube-ext-${i}" \
  --scopes 'storage-ro,compute-rw,monitoring,logging-write'

gcloud compute instance-groups unmanaged add-instances "kube-master-group-${i}" \
  --instances "kube-master-${i}-0"

gcloud compute instance-templates create "kube-node-template-${i}" \
  "${common_instace_flags[@]}" \
  --tags "kube-int-${i},kube-ext-${i},kube-node-${i}" \
  --scopes 'storage-ro,compute-rw,monitoring,logging-write'

gcloud compute instance-groups managed create "kube-node-group-${i}" \
  --template "kube-node-template-${i}" \
  --base-instance-name "kube-node-${i}" \
  --size 3
