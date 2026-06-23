// Jenkinsfile
// Defines the CI/CD pipeline for the order tracking platform.
// Each stage runs in order; if any stage fails, the pipeline stops.

pipeline {

    // Run on Jenkins' built-in node for now.
    // Later phases may move specific stages to dedicated agents/containers.
    agent any

    stages {

        // ---------------------------------------------------
        // Stage 1: Unit Testing
        // Installs Python dependencies and runs pytest against
        // the Flask backend. If any test fails, the pipeline
        // stops here and does not proceed to later stages.
        // ---------------------------------------------------
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

        // ---------------------------------------------------
        // Stage 2: Docker Build
        // Builds the application image using the Dockerfile
        // at the repo root. Tags the image with the Jenkins
        // build number so every build produces a unique,
        // traceable image (e.g. order-tracking-app:5).
        // ---------------------------------------------------
        stage("Docker Build") {
            steps {
                sh """
                    docker build -t order-tracking-app:${BUILD_NUMBER} .
                    docker tag order-tracking-app:${BUILD_NUMBER} order-tracking-app:latest
                """
            }
        }

    }

    // ---------------------------------------------------
    // Post-build actions: run regardless of success/failure.
    // Useful for cleanup or notifications later.
    // ---------------------------------------------------
    post {
        always {
            echo 'Pipeline finished. Check above for test results.'
        }
    }
}
