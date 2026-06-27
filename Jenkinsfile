// // =====================================================
// // Jenkinsfile
// // Cloud-Native E-Commerce Order Tracking Platform
// //
// // Current Pipeline Flow:
// //
// // 1. Unit Testing
// // 2. SonarCloud Scan
// // 3. Docker Build
// // 4. Trivy Security Scan
// // 5. Terraform Apply (ECR + EKS app infra)
// // 6. Push to ECR
// // 7. Deploy to EKS
// //
// // If any stage fails, Jenkins stops the pipeline.
// // =====================================================

// pipeline {

//     agent any

//     stages {

//         // =====================================================
//         // Stage 1: Unit Testing
//         // =====================================================
//         stage('Unit Testing') {
//             steps {
//                 dir('app/backend') {
//                     sh '''
//                         python3 -m venv venv
//                         . venv/bin/activate
//                         pip install -r requirements.txt
//                         pip install pytest pytest-cov

//                         pytest --cov=. --cov-report=xml test_app.py -v
//                     '''
//                 }
//             }
//         }

//         // =====================================================
//         // Stage 2: SonarCloud Scan
//         // =====================================================
//         stage('Sonar Scan') {
//             steps {
//                 script {
//                     def scannerHome = tool 'sonar-scanner'
//                     withSonarQubeEnv('SonarCloud') {
//                         sh """
//                             ${scannerHome}/bin/sonar-scanner
//                         """
//                     }
//                 }
//             }
//         }

//         // =====================================================
//         // Stage 3: Docker Build
//         // =====================================================
//         stage('Docker Build') {
//             steps {
//                 sh """
//                     docker build -t order-tracking-app:${BUILD_NUMBER} .
//                     docker tag order-tracking-app:${BUILD_NUMBER} order-tracking-app:latest
//                 """
//             }
//         }

//         // =====================================================
//         // Stage 4: Trivy Security Scan
//         // =====================================================
//         stage('Trivy Scan') {
//             steps {
//                 sh """
//                     trivy image --severity CRITICAL,HIGH --exit-code 0 order-tracking-app:${BUILD_NUMBER}
//                 """
//             }
//         }

//         // =====================================================
//         // Stage 5: Terraform Apply (ECR + EKS app infra)
//         // =====================================================
//         stage("Terraform Apply - ECR") {
//             steps {
//                 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
//                     dir("terraform-app") {
//                         sh """
//                             docker run --rm \\
//                                 -v \$(pwd):/workspace \\
//                                 -w /workspace \\
//                                 -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
//                                 -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
//                                 -e AWS_DEFAULT_REGION=us-east-1 \\
//                                 hashicorp/terraform:latest init
//                             docker run --rm \\
//                                 -v \$(pwd):/workspace \\
//                                 -w /workspace \\
//                                 -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
//                                 -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
//                                 -e AWS_DEFAULT_REGION=us-east-1 \\
//                                 hashicorp/terraform:latest apply -auto-approve
//                         """
//                     }
//                 }
//             }
//         }

//         // =====================================================
//         // Stage 6: Push to ECR
//         // =====================================================
//         stage("Push to ECR") {
//             steps {
//                 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
//                     sh """
//                         docker run --rm \\
//                             -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
//                             -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
//                             -e AWS_DEFAULT_REGION=us-east-1 \\
//                             amazon/aws-cli ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 227655494308.dkr.ecr.us-east-1.amazonaws.com
//                         docker tag order-tracking-app:${BUILD_NUMBER} 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
//                         docker push 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
//                     """
//                 }
//             }
//         }

//         // =====================================================
//         // Stage 7: Deploy to EKS
//         // =====================================================
//         // Updates kubeconfig to point at the EKS cluster, then
//         // applies the deployment + service manifests, substituting
//         // the placeholder image with the real ECR image just pushed.
//         // Uses a kubectl Docker image since kubectl isn't installed
//         // directly on the Jenkins EC2.
//         // =====================================================
//         stage("Deploy to EKS") {
//             steps {
//                 withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
//                     sh """
//                         sed 's|IMAGE_PLACEHOLDER|227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}|' kubernetes/deployment.yaml > kubernetes/deployment-final.yaml

//                         docker run --rm \\
//                             -v \$(pwd)/kubernetes:/manifests \\
//                             -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
//                             -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
//                             -e AWS_DEFAULT_REGION=us-east-1 \\
//                             --entrypoint /bin/sh \\
//                             amazon/aws-cli -c "
//                                 yum install -y unzip curl >/dev/null 2>&1 || true
//                                 curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
//                                 chmod +x kubectl
//                                 aws eks update-kubeconfig --region us-east-1 --name order-tracking-eks
//                                 ./kubectl apply -f /manifests/deployment-final.yaml
//                                 ./kubectl apply -f /manifests/service.yaml
//                             "
//                     """
//                 }
//             }
//         }

//     }

