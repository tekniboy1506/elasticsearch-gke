#  HA Elasticsearch Cluster on Regional GKE
### Time spent on the Project: roughly 6 hours
## Tech stack used in this Solution:
  - Google Cloud Platform's GKE as the Kubernetes Cluster
  - GKE's Stateful HA Operator --> https://cloud.google.com/kubernetes-engine/docs/how-to/stateful-ha
  - Elastic's Elasticsearch Helm chart --> https://github.com/elastic/helm-charts/tree/main/elasticsearch
  - Nginx Ingress on GKE
  - Terraform and Terragrunt to provision GCP resources
## Brief explanation on the Project and Teck stack choices:
-  I chose Region GKE Cluster along with the Regional PD to give the availability across zones in a GCP region. 
-  Since the limitation of the Regional PD is that it can only replicate a disk between only 2 regions whereas the GKE Cluster uses 3, I made the choice to use a Native solution from GCP which is the Stateful HA Operator, which can help protect the Elasticsearch cluster in case there's a zone failure.
-  Last but not least, I chose the Official Elastic's Elasticsearch Helm chart because of its stability and wide range of setups and options.
## Service Diagram:
![image](https://github.com/user-attachments/assets/9cee563d-4822-44a1-8651-44c73942e4c7)

## Content:
  -  elasticsearch
      -  `ha` --> setup the HA Operator for StatefulSet 
      -  `storage-setups` --> Setup regional PD storage provider
      -  `values.yml` --> contains custom configs for Elasticsearch Cluster
      -  `ingress.yml` --> Ingress object to expose the Elasticsearch through Nginx Ingress
  -  terraform --> contains setup to bring up a Regional GKE cluster, I left this simple enough since I didn't have much time

## Steps to setup the Cluster
After the GKE cluster is up and has the Stateful HA Operator feature enabled, follow these steps to setup the Elasticsearch Cluster
  1. Install Nginx Ingress:
     -  Create a `namespace` for Nginx ingress:
       ```
          kubectl create namespace nginx-ingress && kubectl config set-context --current --namespace nginx-ingress
       ```
     -  Install Nginx Ingress using a helm chart
       ```
          helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
          helm install nginx-ingress ingress-nginx/ingress-nginx
       ```
  2. Install the Stateful HA Operator
     - Create a `namespace` for Elasticsearch:
      ```
         kubectl create namespace elasticsearch && kubectl config set-context --current --namespace elasticsearch
      ```
     - Deploy the HighAvailability Application
      ```
         kubectl apply -f elasticsearch/ha/haa.yml
      ```
  3. Enable Regional PD Storage class
     ```
        kubectl apply -f elasticsearch/storage-setups/regional-pd.yml
     ```
  4. Install Elasticsearch Cluster
     ```
        helm install es elastic/elasticsearch -f elasticsearch/values.yml

        # Install ingress (remember to change the host in the `ingress.yml` to be your exact domain)
        kubectl apply -f elasticsearch/ingress.yml
     ```
After these above steps, the Elasticsearch would be available via the Ingress's Public IP, which you can point a DNS to, there might be SSL error while trying to access the ES in case you don't use GCP Mananged Certificate or any SSL certifcate since I skipped this step.
