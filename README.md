# Croc Hunter - The game!

For those that have dreamt to hunt crocs

# Usage

Basic go webserver to demonstrate example CI/CD pipeline using Kubernetes

# Deploy using JenkinsX (Kubernetes, Helm, Monocular, ChartMuseum)

Just follow the [JenkinsX](http://jenkins-x.io) installation with `--prow=true`

For example, if using GKE with cert-manager preinstalled for https certificates

    jx install --provider=gke --domain=example.com --http=false --tls-acme=true

Then fork this repo and [import it](http://jenkins-x.io/developing/import/)

    jx import --url https://github.com/GITHUB_USER/croc-hunter-jenkinsx-serverless --no-draft --pack=go

Then, any PRs against this repo will be automatically deployed to preview environments.
When they are merged they will be deployed to the `staging` environment.

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
