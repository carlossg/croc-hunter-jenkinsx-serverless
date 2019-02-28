# Croc Hunter - The game!

For those that have dreamt to hunt crocs

# Usage

Basic go webserver to demonstrate example CI/CD pipeline using Kubernetes

# Deploy using JenkinsX (Kubernetes, Helm, Monocular, ChartMuseum)

Just follow the [JenkinsX](http://jenkins-x.io) installation with `--prow=true`

For example, if using GKE with cert-manager preinstalled for https certificates

    jx install --provider=gke --domain=eu.g.csanchez.org --prow
    jx upgrade ingress

Then fork this repo and [import it](http://jenkins-x.io/developing/import/)

    jx import --url https://github.com/GITHUB_USER/croc-hunter-jenkinsx-serverless --no-draft --pack=go

Then, any PRs against this repo will be automatically deployed to preview environments.
When they are merged they will be deployed to the `staging` environment.

To tail all the build logs

    kail -l build.knative.dev/buildName --since=5m

Or in [GKE StackDriver logs](https://console.cloud.google.com/logs/viewer?authuser=1&advancedFilter=resource.type%3D%22container%22%0Aresource.labels.cluster_name%3D%22samurainarrow%22%0Aresource.labels.container_name%3Dbuild-step-jenkins)

```
resource.type="container"
resource.labels.cluster_name="samurainarrow"
resource.labels.container_name="build-step-jenkins"
```

To [promote from staging to production](http://jenkins-x.io/developing/promote/) just run

    jx promote croc-hunter-jenkinsx --version 0.0.1 --env production

Then delete the PR environments

    jx delete env

# Acknowledgements

Original work by [Lachlan Evenson](https://github.com/lachie83/croc-hunter)
Continuation of the awesome work by everett-toews.
* https://gist.github.com/everett-toews/ed56adcfd525ce65b178d2e5a5eb06aa

## Watch Their Demo

https://www.youtube.com/watch?v=eMOzF_xAm7w
