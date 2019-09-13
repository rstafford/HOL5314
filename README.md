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

