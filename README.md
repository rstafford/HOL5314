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
   
   Wait until all are in a Running State.
   
1. Install Coherence cluster with log capture enabled

   > Note: In the following install we are pointing a temporary Coherence 
   > image but normally you would use a secret and
   > point to the Oracle Container Registry official image.
                                                          
   ```bash
   helm install \
   --namespace $NAMESPACE \
   --name storage \
   --set clusterSize=3 \
   --set cluster=storage-tier-cluster \
   --set logCaptureEnabled=true \
   --set coherence.image=tmiddlet/coherence:12.2.1.3.3 \
   coherence/coherence
   ```                
   
   Use `helm ls` and `kubectl get pods -n $NAMESPACE` and wait for the pods to be ready.
   
1. Port-forward Kibana

   Open a second terminal and ensure you run the following `setenv.sh` command.
   
      ```bash
   . ./setenv.sh
   ```   
   
   Then issue the following to port-forward the Kibana Port.
   
   ```bash
   port-forward-kibana.sh $NAMESPACE
   ```
   ```console
   Forwarding from 127.0.0.1:5601 -> 5601
   Forwarding from [::1]:5601 -> 5601
   ```     
   
1. Access Kibana using the following URL:

   [http://127.0.0.1:5601/](http://127.0.0.1:5601/)
   
   > **Note:** It can take up to 2-3 minutes for the data to reach the Elasticsearch instance.

Default Kibana Dashboards

There are a number of Kibana dashboards created via the import process.
* Coherence Operator - All Messages - Shows all Coherence Operator messages                                                |
* Coherence Cluster - All Messages - Shows all messages                                                                   |
* Coherence Cluster - Errors and Warnings - Shows only errors and warnings                                                       |
* Coherence Cluster - Persistence - Shows partition related messages                                                    |
* Coherence Cluster - Message Sources - Allows visualization of messages via the message source (Thread)                     |
* Coherence Cluster - Configuration Messages - Shows configuration related messages                                                 |
* Coherence Cluster - Network - Shows network related messages, such as communication delays and TCP ring disconnects |

## Default Queries

There are many queries related to common Coherence messages, warnings, and errors that are loaded and can be accessed via the `Discover` side-bar.
   
                                            
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


