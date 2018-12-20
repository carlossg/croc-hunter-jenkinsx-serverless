pipeline {
    agent any
    environment {
      ORG               = 'carlossg'
      APP_NAME          = 'croc-hunter-jenkinsx'
      GIT_PROVIDER      = 'github.com'
      CHARTMUSEUM_CREDS = credentials('jenkins-x-chartmuseum')
    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless') {
            checkout scm
            sh "make VERSION=\$PREVIEW_VERSION GIT_COMMIT=\$PULL_PULL_SHA linux"
            sh 'export VERSION=$PREVIEW_VERSION && skaffold build -f skaffold.yaml.new'

            sh "jx step validate --min-jx-version 1.2.36"
            sh "jx step post build --image \$DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
          }
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless/charts/preview') {
            sh "make preview"
            sh "jx preview --app $APP_NAME --dir ../.."
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless') {
            git 'https://github.com/carlossg/croc-hunter-jenkinsx-serverless.git'
          }
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless/charts/croc-hunter-jenkinsx') {
            // until we switch to the new kubernetes / jenkins credential implementation use git credentials store
            sh "git config --global credential.helper store"
            sh "jx step validate --min-jx-version 1.1.73"
            sh "jx step git credentials"
          }
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless') {
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless/charts/croc-hunter-jenkinsx') {
            sh "make tag"
          }
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless') {
            sh "make VERSION=`cat VERSION` GIT_COMMIT=\$PULL_BASE_SHA build"
            sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml.new"
            sh "jx step validate --min-jx-version 1.2.36"
            sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
          }
        }
      }
      stage('Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx-serverless/charts/croc-hunter-jenkinsx') {
            sh 'jx step changelog --version v\$(cat ../../VERSION) --generate-yaml=false'

            // release the helm chart
            sh 'make release'

            // promote through all 'Auto' promotion Environments
            sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION) --no-wait'
          }
        }
      }
    }
  }
