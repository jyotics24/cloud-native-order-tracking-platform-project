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
