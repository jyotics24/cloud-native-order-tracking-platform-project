// // Jenkinsfile
// // Defines the CI/CD pipeline for the order tracking platform.
// // Each stage runs in order; if any stage fails, the pipeline stops.

// pipeline {

//     // Run on Jenkins' built-in node for now.
//     // Later phases may move specific stages to dedicated agents/containers.
//     agent any

//     stages {

//         // ---------------------------------------------------
//         // Stage 1: Unit Testing
//         // Installs Python dependencies and runs pytest against
//         // the Flask backend. If any test fails, the pipeline
//         // stops here and does not proceed to later stages.
//         // ---------------------------------------------------
//         stage('Unit Testing') {
//             steps {
//                 dir('app/backend') {
//                     sh '''
//                         python3 -m venv venv
//                         . venv/bin/activate
//                         pip install -r requirements.txt
//                         pytest test_app.py -v
//                     '''
//                 }
//             }
//         }

//         // ---------------------------------------------------
//         // Stage 2: Docker Build
//         // Builds the application image using the Dockerfile
//         // at the repo root. Tags the image with the Jenkins
//         // build number so every build produces a unique,
//         // traceable image (e.g. order-tracking-app:5).
//         // ---------------------------------------------------
//         stage("Docker Build") {
//             steps {
//                 sh """
//                     docker build -t order-tracking-app:${BUILD_NUMBER} .
//                     docker tag order-tracking-app:${BUILD_NUMBER} order-tracking-app:latest
//                 """
//             }
//         }

//     }

//     // ---------------------------------------------------
//     // Post-build actions: run regardless of success/failure.
//     // Useful for cleanup or notifications later.
//     // ---------------------------------------------------
//     post {
//         always {
//             echo 'Pipeline finished. Check above for test results.'
//         }
//     }
// }

// =====================================================
// Jenkinsfile
// Cloud-Native E-Commerce Order Tracking Platform
//
// Current Pipeline Flow:
//
// 1. Unit Testing
// 2. SonarCloud Scan
// 3. Docker Build
//
// If any stage fails, Jenkins stops the pipeline.
// =====================================================

pipeline {

    // Run on Jenkins built-in agent
    agent any

    stages {

        // =====================================================
        // Stage 1: Unit Testing
        // =====================================================
        // Creates Python virtual environment
        // Installs dependencies
        // Runs pytest tests
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
        // Sends code quality analysis to SonarCloud
        //
        // Requirements:
        // 1. SonarCloud project created
        // 2. sonar-project.properties exists
        // 3. SonarCloud configured in Jenkins
        // 4. Sonar Scanner configured in Jenkins Tools
        // =====================================================
//        stage('Sonar Scan') {
//            steps {
//
//                script {
//
//                    def scannerHome = tool 'sonar-scanner'
//
//                    withSonarQubeEnv('SonarCloud') {
//
//                        sh """
//                            ${scannerHome}/bin/sonar-scanner
//                        """

//                    }
//                }
//            }
//        }

        // =====================================================
        // Stage 3: Docker Build
        // =====================================================
        // Builds Docker image
        // Tags image using Jenkins build number
        // Creates latest tag
        // =====================================================
        stage('Docker Build') {
            steps {

                sh """
                    docker build -t order-tracking-app:${BUILD_NUMBER} .

                    docker tag order-tracking-app:${BUILD_NUMBER} order-tracking-app:latest
                """

            }
        }
    }

    // =====================================================
    // Post Actions
    // =====================================================
    // Runs regardless of success or failure
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