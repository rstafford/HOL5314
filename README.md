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

# LAB Guides

## LAB 1 - Install the Coherence Operator and view Logs in Kibana

This Lab shows how to enable log capture and access the Kibana user interface (UI) to view the captured logs.

> Note: Because many people are using the same cluster, helm release names need to be unique so
> we are suffixing any helm names with your `NAMESPACE`.
> If you do not specify a name, then a generatet one will be created.

1. Install Coherence Operator

   Use the following command to install `coherence-operator` with log capture enabled.
   
   ```bash
   helm install \
   --namespace $NAMESPACE \
   --name coherence-operator-$NAMESPACE \
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
   --name storage-${NAMESPACE} \
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
   
   Then issue the following to port-forward the Kibana Port:
   
   ```bash
   port-forward-kibana.sh $NAMESPACE
   Forwarding from 127.0.0.1:5601 -> 5601
   Forwarding from [::1]:5601 -> 5601
   ```     
   
1. Access Kibana using the following URL:

   [http://127.0.0.1:5601/](http://127.0.0.1:5601/)
   
   > **Note:** It can take up to 2-3 minutes for the data to reach the Elasticsearch instance.

   **Default Kibana Dashboards**

   There are a number of Kibana dashboards created via the import process.
   * Coherence Operator - All Messages - Shows all Coherence Operator messages                                             
   * Coherence Cluster - All Messages - Shows all messages                                                             
   * Coherence Cluster - Errors and Warnings - Shows only errors and warnings                                                   
   * Coherence Cluster - Persistence - Shows partition related messages                                                   
   * Coherence Cluster - Message Sources - Allows visualization of messages via the message source (Thread)                 
   * Coherence Cluster - Configuration Messages - Shows configuration related messages                                   
   * Coherence Cluster - Network - Shows network related messages, such as communication delays and TCP ring disconnects 

   **Default Queries**

   There are many queries related to common Coherence messages, warnings, and errors that are loaded 
   and can be accessed via the `Discover` side-bar.
   
3. Port forward the proxy port on the storage-coherence-0 pod using the `kubectl` command:

   Open a third terminal and ensure you run the following `setenv.sh` command.
   
   ```bash
   . ./setenv.sh
   ```   

   Then issue the following to port-forward the default Coherence*Extend port:
   
   ```bash
   $ kubectl port-forward -n $NAMESPACE storage-${NAMESPACE}-coherence-0 20000:20000
   ```

4. Connect via CohQL and run the following commands:

   In your first terminal, change to the following directory:
   
   ```bash
   cd ../coherence-operator/docs/samples/coherence-deployments/extend/default
   ```
   
   ```bash
   $ mvn exec:java
   ```

   Run the following `CohQL` commands to insert data into the cluster.

   ```sql
   insert into 'test' key('key-1') value('value-1');

   select key(), value() from 'test';
   Results
   ["key-1", "value-1"]

   select count() from 'test';
   Results
   1
   ```
    
1. Uninstall the Coherence Chart

   Before you continue to the next lab, use the following commands to delete the chart installed in this sample:

   ```bash
   helm delete storage-${NAMESPACE} --purge
   ```     
   
1. Ensure you stop the port-forward commands using `CTRL-C`.   
  
## LAB 2 - Install the Coherence Demo Application
   
This lab show how to build and run the Coherence Demonstration application. 
The application showcases Coherence general features, scalability capabilities, and new features of 12.2.1 version including:

* Cache Persistence
* Federation
* Java 8 Support
      
The steps to run the application on Kubernetes comprises the following Helm chart installs:
* Oracle Coherence Operator (Already complete)
* Coherence Cluster - storage-enabled Coherence servers
* Coherence Application Tier - storage-disabled with Grizzly HTTP Server 
          
1. Build and Push Sidecar Docker Image

   The Oracle Coherence Operator requires a sidecar Docker image to be built containing 
   he classes and configuration files required by the application.

   > Note: for the purposes of this Lab, the Docker image has already been created and is available as
   > `tmiddlet/coherence-demo-sidecar:3.0.0-SNAPSHOT`.
   > If you wish to build it, please follow the instructions in step 3 [here](https://github.com/coherence-community/coherence-demo#run-the-application-on-kubernetes-coherence-12213x).

1. Install the Coherence Cluster

   ```bash
   helm install \
      --namespace $NAMESPACE \
      --name coherence-demo-storage-${NAMESPACE} \
      --set clusterSize=1 \
      --set cluster=PrimaryCluster \
      --set store.cacheConfig=cache-config.xml \
      --set store.pof.config=pof-config.xml \
      --set store.javaOpts="-Dwith.http=false" \
      --set store.maxHeap=512m \
      --set userArtifacts.image=tmiddlet/coherence-demo-sidecar:3.0.0-SNAPSHOT \
      --set coherence.image=tmiddlet/coherence:12.2.1.3.3 \
      coherence/coherence
   ```
 
   Use `helm ls` and `kubectl get pods -n $NAMESPACE` and wait for the Coherence pod to be ready.  
   
1. Install the Application Tier

   Install the application tier using the following command:

   ```bash
   helm install \
      --namespace $NAMESPACE \
      --name coherence-demo-app-${NAMESPACE} \
      --set clusterSize=1 \
      --set cluster=PrimaryCluster \
      --set store.cacheConfig=cache-config.xml \
      --set store.pof.config=pof-config.xml \
      --set store.wka=coherence-demo-storage-${NAMESPACE}-headless \
      --set store.javaOpts="-Dcoherence.distributed.localstorage=false"  \
      --set store.maxHeap=512m \
      --set userArtifacts.image=coherence-demo-sidecar:3.0.0-SNAPSHOT \
      --set coherence.image=tmiddlet/coherence:12.2.1.3.3 \
      coherence/coherence
   ```  

1. Port Forward the HTTP Port

   ```bash
   kubectl port-forward --namespace $NAMESPACE coherence-demo-app-${NAMESPACE}-0 8080:8080
   ```  

1. Access the Application

   Use the following URL to access the application home page:

   [http://127.0.0.1:8080/application/index.html](http://127.0.0.1:8080/application/index.html)  
   
1. Scale the Application
  
   Scale the application using `kubectl`. When running the application in Kubernetes, 
   the **Add Server** and **Remove Server** options are not available. You need to use `kubectl` 
   to scale the application.

   Scale the application to two nodes:

   ```bash
   kubectl scale statefulsets coherence-demo-storage-${NAMESPACE} --namespace $NAMESPACE --replicas=2
   ```   
   
   Check the number of running pods using:   
      
   ```bash
   kubectl get pods -n $NAMESPACE
   ```      
                                          
1. View the application logs via Kibana.

1. Explore the Application

   The following features are available to demonstrate in the application:

   * Dynamically add or remove cluster members and observe the data repartition and recover automatically.
   * Create and recover snapshots from the **Persistence** menu.
   * Enable real-time price updates.
   * Enable or disable indexes for queries.
   * Add additional data, clear the cache or populate the cache from the **Tools** menu.

1. Uninstall the Coherence Charts

   ```bash
   helm delete coherence-demo-storage-${NAMESPACE} --purge
   ```        
   
   ```bash
   helm delete coherence-demo-app-${NAMESPACE} --purge
   ```     
   
1. Ensure you stop the HTTP port-forward commands using `CTRL-C`.  
                                           
## LAB 3 - ???


