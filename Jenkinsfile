// =====================================================
// Jenkinsfile
// Cloud-Native E-Commerce Order Tracking Platform
//
// Current Pipeline Flow:
//
// 1. Unit Testing
// 2. SonarCloud Scan
// 3. Docker Build
// 4. Trivy Security Scan
// 5. Terraform Apply (ECR + EKS app infra)
// 6. Push to ECR
// 7. Deploy to EKS
//
// If any stage fails, Jenkins stops the pipeline.
// =====================================================

pipeline {

    agent any

    stages {

        // =====================================================
        // Stage 1: Unit Testing
        // =====================================================
        stage('Unit Testing') {
            steps {
                dir('app/backend') {
                    sh '''
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install -r requirements.txt
                        pip install pytest pytest-cov

                        pytest --cov=. --cov-report=xml test_app.py -v
                    '''
                }
            }
        }

        // =====================================================
        // Stage 2: SonarCloud Scan
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
        // Stage 3: Docker Build
        // =====================================================
        stage('Docker Build') {
            steps {
                sh """
                    docker build -t order-tracking-app:${BUILD_NUMBER} .
                    docker tag order-tracking-app:${BUILD_NUMBER} order-tracking-app:latest
                """
            }
        }

        // =====================================================
        // Stage 4: Trivy Security Scan
        // =====================================================
        stage('Trivy Scan') {
            steps {
                sh """
                    trivy image --severity CRITICAL,HIGH --exit-code 0 order-tracking-app:${BUILD_NUMBER}
                """
            }
        }

        // =====================================================
        // Stage 5: Terraform Apply (ECR + EKS app infra)
        // =====================================================
        stage("Terraform Apply - ECR") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    dir("terraform-app") {
                        sh """
                            docker run --rm \\
                                -v \$(pwd):/workspace \\
                                -w /workspace \\
                                -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
                                -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
                                -e AWS_DEFAULT_REGION=us-east-1 \\
                                hashicorp/terraform:latest init
                            docker run --rm \\
                                -v \$(pwd):/workspace \\
                                -w /workspace \\
                                -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
                                -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
                                -e AWS_DEFAULT_REGION=us-east-1 \\
                                hashicorp/terraform:latest apply -auto-approve
                        """
                    }
                }
            }
        }

        // =====================================================
        // Stage 6: Push to ECR
        // =====================================================
        stage("Push to ECR") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    sh """
                        docker run --rm \\
                            -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
                            -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
                            -e AWS_DEFAULT_REGION=us-east-1 \\
                            amazon/aws-cli ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 227655494308.dkr.ecr.us-east-1.amazonaws.com
                        docker tag order-tracking-app:${BUILD_NUMBER} 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
                        docker push 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
                    """
                }
            }
        }

        // =====================================================
        // Stage 7: Deploy to EKS
        // =====================================================
        // Updates kubeconfig to point at the EKS cluster, then
        // applies the deployment + service manifests, substituting
        // the placeholder image with the real ECR image just pushed.
        // Uses a kubectl Docker image since kubectl isn't installed
        // directly on the Jenkins EC2.
        // =====================================================
        stage("Deploy to EKS") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    sh """
                        sed 's|IMAGE_PLACEHOLDER|227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}|' kubernetes/deployment.yaml > kubernetes/deployment-final.yaml

                        docker run --rm \\
                            -v \$(pwd)/kubernetes:/manifests \\
                            -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \\
                            -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \\
                            -e AWS_DEFAULT_REGION=us-east-1 \\
                            --entrypoint /bin/sh \\
                            amazon/aws-cli -c "
                                yum install -y unzip curl >/dev/null 2>&1 || true
                                curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
                                chmod +x kubectl
                                aws eks update-kubeconfig --region us-east-1 --name order-tracking-eks
                                ./kubectl apply -f /manifests/deployment-final.yaml
                                ./kubectl apply -f /manifests/service.yaml
                            "
                    """
                }
            }
        }

    }

    // =====================================================
    // Post Actions
    // =====================================================
    post {
        always {
            echo 'Pipeline finished. Check above for results.'
        }
        success {
            echo 'Pipeline completed successfully.'
        }
        failure {
            echo 'Pipeline failed. Check logs.'
        }
    }
}
