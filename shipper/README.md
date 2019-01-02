# Croc Hunter deployment with Shipper

Install [Shipper](https://docs.shipper-k8s.io/en/latest/start/install.html)

Create the cluster configuration

```
managementClusters:
- name: gke-CLUSTER_NAME_US
  context: gke_PROJECT_ID_us-central1-a_CLUSTER_NAME_US
applicationClusters:
- name: gke-CLUSTER_NAME_US
  region: us
  context: gke_PROJECT_ID_us-central1-a_CLUSTER_NAME_US
- name: gke-CLUSTER_NAME_EU
  region: europe
  context: gke_PROJECT_ID_europe-west4-a_CLUSTER_NAME_EU
```

Apply the cluster configuration

    shipperctl admin clusters apply -f clusters.yaml

Deploy croc-hunter

    kubectl apply -f croc-hunter.yaml

Edit the created release object to roll out

    kubectl get release.shipper.booking.com
    kubectl edit release.shipper.booking.com croc-hunter-d534b276-0

Go to the next rollout step (staging, 50/50, full on), editing `spec.targetStep` to (0,1,2)
