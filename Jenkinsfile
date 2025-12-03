pipeline {
    agent any

    environment {
        AWS_CREDS   = "aws-jenkins-creds"
        SECRET_NAME = "GITHUB_TOKEN"
        REGION      = "ap-south-1"
        REPO_URL    = "github.com/Ravichandu-git/ravitest.git"
    }

    stages {

        /* ========== FETCH GITHUB TOKEN ========== */
        stage('Fetch GitHub Secret') {
            steps {
                script {
                    def gitJson = sh(
                        script: """
                        aws secretsmanager get-secret-value \
                        --secret-id ${SECRET_NAME} \
                        --region ${REGION} \
                        --query SecretString --output text
                        """,
                        returnStdout: true
                    ).trim()

                    def gitCred = readJSON text: gitJson
                    env.GITHUB_TOKEN = gitCred.GITHUB_TOKEN    // FIXED
                }
            }
        }

        /* ========== FETCH AWS CREDENTIALS ========== */
        stage('Fetch AWS Credentials') {
            steps {
                script {
                    def awsJson = sh(
                        script: """
                        aws secretsmanager get-secret-value \
                        --secret-id ${AWS_CREDS} \
                        --region ${REGION} \
                        --query SecretString --output text
                        """,
                        returnStdout: true
                    ).trim()

                    def awsCred = readJSON text: awsJson
                    env.AWS_ACCESS_KEY_ID     = awsCred.AWS_ACCESS_KEY_ID
                    env.AWS_SECRET_ACCESS_KEY = awsCred.AWS_SECRET_ACCESS_KEY
                }
            }
        }

        /* ========== CHECKOUT TERRAFORM CODE ========== */
        stage('Checkout Code') {
            steps {
                git(
                    url: "https://${env.GITHUB_TOKEN}@${REPO_URL}",
                    branch: "main"
                )
            }
        }

        /* ========== TERRAFORM INIT ========== */
        stage('Terraform Init') {
            steps {
                sh """
                export AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
                export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}

                terraform init
                """
            }
        }

        /* ========== TERRAFORM PLAN ========== */
        stage('Terraform Plan') {
            steps {
                sh """
                terraform plan -out=tfplan
                """
            }
        }

        /* ========== APPROVAL ========== */
        stage('Approve Apply') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: "Approve Terraform Apply?"
                }
            }
        }

        /* ========== TERRAFORM APPLY ========== */
        stage('Terraform Apply') {
            steps {
                sh """
                terraform apply -auto-approve tfplan
                """
            }
        }

         /* ====== DESTROY SECTION ====== */

        stage('Destroy Approval') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    input message: "Are you SURE you want to DESTROY ALL INFRA?"
                }
            }
        }

        stage('Terraform Destroy') {
            steps {
                sh """
                terraform destroy -auto-approve
                """
            }
        }
    }
}
