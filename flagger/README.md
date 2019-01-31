# Croc Hunter deployment with Flagger

Install [Flagger](https://docs.flagger.app/install/install-flagger)

Enable Istio in the `jx-staging` and `jx-production` namespaces for metrics gathering

    kubectl label namespace jx-staging istio-injection=enabled
    kubectl label namespace jx-production istio-injection=enabled


Create the canary object that will add our deployment to Flagger. This is already created by the Helm chart when promoting to `jx-production` namespace.

    kubectl create -f croc-hunter-canary.yaml

Optional: Create a `ServiceEntry` to allow traffic to the Google metadata api to display the region

    kubectl create -f ../istio/google-api.yaml

# Grafana dashboard

    kubectl --namespace istio-system port-forward deploy/flagger-grafana 3000

Access it at [http://localhost:3000](http://localhost:3000) using admin/admin
Go to the `canary-analysis` dashboard and select

* namespace: `jx-production`
* primary: `jx-production-croc-hunter-jenkinsx-primary`
* canary: `jx-production-croc-hunter-jenkinsx`
