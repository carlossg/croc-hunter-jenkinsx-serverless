# Croc Hunter deployment with Flagger

Install [Flagger](https://docs.flagger.app/install/install-flagger)

Enable Istio in the jx-staging and jx-production namespaces

    kubectl patch ns jx-staging --type=json -p='[{"op": "add", "path": "/metadata/labels/istio-injection", "value": "enabled"}]'
    kubectl patch ns jx-production --type=json -p='[{"op": "add", "path": "/metadata/labels/istio-injection", "value": "enabled"}]'


Create the canary object that will add our deployment to Flagger

    kubectl create -f croc-hunter-canary.yaml