//     // =====================================================
//     // Post Actions
//     // =====================================================
//     post {
//         always {
//             echo 'Pipeline finished. Check above for results.'
//         }
//         success {
//             echo 'Pipeline completed successfully.'
//         }
//         failure {
//             echo 'Pipeline failed. Check logs.'
//         }
//     }
// }
pipeline {

    // =====================================================
    // Jenkins agent (runs on any available executor)
    // =====================================================
    agent any

    stages {

        // =====================================================
        // 1. UNIT TESTING STAGE
        // Runs Python unit tests with coverage reporting
        // =====================================================
        stage('Unit Testing') {
            steps {
                dir('app/backend') {
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate

                        # Install dependencies
                        pip install -r requirements.txt
                        pip install pytest pytest-cov

                        # Run unit tests with coverage
                        pytest --cov=. --cov-report=xml test_app.py -v
                    '''
                }
            }
        }

        // =====================================================
        // 2. SONARQUBE / SONARCLOUD ANALYSIS
        // Static code quality and security analysis
        // =====================================================
        stage('Sonar Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'

                    withSonarQubeEnv('SonarCloud') {
                        sh """
                            ${scannerHome}/bin/sonar-scanner
                        """
                    }
                }
            }
        }

        // =====================================================
        // 3. DOCKER IMAGE BUILD
        // Builds and tags Docker image locally
        // =====================================================
        stage('Docker Build') {
            steps {
                sh """
                    docker build -t order-tracking-app:${BUILD_NUMBER} .

                    # Also tag latest for convenience
                    docker tag order-tracking-app:${BUILD_NUMBER} order-tracking-app:latest
                """
            }
        }

        // =====================================================
        // 4. TRIVY SECURITY SCAN
        // Scans Docker image for vulnerabilities (HIGH/CRITICAL)
        // =====================================================
        stage('Trivy Scan') {
            steps {
                sh """
                    trivy image --severity CRITICAL,HIGH --exit-code 0 order-tracking-app:${BUILD_NUMBER}
                """
            }
        }

        // =====================================================
        // 5. TERRAFORM INFRASTRUCTURE DEPLOYMENT
        // Creates/updates AWS ECR and EKS infrastructure
        // =====================================================
        stage("Terraform Apply - ECR") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    dir("terraform-app") {

                        // Initialize Terraform
                        sh """
                            docker run --rm \
                                -v \$(pwd):/workspace \
                                -w /workspace \
                                -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \
                                -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \
                                -e AWS_DEFAULT_REGION=us-east-1 \
                                hashicorp/terraform:latest init
                        """

                        // Apply Terraform configuration
                        sh """
                            docker run --rm \
                                -v \$(pwd):/workspace \
                                -w /workspace \
                                -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \
                                -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \
                                -e AWS_DEFAULT_REGION=us-east-1 \
                                hashicorp/terraform:latest apply -auto-approve
                        """
                    }
                }
            }
        }

        // =====================================================
        // 6. PUSH DOCKER IMAGE TO AWS ECR
        // Authenticates and pushes image to container registry
        // =====================================================
        stage("Push to ECR") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    sh """
                        # Login to AWS ECR
                        docker run --rm \
                            -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \
                            -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \
                            -e AWS_DEFAULT_REGION=us-east-1 \
                            amazon/aws-cli ecr get-login-password --region us-east-1 | \
                            docker login --username AWS --password-stdin 227655494308.dkr.ecr.us-east-1.amazonaws.com

                        # Tag image for ECR
                        docker tag order-tracking-app:${BUILD_NUMBER} 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}

                        # Push image to ECR
                        docker push 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
                    """
                }
            }
        }

        // =====================================================
        // 7. DEPLOY TO AWS EKS
        // Deploy Kubernetes manifests using kubectl
        // =====================================================
        stage("Deploy to EKS") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    sh """
                        # Replace image tag in deployment file
                        sed 's|IMAGE_PLACEHOLDER|227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}|' \
                        kubernetes/deployment.yaml > kubernetes/deployment-final.yaml

                        # Run kubectl inside container
                        docker run --rm \
                            -v \$(pwd)/kubernetes:/manifests \
                            -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \
                            -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \
                            -e AWS_DEFAULT_REGION=us-east-1 \
                            --entrypoint /bin/sh \
                            amazon/aws-cli -c "
                                # Download kubectl
                                curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
                                chmod +x kubectl

                                # Configure kubeconfig for EKS
                                aws eks update-kubeconfig --region us-east-1 --name order-tracking-eks

                                # Deploy application
                                ./kubectl apply -f /manifests/deployment-final.yaml
                                ./kubectl apply -f /manifests/service.yaml
                            "
                    """
                }
            }
        }
    }

    // =====================================================
    // POST ACTIONS (SLACK NOTIFICATIONS)
    // Runs after pipeline execution regardless of result
    // =====================================================
    post {

        // Always executed regardless of success/failure
        always {
            echo 'Pipeline finished. Check logs for details.'
        }

        // =====================================================
        // SUCCESS NOTIFICATION (SLACK)
        // =====================================================
        success {
            echo 'Pipeline completed successfully.'

            script {
                try {
                    withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
                        sh """
                            curl --fail -X POST "\$SLACK_WEBHOOK" \
                            -H "Content-Type: application/json" \
                            -d '{
                                "text":"✅ Jenkins Build Successful\\nProject: Cloud-Native Order Tracking Platform\\nBuild: #${BUILD_NUMBER}\\nJob: ${JOB_NAME}\\nStatus: SUCCESS\\nURL: ${BUILD_URL}"
                            }'
                        """
                    }
                } catch (Exception e) {
                    echo "Slack notification failed: ${e}"
                }
            }
        }

        // =====================================================
        // FAILURE NOTIFICATION (SLACK)
        // =====================================================
        failure {
            echo 'Pipeline failed. Check logs.'

            script {
                try {
                    withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
                        sh """
                            curl --fail -X POST "\$SLACK_WEBHOOK" \
                            -H "Content-Type: application/json" \
                            -d '{
                                "text":"❌ Jenkins Build Failed\\nProject: Cloud-Native Order Tracking Platform\\nBuild: #${BUILD_NUMBER}\\nJob: ${JOB_NAME}\\nStatus: FAILED\\nURL: ${BUILD_URL}"
                            }'
                        """
                    }
                } catch (Exception e) {
                    echo "Slack notification failed: ${e}"
                }
            }
        }
    }
}