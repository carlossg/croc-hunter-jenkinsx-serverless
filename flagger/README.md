# Canary Deployments with Flagger

## Installation

Install Istio, Prometheus and [Flagger](https://docs.flagger.app)

    jx create addon istio
    jx create addon prometheus
    jx create addon flagger

Istio is enabled in the `jx-production` namespace for metrics gathering.

Get the ip of the Istio ingress and point your wildcard domain to it

    kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}'

## Application Configuration

Add the [canary object](../charts/croc-hunter-jenkinsx/templates/canary.yaml) that will add our deployment to Flagger. Add it to the Helm chart so it is created when promoting to `jx-production` namespace.

Update the `values.yaml` section `canary.service.hosts` with the hostname for your aplication.

Optional: Create a `ServiceEntry` to allow traffic to the Google metadata api to display the region

    kubectl create -f ../istio/google-api.yaml

## Grafana Dashboard

    kubectl --namespace istio-system port-forward deploy/flagger-grafana 3000

Access it at [http://localhost:3000](http://localhost:3000) using admin/admin
Go to the `canary-analysis` dashboard and select

* namespace: `jx-production`
* primary: `jx-production-croc-hunter-jenkinsx-primary`
* canary: `jx-production-croc-hunter-jenkinsx`

to see the roll out metrics.

## Prometheus Metrics

    kubectl --namespace istio-system port-forward deploy/prometheus 9090

## Caveats

If a rollback happens automatically because the metrics fail the GitOps repository for the production environment becomes out of date, still pointing to the new version instead of the old one.

# Croc Hunter Demo

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
