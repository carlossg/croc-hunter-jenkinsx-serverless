pipeline {
    agent {
        label "jenkins-nodejs"
    }
    environment {
      ORG               = 'jenkinsx'
      APP_NAME          = 'croc-hunter-jenkinsx'
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
          container('nodejs') {
            sh "npm install"
            sh "npm test"

            sh 'export VERSION=$PREVIEW_VERSION && skaffold run -f skaffold.yaml'
          }

          dir ('./charts/preview') {
           container('nodejs') {
             sh "make preview"
             sh "jx preview --app $APP_NAME --dir ../.."
           }
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          container('nodejs') {
            // ensure we're not on a detached head
            sh "git checkout master"
            sh "git config --global credential.helper store"
            sh "jx step validate --min-jx-version 1.1.73"
            sh "jx step git credentials"
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }
          dir ('./charts/croc-hunter-jenkinsx') {
            container('nodejs') {
              sh "make tag"
            }
          }
          container('nodejs') {
            sh "npm install"
            sh "npm test"

            sh 'export VERSION=`cat VERSION` && skaffold run -f skaffold.yaml'
          }
        }
      }
      stage('Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('./charts/croc-hunter-jenkinsx') {
            container('nodejs') {
              sh 'jx step changelog --version v\$(cat ../../VERSION)'

              // release the helm chart
              sh 'make release'

              // promote through all 'Auto' promotion Environments
              sh 'jx promote -b --all-auto --timeout 1h --version \$(cat ../../VERSION)'
            }
          }
        }
      }
    }
    post {
        always {
            cleanWs()
        }
    }
  }
