# Croc Hunter deployment with Flagger

Install [Flagger](https://docs.flagger.app/install/install-flagger)

Enable Istio in the `jx-staging` and `jx-production` namespaces for metrics gathering

    kubectl label namespace jx-staging istio-injection=enabled
    kubectl label namespace jx-production istio-injection=enabled


Create the canary object that will add our deployment to Flagger

    kubectl create -f croc-hunter-canary.yaml

Optional: Create a `ServiceEntry` to allow traffic to the Google metadata api to display the region

    kubectl create -f ../istio/google-api.yaml

# Grafana dashboard

    kubectl --namespace istio-system port-forward deploy/flagger-grafana 3000
    kubectl --namespace istio-system port-forward deploy/prometheus 9090

[http://localhost:3000](http://localhost:3000)
