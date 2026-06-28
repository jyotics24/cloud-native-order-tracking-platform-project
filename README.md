# Cloud-Native Order Tracking Platform

## Overview

A production-style cloud-native DevOps project that demonstrates an
end-to-end CI/CD pipeline for deploying a containerized Order Tracking
application on Amazon EKS using Jenkins, Terraform, Docker, Kubernetes,
SonarCloud, Trivy, Prometheus, Grafana, and Slack notifications.

## Architecture

``` text
Developer
    │
    ▼
GitHub Repository
    │
    ▼
GitHub Webhook
    │
    ▼
Jenkins Pipeline
    ├── Unit Testing (Pytest)
    ├── SonarCloud Scan
    ├── Docker Build
    ├── Trivy Scan
    ├── Terraform Apply
    ├── Push Image to Amazon ECR
    ├── Deploy to Amazon EKS
    ├── Install Prometheus & Grafana
    └── Slack Notification
                     │
                     ▼
              Amazon EKS Cluster
                 ├── Order Tracking App
                 ├── Prometheus
                 ├── Grafana
                 └── Kubernetes Services
```

## Features

-   Automated CI/CD with Jenkins
-   GitHub Webhook integration
-   Docker containerization
-   Infrastructure as Code using Terraform
-   Amazon ECR image registry
-   Amazon EKS deployment
-   Kubernetes rolling updates
-   Pytest unit testing
-   SonarCloud static code analysis
-   Trivy image vulnerability scanning
-   Prometheus monitoring
-   Grafana dashboards
-   Slack build notifications

## Technology Stack

  Category        Technologies
  --------------- -------------------------
  Cloud           AWS
  CI/CD           Jenkins, GitHub
  IaC             Terraform
  Containers      Docker
  Orchestration   Kubernetes (Amazon EKS)
  Registry        Amazon ECR
  Language        Python, Flask
  Testing         Pytest
  Code Quality    SonarCloud
  Security        Trivy
  Monitoring      Prometheus, Grafana
  Notifications   Slack

## Repository Structure

``` text
.
├── app/
├── ansible/
├── kubernetes/
├── monitoring/
│   ├── install-monitoring.sh
│   └── values.yaml
├── terraform/
├── terraform-app/
├── Dockerfile
├── Jenkinsfile
├── sonar-project.properties
└── README.md
```

## Jenkins Pipeline

1.  Unit Testing
2.  SonarCloud Scan
3.  Docker Build
4.  Trivy Scan
5.  Terraform Apply
6.  Push Image to Amazon ECR
7.  Deploy to Amazon EKS
8.  Install Prometheus & Grafana
9.  Slack Notification

## Monitoring

### Prometheus

Collects Kubernetes cluster metrics.

### Grafana

Visualizes metrics through dashboards.

## Security

-   SonarCloud code quality checks
-   Trivy container image scanning
-   AWS IAM credentials managed through Jenkins Credentials

## Future Improvements

-   Cluster Autoscaler
-   Horizontal Pod Autoscaler
-   HTTPS with ACM and Route 53
-   Fluent Bit + CloudWatch Logs
-   GitOps using Argo CD

## Author

**Jyotiprakash Khuntia**

DevOps Engineer

## License

This project is for learning and portfolio purposes.