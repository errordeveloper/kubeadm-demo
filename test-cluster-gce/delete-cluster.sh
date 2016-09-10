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

i="${1:-"1"}"

dynamic_firewall_rules=($(gcloud compute firewall-rules list --regexp 'k8s-fw-.*' --uri))

gcloud compute instances delete -q "kube-master-${i}-0"

gcloud compute instance-groups unmanaged delete -q "kube-master-group-${i}"

gcloud compute instance-groups managed delete -q "kube-node-group-${i}"

gcloud compute instance-templates delete -q "kube-node-template-${i}"

gcloud compute firewall-rules delete -q "kube-extfw-${i}" "kube-intfw-${i}" "kube-nodefw-${i}" "${dynamic_firewall_rules[@]}"

## TODO: handle cleanup of dynamically allocated resources (forwarding rules, static IPs etc)

gcloud compute networks delete -q "kube-net-${i}"
