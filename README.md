# HOL5314

git clone https://github.com/rstafford/HOL5314.git

. ./setenv.sh

./add-helm-repo.sh

kubectl create namespace ns-user-00

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


