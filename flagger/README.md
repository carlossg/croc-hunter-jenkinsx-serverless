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

to see the roll out metrics.

# Prometheus Metrics

    kubectl --namespace istio-system port-forward deploy/prometheus 9090

# Demo

Promote to production

    jx promote croc-hunter-jenkinsx --env production --version 0.0.xxx

Tail the flagger logs

    kail -d flagger --since=5m

Generate traffic to show the version served

    while true; do
        out=$(curl -sSL -w "%{http_code}" http://croc-hunter.istio.us.g.csanchez.org/)
        date="$(date +%R:%S)"; echo -n $date
        echo -n "$out" | tail -n 1 ; echo -n "-" ; echo "$out" | grep Release | grep -o '\d*\.\d*\.\d*'
    done

Generate delays and errors to show automatic rollbacks

    watch curl -sSL http://croc-hunter.istio.us.g.csanchez.org/delay?wait=5
    watch curl -sSL http://croc-hunter.istio.us.g.csanchez.org/status?code=500
