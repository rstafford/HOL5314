# HOL5314 - Coherence Operator Hands-On Lab

# Initial "Once-Only" Setup

After initial clone of the repository, carry out the following to setup your environment for the lab.

1. Setup your environment

   ```bash
   . ./setenv.sh
   ```

1. Run the following setup script to clone various repositories

   ```bash
   ./add-helm-repo.sh
   ``` 
   
1. Create a namespace using the user number assigned to you. E.g. 01-20   

   E.g. for user `01`:
   
   ```bash
   kubectl create namespace ns-user-01
   ```

1. 

   ```bash
   
   ```
helm install \
   --namespace ns-user-00 \
   --name coherence-operator \
   --set logCaptureEnabled=true \
   --set "targetNamespaces={ns-user-00}" \
   coherence/coherence-operator

helm ls
kubectl get pods -n ns-user-00 (until running)

open new tab; source setenv
run port-forward-kibana <namespace>
in browser 127.0.0.1:5601 to access Kibana

helm install \
   --namespace ns-user-00 \
   --name storage \
   --set clusterSize=3 \
   --set cluster=storage-tier-cluster \
   --set logCaptureEnabled=true \
   --set coherence.image=tmiddlet/coherence:12.2.1.3.3 \
   coherence/coherence


