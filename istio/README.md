# Croc Hunter Canary deployment with Istio

Install [Istio](https://istio.io/docs/setup/kubernetes/quick-start/)

## Access from the Internet using Istio ingress gateway

Find the [ingress gateway ip address](https://istio.io/docs/tasks/traffic-management/ingress/#determining-the-ingress-ip-and-ports) and configure a wildcard DNS for it.

For example map `*.example.com` to

    kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

Create the `Gateway` that will route all external traffic through the ingress gateway

    kubectl create -f gateway.yaml

Create the `VirtualService` that will route to the staging and production deployments (change the host to your DNS)

    kubectl create -f virtualservice.yaml

## Access from other services in the cluster through Istio

If you need to access the service through Istio from inside the cluster (not needed for the demo)

Enable Istio in the jx-staging and jx-production namespaces

    kubectl patch ns jx-carlossg-croc-hunter-jenkinsx-serverless-pr-35 --type=json -p='[{"op": "add", "path": "/metadata/labels/istio-injection", "value": "enabled"}]'
    kubectl patch ns jx-production --type=json -p='[{"op": "add", "path": "/metadata/labels/istio-injection", "value": "enabled"}]'

Optional: Create a `ServiceEntry` to allow traffic to the Google metadata api to display the region

    kubectl create -f google-api.yaml
