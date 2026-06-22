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
