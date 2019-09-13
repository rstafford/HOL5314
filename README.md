# HOL5314 - Coherence Operator Hands-On Lab

# Initial "Once-Only" Setup

After initial clone of the repository, carry out the following to setup your environment for the lab.

1. Setup your environment

   You will be asked for your assigned user number which will set the NAMESPACE environment variable
   which is used in eac of the `helm` and `kubectl` commands.

   ```bash
   . ./setenv.sh
   ```           
   
   > Note: Ensure you run this command in any terminal you open.

1. Run the following setup script to clone various repositories

   ```bash
   ./setup.sh
   ```       
   
   > Note: If there are any errors, please refer to the `logs` directory.
   
1. Create a namespace using the user number assigned to you. The `NAMESPACE` environment variable has been set in the `. ./setenv.sh` step above. 

   E.g. for user `01`:
   
   ```bash
   kubectl create namespace $NAMESPACE
   ```

# LAB 1 - Install the Coherence Operator and view Logs in Kibana

This Lab shows how to enable log capture and access the Kibana user interface (UI) to view the captured logs.

1. Install Coherence Operator

   Use the following command to install `coherence-operator` with log capture enabled.
   
   ```bash
   helm install \
   --namespace $NAMESPACE \
   --name coherence-operator \
   --set logCaptureEnabled=true \
   --set "targetNamespaces={$NAMESPACE}" \
   coherence/coherence-operator
   ```

   List the installed releases:
   
   ```bash
   helm ls
   ```

   List the installed pods:
   
   ```bash
   kubectl get pods -n $NAMESPACE
   ``` 
helm ls
 (until running)

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


