pipeline {
    agent any

    environment {
      PATH = "/Users/mustafayildiz/sdks/flutter/bin:$PATH"
      COMMIT_MESSAGE = '' // Initialize the variable
      branchName = ''
    } 

    stages {
        stage('Checkout') {
            steps {
                // Checkout your source code repository
                checkout scm
                  script {

                          COMMIT_MESSAGE = sh(
                        script: 'git log -1 --pretty=%B',
                        returnStdout: true
                    ).trim()
                    

                    branchName = sh(script: 'git rev-parse --abbrev-ref HEAD', returnStdout: true).trim()
                    }
            }
        }

        stage('Copy Files') {
            steps {
                // Assuming you have files to copy in the same directory as your Jenkinsfile
                script {
                    sh 'cp -r /Users/mustafayildiz/Desktop/pay.cool-jenkins-copyfiles/* ./android/'
                }
            }
        }

        stage('Build APK') {
            steps {
                // Run 'flutter build apk' command
                script {
                    sh 'flutter clean'
                    sh 'flutter pub get'
                    sh 'flutter build apk'
                }
            }
        }

        stage('Slack Notification') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }   
            steps {
                script {
                    slackSend channel:  "#paycool-testing",
                     message: "Build Started!\n*Project: Pay.Cool \n*Branch:* ${branchName}",
                      teamDomain: "aukfa",
                       tokenCredentialId: "slack-token"
                    slackUploadFile channel: "#paycool-testing", credentialId: "slack-file-token", filePath: "build/app/outputs/flutter-apk/app-release.apk", initialComment: ${COMMIT_MESSAGE}
                }
            }
        }

    }

     post {
        always {
            echo 'This will always run'
        }
                success {
            echo 'This will success run'
        }
        failure {
            echo 'This will failure run'
        }
    }

}