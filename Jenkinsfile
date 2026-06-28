def failedStage = 'Unknown / Checkout'

pipeline {

    // =====================================================
    // Jenkins agent (runs on any available executor)
    // =====================================================
    agent any

    stages {

        // =====================================================
        // 1. UNIT TESTING STAGE
        // =====================================================
        stage('Unit Testing') {
            steps {
                dir('app/backend') {
                    sh '''
                        rm -rf venv
                        python3 -m venv venv
                        . venv/bin/activate
                        pip install -r requirements.txt
                        pip install pytest pytest-cov
                        pytest --cov=. --cov-report=xml test_app.py -v
                    '''
                }
            }
            post {
                failure {
                    script { failedStage = 'Unit Testing' }
                }
            }
        }

        // =====================================================
        // 2. SONARQUBE / SONARCLOUD ANALYSIS
        // =====================================================
        stage('Sonar Scan') {
            steps {
                script {
                    def scannerHome = tool 'sonar-scanner'
                    withSonarQubeEnv('SonarCloud') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
            post {
                failure {
                    script { failedStage = 'Sonar Scan' }
                }
            }
        }

        // =====================================================
        // =====================================================
        // 2b. SONARCLOUD QUALITY GATE CHECK (informational only)
        // =====================================================
        stage('Quality Gate') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate abortPipeline: false
                        echo "SonarCloud Quality Gate result: ${qg.status}"
                        if (qg.status != 'OK') {
                            echo "WARNING: Quality Gate did not pass (status: ${qg.status}). Continuing pipeline anyway — gate is informational while test coverage is being built up."
                        }
                    }
                }
            }
        }

        // =====================================================
        // 3. DOCKER IMAGE BUILD
        // =====================================================
        stage('Docker Build') {
            steps {
                sh """
                    docker build -t order-tracking-app:${BUILD_NUMBER} .
                    docker tag order-tracking-app:${BUILD_NUMBER} order-tracking-app:latest
                """
            }
            post {
                failure {
                    script { failedStage = 'Docker Build' }
                }
            }
        }

        // =====================================================
        // 4. TRIVY SECURITY SCAN
        // =====================================================
        stage('Trivy Scan') {
            steps {
                sh "trivy image --severity CRITICAL,HIGH --ignore-unfixed --exit-code 1 order-tracking-app:${BUILD_NUMBER}"
            }
            post {
                failure {
                    script { failedStage = 'Trivy Scan' }
                }
            }
        }

        // =====================================================
        // 5. TERRAFORM INFRASTRUCTURE DEPLOYMENT
        // =====================================================
        stage("Terraform Apply - ECR") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
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
            post {
                failure {
                    script { failedStage = 'Terraform Apply - ECR' }
                }
            }
        }

        // =====================================================
        // 6. PUSH DOCKER IMAGE TO AWS ECR
        // =====================================================
        stage("Push to ECR") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    sh """
                        docker run --rm \
                            -e AWS_ACCESS_KEY_ID=\$AWS_ACCESS_KEY_ID \
                            -e AWS_SECRET_ACCESS_KEY=\$AWS_SECRET_ACCESS_KEY \
                            -e AWS_DEFAULT_REGION=us-east-1 \
                            amazon/aws-cli ecr get-login-password --region us-east-1 | \
                            docker login --username AWS --password-stdin 227655494308.dkr.ecr.us-east-1.amazonaws.com

                        docker tag order-tracking-app:${BUILD_NUMBER} 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
                        docker push 227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}
                    """
                }
            }
            post {
                failure {
                    script { failedStage = 'Push to ECR' }
                }
            }
        }

        // =====================================================
        // 7. DEPLOY TO AWS EKS
        // =====================================================
        stage("Deploy to EKS") {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr']]) {
                    script {
                        sh """
                            set -e
                            sed 's|IMAGE_PLACEHOLDER|227655494308.dkr.ecr.us-east-1.amazonaws.com/order-tracking-app:${BUILD_NUMBER}|' \
                            kubernetes/deployment.yaml > kubernetes/deployment-final.yaml
                            grep -q '227655494308' kubernetes/deployment-final.yaml || (echo 'ERROR: sed replace failed' && exit 1)
                        """

                        sh '''
                            docker run --rm \
                                -v $(pwd):/workspace \
                                -w /workspace \
                                -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
                                -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
                                -e AWS_DEFAULT_REGION=us-east-1 \
                                --entrypoint /bin/sh \
                                amazon/aws-cli -c '
                                    set -e
                                    curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
                                    chmod +x kubectl
                                    aws eks update-kubeconfig --region us-east-1 --name order-tracking-eks
                                    
                                    ./kubectl apply -f kubernetes/deployment-final.yaml
                                    ./kubectl apply -f kubernetes/service.yaml

                                    set +e
                                    ./kubectl rollout status deployment/order-tracking-app --timeout=300s
                                    ROLLOUT_EXIT_CODE=$?
                                    set -e

                                    echo "===== CLUSTER SERVICE DEBUG ====="
                                    ./kubectl get nodes
                                    ./kubectl get svc
                                    ./kubectl get svc order-tracking-service -o wide

                                    echo "===== POD STATUS ====="
                                    ./kubectl get pods -l app=order-tracking-app -o wide

                                    echo "===== POD DESCRIBE (events + reasons) ====="
                                    for pod in $(./kubectl get pods -l app=order-tracking-app -o jsonpath="{.items[*].metadata.name}"); do
                                        echo "--- describe $pod ---"
                                        ./kubectl describe pod "$pod" | tail -40
                                        echo "--- logs $pod ---"
                                        ./kubectl logs "$pod" --tail=50 || echo "(no logs available yet)"
                                    done

                                    if [ "$ROLLOUT_EXIT_CODE" -ne 0 ]; then
                                        echo "ERROR: rollout did not complete, see pod diagnostics above"
                                        exit 1
                                    fi
                                    
                                    HOSTNAME=""
                                    i=1
                                    while [ $i -le 20 ]; do
                                        HOSTNAME=$(./kubectl get svc order-tracking-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null || true)
                                        if [ ! -z "$HOSTNAME" ]; then
                                            break
                                        fi
                                        i=$((i+1))
                                        sleep 10
                                    done
                                    
                                    echo "$HOSTNAME" > /workspace/app_endpoint.txt
                                '
                        '''
                    }
                }
            }
            post {
                failure {
                    script { failedStage = 'Deploy to EKS' }
                }
            }
        }

        // =====================================================
        // 8. INSTALL MONITORING (PROMETHEUS + GRAFANA)
        // =====================================================
        stage("Install Monitoring") {
            steps {
                withCredentials([
                    [$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-jenkins-ecr'],
                    string(credentialsId: 'grafana-admin-password', variable: 'GRAFANA_ADMIN_PASSWORD')
                ]) {
                    script {
                        sh '''
                            docker run --rm \
                                -v $(pwd):/workspace \
                                -w /workspace \
                                -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
                                -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
                                -e AWS_DEFAULT_REGION=us-east-1 \
                                -e GRAFANA_ADMIN_PASSWORD=$GRAFANA_ADMIN_PASSWORD \
                                --entrypoint /bin/sh \
                                amazon/aws-cli -c '
                                    set -e
                                    (yum install -y openssl tar gzip -q 2>/dev/null) || (microdnf install -y openssl tar gzip 2>/dev/null) || true
                                    curl -LO https://dl.k8s.io/release/v1.31.0/bin/linux/amd64/kubectl
                                    chmod +x kubectl
                                    mv kubectl /usr/local/bin/kubectl
                                    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
                                    chmod +x get_helm.sh
                                    ./get_helm.sh --version v3.16.0
                                    
                                    aws eks update-kubeconfig --region us-east-1 --name order-tracking-eks
                                    chmod +x monitoring/install-monitoring.sh
                                    ./monitoring/install-monitoring.sh
                                    
                                    echo "===== MONITORING SERVICE DEBUG ====="
                                    /usr/local/bin/kubectl get svc -n monitoring
                                    /usr/local/bin/kubectl get svc prometheus-grafana -n monitoring -o wide
                                    
                                    HOSTNAME=""
                                    i=1
                                    while [ $i -le 20 ]; do
                                        HOSTNAME=$(/usr/local/bin/kubectl get svc prometheus-grafana -n monitoring -o jsonpath="{.status.loadBalancer.ingress[0].hostname}" 2>/dev/null || true)
                                        if [ ! -z "$HOSTNAME" ]; then
                                            break
                                        fi
                                        i=$((i+1))
                                        sleep 10
                                    done
                                    
                                    echo "$HOSTNAME" > /workspace/grafana_endpoint.txt
                                '
                        '''
                    }
                }
            }
            post {
                failure {
                    script { failedStage = 'Install Monitoring' }
                }
            }
        }
    }

    // =====================================================
    // POST ACTIONS (SLACK NOTIFICATIONS)
    // FIXED: Files read directly inside the execution scope of post
    // =====================================================
    post {

        always {
            echo 'Pipeline finished. Check logs for details.'
        }

        success {
            echo 'Pipeline completed successfully.'
            script {
                try {
                    // Read the files directly inside the post-success scope to bypass declarative sandboxing
                    def finalAppUrl = readFile('app_endpoint.txt').trim()
                    def finalGrafanaUrl = readFile('grafana_endpoint.txt').trim()

                    withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
                        sh """
                            curl --fail -X POST "\$SLACK_WEBHOOK" \
                            -H "Content-Type: application/json" \
                            -d '{
                                "text":"🎉 *Jenkins Pipeline Successful*\\n\\nProject: Cloud-Native Order Tracking Platform\\n\\n🚀 Build: #${BUILD_NUMBER}\\n📦 Job: ${JOB_NAME}\\n\\n🌐 Application:\\nhttp://${finalAppUrl}\\n\\n❤️ Health Check:\\nhttp://${finalAppUrl}/health\\n\\n📊 Grafana Dashboard:\\nhttp://${finalGrafanaUrl}\\n\\n🔗 Jenkins Build:\\n${BUILD_URL}\\n\\nStatus: SUCCESS"
                            }'
                        """
                    }
                } catch (Exception e) {
                    echo "Slack notification failed: ${e}"
                }
            }
        }

        failure {
            echo 'Pipeline failed. Check logs.'
            script {
                try {
                    def stageThatFailed = failedStage

                    withCredentials([string(credentialsId: 'slack-webhook', variable: 'SLACK_WEBHOOK')]) {
                        sh """
                            curl --fail -X POST "\$SLACK_WEBHOOK" \
                            -H "Content-Type: application/json" \
                            -d '{
                                "text":"❌ *Jenkins Build Failed*\\n\\nProject: Cloud-Native Order Tracking Platform\\n\\n🚀 Build: #${BUILD_NUMBER}\\n📦 Job: ${JOB_NAME}\\n🛑 Failed at stage: *${stageThatFailed}*\\n\\n🔗 Jenkins Build:\\n${BUILD_URL}console\\n\\nStatus: FAILED"
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