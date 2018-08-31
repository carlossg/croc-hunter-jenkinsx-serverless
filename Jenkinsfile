pipeline {
    agent {
        label "jenkins-go"
    }
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
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx') {
            checkout scm
            container('go') {
              sh "make VERSION=\$PREVIEW_VERSION GIT_COMMIT=\$GIT_COMMIT linux"
              sh 'export VERSION=$PREVIEW_VERSION && skaffold run -f skaffold.yaml.new'


              sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:$PREVIEW_VERSION"
            }
          }
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx/charts/preview') {
            container('go') {
              sh "make preview"
              sh "jx preview --app $APP_NAME --dir ../.."
            }
          }
        }
      }
      stage('Selenium test') {
        agent {
          kubernetes {
            label 'selenium'
            yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    some-label: some-label-value
spec:
  serviceAccountName: jenkins
  containers:
  - name: maven-chrome
    image: jenkinsxio/builder-maven:0.0.305
    command:
    - cat
    tty: true
  - name: maven-firefox
    image: jenkinsxio/builder-maven:0.0.305
    command:
    - cat
    tty: true
  - name: selenium-hub
    image: selenium/hub:3.4.0
  - name: selenium-chrome
    image: selenium/node-chrome:3.4.0
    env:
    - name: HUB_PORT_4444_TCP_ADDR
      value: localhost
    - name: HUB_PORT_4444_TCP_PORT
      value: "4444"
    - name: DISPLAY
      value: ":99.0"
    - name: SE_OPTS
      value: -port 5556
  - name: selenium-firefox
    image: selenium/node-firefox:3.4.0
    env:
    - name: HUB_PORT_4444_TCP_ADDR
      value: localhost
    - name: HUB_PORT_4444_TCP_PORT
      value: "4444"
    - name: DISPLAY
      value: ":98.0"
    - name: SE_OPTS
      value: -port 5557
"""
          }
        }
        when {
          branch 'PR-*'
        }
        steps {
          parallel(
            chrome: {
              dir('chrome') {
                git url: 'https://github.com/carlossg/croc-hunter-selenium.git'
                container('maven-chrome') {
                  sh '''
                  yum install -y jq
                  echo PR is $CHANGE_ID
                  previewUrl=$(jx get preview -o json|jq  -r ".items[].spec | select (.previewGitInfo.name==\\"$CHANGE_ID\\") | .previewGitInfo.applicationURL")
                  mvn -B clean test -Dselenium.browser=chrome -Dsurefire.rerunFailingTestsCount=1 -Dsleep=0 -Durl=$previewUrl -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn
                  '''
                }
              }
            },
            firefox: {
              dir('firefox') {
                git url: 'https://github.com/carlossg/croc-hunter-selenium.git'
                container('maven-firefox') {
                  sh '''
                  yum install -y jq
                  echo PR is $CHANGE_ID
                  previewUrl=$(jx get preview -o json|jq  -r ".items[].spec | select (.previewGitInfo.name==\\"$CHANGE_ID\\") | .previewGitInfo.applicationURL")
                  mvn -B clean test -Dselenium.browser=firefox -Dsurefire.rerunFailingTestsCount=1 -Dsleep=0 -Durl=$previewUrl -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn
                  '''
                }
              }
            }
          )
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          container('go') {
            dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx') {
              checkout scm
            }
            dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx/charts/croc-hunter-jenkinsx') {
                // ensure we're not on a detached head
                sh "git checkout master"
                // until we switch to the new kubernetes / jenkins credential implementation use git credentials store
                sh "git config --global credential.helper store"

                sh "jx step git credentials"
            }
            dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx') {
              // so we can retrieve the version in later steps
              sh "echo \$(jx-release-version) > VERSION"
            }
            dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx/charts/croc-hunter-jenkinsx') {
              sh "make tag"
            }
            dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx') {
              container('go') {
                sh "make VERSION=`cat VERSION` GIT_COMMIT=\$GIT_COMMIT build"
                sh "export VERSION=`cat VERSION` && skaffold build -f skaffold.yaml.new"
                sh "jx step post build --image $DOCKER_REGISTRY/$ORG/$APP_NAME:\$(cat VERSION)"
              }
            }
          }
        }
      }
      stage('Promote to Environments') {
        when {
          branch 'master'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/carlossg/croc-hunter-jenkinsx/charts/croc-hunter-jenkinsx') {
            container('go') {
              sh 'jx step changelog --version v\$(cat ../../VERSION)'

              // release the helm chart
              sh 'jx step helm release'

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
