# HOL5314 - Coherence Operator Hands-On Lab

# Initial "Once-Only" Setup

After initial clone of the repository, carry out the following to setup your environment for the lab.

1. Setup your environment

   You will be asked for your assigned user number which will set the NAMESPACE environment variable
   which is used in each of the `helm` and `kubectl` commands.

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
   
   Wait until all are in a Running State and all pods are shown as `1/1` or `2/2`.
   
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

   > **Note:** If you get a `broken pipe` stop the port-forward via CTRL-C and restart it.
 
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

   Then issue the following to port-forward the default Coherence*Extend port. (Normally you would
   use a load balancer for this, but we are just using port-forward for this demonstration)
   
   ```bash
   kubectl port-forward -n $NAMESPACE storage-${NAMESPACE}-coherence-0 20000:20000
   ```

4. Connect via CohQL and run the following commands:

   In your first terminal, change to the following directory:
   
   ```bash
   cd ~/coherence-operator/docs/samples/coherence-deployments/extend/default
   ```
   
   ```bash
   mvn exec:java -Dcoherence.version=12.2.1-3-3
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
   
   Type `quit` to exit CohQL and change back to the base directory:
   
   ```bash
   cd ~/HOL5314
   ```
    
1. Uninstall the Coherence helm release

   Before you continue to the next lab, use the following commands to delete the 
   chart installed in this sample:

   ```bash
   helm delete storage-${NAMESPACE} --purge
   ```                           
   
   Use the following command to ensure all the pods have terminated.
   
   ```bash
   kubectl get pods -n $NAMESPACE
   ```    
   
1. Ensure you stop the port-forward for Coherence*Extend command using `CTRL-C`.

   > **Note:** Leave the port-forward for Kibana running as we will use this in the next Lab.   
  
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

   > Note: for the purposes of this Lab, the Docker image has already been created and has been pushed as 
   > `tmiddlet/coherence-demo-sidecar:3.0.0-SNAPSHOT`.
   > If you wish to build it, please follow the instructions in step 3 [here](https://github.com/coherence-community/coherence-demo#run-the-application-on-kubernetes-coherence-12213x).

   Use the following Docker command to see the sidecar image on your machine.
   
   ```bash
   docker images
   ```
      
1. Install the Coherence Cluster Tier

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
      --set logCaptureEnabled=true \
      --set userArtifacts.image=tmiddlet/coherence-demo-sidecar:3.0.0-SNAPSHOT \
      --set coherence.image=tmiddlet/coherence:12.2.1.3.3 \
      coherence/coherence
   ```
 
   Use `helm ls` and `kubectl get pods -n $NAMESPACE` and wait for the Coherence pod to be ready `2/2`.  
   
