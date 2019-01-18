# Croc Hunter Canary deployment with Istio

Install [Istio](https://istio.io/docs/setup/kubernetes/quick-start/)

Enable Istio in the jx-staging and jx-production namespaces

    kubectl patch ns jx-carlossg-croc-hunter-jenkinsx-serverless-pr-35 --type=json -p='[{"op": "add", "path": "/metadata/labels/istio-injection", "value": "enabled"}]'
    kubectl patch ns jx-production --type=json -p='[{"op": "add", "path": "/metadata/labels/istio-injection", "value": "enabled"}]'


Create the `Gateway` that will route all external traffic through the ingress gateway

    kubectl create -f gateway.yaml

Optional: Create a `ServiceEntry` to allow traffic to the Google metadata api to display the region

    kubectl create -f google-api.yaml

Create the `VirtualService` that will route to the staging and production deployments (change the host to your DNS)

    kubectl create -f virtualservice.yaml
