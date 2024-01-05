pipeline {
    agent any

    environment {
        PATH = "/Users/mustafayildiz/sdks/flutter/bin:$PATH"
        COMMIT_MESSAGE = '' // Initialize the variable
        CHECKTOUPDATE = 'PushtoTest'
    } 

    stages {
        stage('Checkout') {
            steps {
                // Checkout your source code repository
                checkout scm
                script {
                    COMMIT_MESSAGE = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                }
            }
        }

        stage('Copy Files') {
            steps {
                script {
                    if (COMMIT_MESSAGE.contains(CHECKTOUPDATE)) {
                        sh 'cp -r /Users/mustafayildiz/Desktop/pay.cool-jenkins-copyfiles/* ./android/'
                    } else {
                        echo 'No need to copy files'
                    }
                }
            }
        }

        stage('Build APK') {
            steps {
                script {
                    if (COMMIT_MESSAGE.contains(CHECKTOUPDATE)) {
                        sh 'flutter clean'
                        sh 'flutter pub get'
                        sh 'flutter build apk'
                    } else {
                        echo 'No need to build APK'
                    }
                }
            }
        }

        // stage('Send to TestFlight') {
        //     steps {
        //         script {
        //             if (COMMIT_MESSAGE.contains(CHECKTOUPDATE)) {
        //                 sh "cd ios"
        //                 sh "fastlane beta"
        //             } else {
        //                 echo 'No need to send to TestFlight'
        //             }
        //         }
        //     }
        // }

        stage('Slack Notification') {
            when {
                expression { currentBuild.resultIsBetterOrEqualTo('SUCCESS') }
            }   
            steps {
                script {
                    if (COMMIT_MESSAGE.contains(CHECKTOUPDATE)) {
                        def modifiedText = COMMIT_MESSAGE.replace(CHECKTOUPDATE, "")

                        slackUploadFile(
                            channel: "#paycool-testing",
                            credentialId: "slack-file-token",
                            filePath: "build/app/outputs/flutter-apk/app-release.apk",
                            initialComment: "Build Completed for Testing!\nTest the Pay.Cool application on the following branch: new-design\nCommit Message: ${modifiedText}"
                        )
                    } else {
                        echo 'No need to send Slack notification'
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'This will always run'
        }
        success {
            echo 'This will run on success'
        }
        failure {
            echo 'This will run on failure'
        }
    }
}