1. Install the Application Tier

   Install the application tier using the following command:
   
   > **Note**: We set the application tier to storage-disabled as well as well as set the Well Known Address (WKA)
   > using `--set store.wka=coherence-demo-storage-${NAMESPACE}-headless` to point to the DNS address 
   > `coherence-demo-storage-${NAMESPACE}-headless`
   > which points to all the cluster members to ensure the application tier joins the cluster.      

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
      --set logCaptureEnabled=true \
      --set userArtifacts.image=tmiddlet/coherence-demo-sidecar:3.0.0-SNAPSHOT \
      --set coherence.image=tmiddlet/coherence:12.2.1.3.3 \
      coherence/coherence
   ```  

1. Port Forward the HTTP port of the demo application

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

   Scale the application to three nodes:

   ```bash
   kubectl scale statefulsets coherence-demo-storage-${NAMESPACE} --namespace $NAMESPACE --replicas=3
   ```   
   
   Check the number of running pods using:   
      
   ```bash
   kubectl get pods -n $NAMESPACE
   ```                              
   
   You should also see the UI update to reflect the number of nodes.
                                          
1. View the application logs via Kibana.

   Open Kibana and click on the `Coherence Cluster - All Messages` dashboard.
   
   Also explore the other dashboards.

1. Explore the Application

   The following features are available to demonstrate in the application:

   * Dynamically add or remove cluster members and observe the data repartition and recover automatically.
   * Create and recover snapshots from the **Persistence** menu.
   * Enable real-time price updates.
   * Enable or disable indexes for queries.
   * Add additional data, clear the cache or populate the cache from the **Tools** menu.

1. Uninstall the Coherence Charts

   ```bash
   helm delete coherence-demo-storage-${NAMESPACE} coherence-demo-app-${NAMESPACE} --purge
   ```        
   
1. Ensure you stop the HTTP port-forward commands using `CTRL-C`.  
                                           
## LAB 3 - Issue a Safe Rolling Upgrade

The safe rolling upgrade feature allows you to instruct Kubernetes, through the operator, 
to replace the currently installed version of your application classes with a different one. Kubernetes does not verify whether the classes are new or old. It checks whether the image can be pulled by the cluster and image has a docker tag. The operator also ensures that the replacement is done without data loss or interruption of service.

This sample initially deploys version 1.0.0 of the sidecar Docker image and then does a rolling upgrade to
version 2.0.0 of the sidecar image which introduces a server side Interceptor to modify 
data to ensure it is stored as uppercase.

As before, the Docker images, version 1.0.0 and version 2.0.0 Docker images already been created and pushed to:

   * `tmiddlet/rolling-upgrade-sample:1.0.0`

   * `tmiddlet/rolling-upgrade-sample:2.0.0`

`tmiddlet/rolling-upgrade-sample:1.0.0` is the initial image installed in the chart.

The version 2.0.0 cache config and interceptor can be found below:

* [Version 2.0.0 cache config](https://github.com/oracle/coherence-operator/blob/gh-pages/docs/samples/operator/rolling-upgrade/src/main/resources/conf/v2/storage-cache-config.xml)
* [Version 2.0.0 interceptor](https://github.com/oracle/coherence-operator/blob/gh-pages/docs/samples/operator/rolling-upgrade/src/main/java/com/oracle/coherence/examples/UppercaseInterceptor.java)

1. In a terminal where you have run `. ./setenv.sh`, change to the samples directory.

   ```bash
   cd ~/coherence-operator/docs/samples/operator/rolling-upgrade/
   ```  
   
1. Install the Coherence cluster with tmiddlet/rolling-upgrade-sample:1.0.0 image as a sidecar:

   ```bash
   helm install \
      --namespace $NAMESPACE \
      --name storage-${NAMESPACE} \
      --set clusterSize=3 \
      --set cluster=rolling-upgrade-cluster \
      --set store.cacheConfig=storage-cache-config.xml \
      --set logCaptureEnabled=true \
      --set coherence.image=tmiddlet/coherence:12.2.1.3.3 \
      --set userArtifacts.image=tmiddlet/rolling-upgrade-sample:1.0.0 \
      coherence/coherence
   ```

   After the installation completes, list the pods:

   ```bash
   $ kubectl get pods -n $NAMESPACE
   ```

   All the three storage-${NAMESPACE}-coherence-0/1/2 pods should be in running state - `2/2`.
                                                    
1. Port forward the proxy port on the `storage-${NAMESPACE}-coherence-0` pod:

   ```bash
   kubectl port-forward -n $NAMESPACE storage-${NAMESPACE}-coherence-0 20000:20000
   ```

1. Connect via CohQL commands and execute the following command in the terminal you changed directory.

   ```bash
   $ mvn exec:java -Dcoherence.version=12.2.1-3-3
   ```

   Run the following CohQL commands to insert data into the cluster:

   ```sql
   insert into 'test' key('key-1') value('value-1');
   insert into 'test' key('key-2') value('value-2');

   select key(), value() from 'test';
   Results
   ["key-1", "value-1"]
   ["key-2", "value-2"]
   ```                   
   
   Quit CohQL.
 
1. Upgrade the helm release to use the `tmiddlet/rolling-upgrade-sample:2.0.0` image.

   Use the following arguments to upgrade to version 2.0.0 of the image:

   * `--reuse-values` - specifies to reuse all previous values associated with the release

   * `--set userArtifacts.image=tmiddlet/rolling-upgrade-sample:2.0.0` - the new artifact version

   ```bash
   helm upgrade storage-${NAMESPACE} coherence/coherence \
      --namespace sample-coherence-ns \
      --reuse-values \
      --set userArtifacts.image=tmiddlet/rolling-upgrade-sample:2.0.0
   ```              
   
1. Check the status of the upgrade.

   Use the following command to check the status of the rolling upgrade of all pods.

   > **Note**: The command below will not return until upgrade of all pods is complete.

   ```bash
   kubectl rollout status sts/storage-${NAMESPACE}-coherence --namespace $NAMESPACE
   Waiting for 1 pods to be ready...
   Waiting for 1 pods to be ready...
   waiting for statefulset rolling update to complete 1 pods at revision storage-...coherence...
   Waiting for 1 pods to be ready...
   Waiting for 1 pods to be ready...
   waiting for statefulset rolling update to complete 2 pods at revision storage-...coherence...
   Waiting for 1 pods to be ready...
   Waiting for 1 pods to be ready...
   statefulset rolling update complete 3 pods at revision storage-...coherence...
   ```

1. Verify the data through CohQL commands.

   When the upgrade is running, you can re-run CohQL and execute the following commands in the CohQL session:

   ```sql
   select key(), value() from 'test';
   ```

   You can note that the data always remains the same.

   > **Note**: Your port-forward fails when the storage-$NAMESPACE-coherence-0` pod restarts. 
   > You have to restart it.

   In an environment where you have configured a load balancer, then the Coherence*Extend 
   session automatically reconnects when it detects a disconnect.

1. Add new data to confirm the interceptor is now active.  

   ```sql
   insert into 'test' key('key-3') value('value-3');

   select key(), value() from 'test';
   Results
   ["key-1", "value-1"]
   ["key-3", "VALUE-3"]
   ["key-2", "value-2"]
   ```

   You can note that the value for `key-3` has been converted to uppercase which shows that the server-side interceptor is now active.

1. Verify that the 2.0.0 image on one of the pods.

   Use the following command to verify that the 2.0.0 image is active:

   ```bash
   kubectl describe pod storage-${NAMESPACE}-coherence-0  -n $NAMESPACE| grep rolling-upgrade
   ```
   ```console
   Image:         rolling-upgrade-sample:2.0.0
   Normal  Pulled                 4m59s  kubelet, docker-for-desktop  Container image "rolling-upgrade-sample:2.0.0" already present on machine
   ```

   The output shows that the version 2.0.0 image is now present.  
  
1. (Optionally) you could issue the helm upgrade to downgrade the image back to 1.0.0 version.

1. Uninstall the Coherence Charts

   ```bash
   helm delete storage-${NAMESPACE} --purge
   ```        
   
1. Ensure you stop the port-forward command using `CTRL-C`.  
                                           


