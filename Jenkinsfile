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
                        pytest test_app.py -v
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
        // Scans the built Docker image for known
        // vulnerabilities (CVEs) in OS packages and
        // language dependencies. exit-code 0 means it
        // reports findings without failing the build yet.
        // =====================================================
        stage('Trivy Scan') {
            steps {
                sh """
                    trivy image --severity CRITICAL,HIGH --exit-code 0 order-tracking-app:${BUILD_NUMBER}
                """
            }
        }

        // =====================================================
        // Stage 5: Terraform Apply (App Infra - ECR)
        // =====================================================
        // Runs Terraform inside an official HashiCorp Docker
        // image to create/update the ECR repository. This is a
        // SEPARATE Terraform state from the Jenkins EC2 itself,
        // so this stage can never modify or destroy the server
        // it's running on.
        // =====================================================
        stage("Terraform Apply - ECR") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "aws-jenkins-ecr",
                    usernameVariable: "AWS_ACCESS_KEY_ID",
                    passwordVariable: "AWS_SECRET_ACCESS_KEY"
                )]) {
                    dir("terraform-app") {
                        sh """
                            docker run --rm \
                                -v \$(pwd):/workspace \
                                -w /workspace \
                                -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \
                                -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \
                                -e AWS_DEFAULT_REGION=us-east-1 \
                                hashicorp/terraform:latest init
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
        // Stage 6: Push Image to ECR
        // =====================================================
        // Authenticates Docker to ECR using the AWS CLI, then
        // tags and pushes the image built earlier in the
        // pipeline to the ECR repository created above.
        // =====================================================
        stage("Push to ECR") {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "aws-jenkins-ecr",
                    usernameVariable: "AWS_ACCESS_KEY_ID",
                    passwordVariable: "AWS_SECRET_ACCESS_KEY"
                )]) {
                    sh """
                        docker run --rm \
                            -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \
                            -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \
                            -e AWS_DEFAULT_REGION=us-east-1 \
                            amazon/aws-cli ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 227655494308.dkr.ecr.us-east-1.amazonaws.com
                        docker tag order-tracking-app:${BUILD_NUMBER} 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
                        docker push 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
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
