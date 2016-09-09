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

gcloud compute networks create 'kube-net' \
  --mode 'auto'

gcloud compute firewall-rules create 'kube-extfw' \
  --network 'kube-net' \
  --allow 'tcp:22,tcp:4040' \
  --target-tags 'kube-ext' \
  --description 'External access only for SSH'

gcloud compute firewall-rules create 'kube-intfw' \
  --network 'kube-net' \
  --allow 'tcp:443,tcp:9898,tcp:6783,udp:6783-6784' \
  --source-tags 'kube-int' \
  --target-tags 'kube-int' \
  --description 'Internal access for the API & Weave Net ports'

gcloud compute firewall-rules create 'kube-nodefw' \
  --network 'kube-net' \
  --allow 'tcp,udp,icmp,esp,ah,sctp' \
  --source-tags 'kube-node' \
  --target-tags 'kube-node' \
  --description 'Internal access to all ports on the nodes'

gcloud compute instance-groups unmanaged create 'kube-master-group'

common_instace_flags=(
  --network kube-net
  --image-family centos-7
  --image-project centos-cloud
  --metadata-from-file startup-script=provision.sh
  --boot-disk-type pd-standard
)

gcloud compute instances create 'kube-master-0' \
  "${common_instace_flags[@]}" \
  --tags 'kube-int,kube-ext' \
  --boot-disk-size '10GB' \
  --can-ip-forward \
  --scopes 'storage-ro,compute-rw,monitoring,logging-write'

gcloud compute instance-groups unmanaged add-instances 'kube-master-group' \
  --instances 'kube-master-0'

gcloud compute instance-templates create 'kube-node-template' \
  "${common_instace_flags[@]}" \
  --tags 'kube-int,kube-ext,kube-node' \
  --boot-disk-size '30GB' \
  --can-ip-forward \
  --scopes 'storage-ro,compute-rw,monitoring,logging-write'

gcloud compute instance-groups managed create 'kube-node-group' \
  --template 'kube-node-template' \
  --base-instance-name 'kube-node' \
  --size 3
