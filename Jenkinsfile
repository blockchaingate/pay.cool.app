pipeline {
    agent any

    environment {
      PATH = "/Users/mustafayildiz/sdks/flutter/bin:$PATH"
    } 

    stages {
        stage('Checkout') {
            steps {
                // Checkout your source code repository
                checkout scm
            }
        }

        stage('Copy Files') {
            steps {
                // Assuming you have files to copy in the same directory as your Jenkinsfile
                script {
                    sh 'cp -r /Users/mustafayildiz/Desktop/jenkins-copyfiles/* ./android/'
                }
            }
        }

        stage('Build APK') {
            steps {
                // Run 'flutter build apk' command
                script {
                    sh 'flutter clean'
                    sh 'flutter pub get'
                    // sh 'flutter build apk'
                }
            }
        }

        stage('Slack Notification') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }   
            steps {
                script {
                    slackSend channel:  "#paycool-testing", message: "Build Started: ${env.JOB_NAME} ${env.BUILD_NUMBER}", teamDomain: "aukfa", tokenCredentialId: "slack-token"
                    // slackUploadFile channel: "#jenkins-apk", credentialId: "slack-file-token", filePath: "build/app/outputs/flutter-apk/app-release.apk", initialComment: "this is test"
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