# Cloud-Native Order Tracking Platform

> End-to-end production-style DevOps project demonstrating CI/CD,
> Infrastructure as Code, Kubernetes deployment, monitoring, and
> security on AWS.

## 📖 Overview

This project automates the complete software delivery lifecycle for a
containerized Order Tracking application. A GitHub push triggers a
Jenkins pipeline that performs testing, code quality analysis, security
scanning, infrastructure provisioning, container deployment to Amazon
EKS, monitoring installation, and Slack notifications.

## 🏗️ Architecture

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

## ✨ Features

-   Automated CI/CD with Jenkins
-   GitHub Webhook integration
-   Infrastructure as Code using Terraform
-   Docker containerization
-   Amazon ECR image management
-   Amazon EKS deployment
-   Kubernetes rolling updates
-   Pytest unit testing
-   SonarCloud static code analysis
-   Trivy vulnerability scanning
-   Prometheus monitoring
-   Grafana dashboards
-   Slack build notifications

## 🛠️ Technology Stack

  Category        Technologies
  --------------- -------------------------
  Cloud           AWS
  CI/CD           Jenkins, GitHub
  IaC             Terraform
  Containers      Docker
  Orchestration   Kubernetes (Amazon EKS)
  Registry        Amazon ECR
  Backend         Python, Flask
  Testing         Pytest
  Code Quality    SonarCloud
  Security        Trivy
  Monitoring      Prometheus, Grafana
  Notifications   Slack

## 📂 Repository Structure

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

## 🔄 Jenkins Pipeline

1.  Unit Testing
2.  SonarCloud Scan
3.  Docker Build
4.  Trivy Security Scan
5.  Terraform Apply
6.  Push Docker Image to Amazon ECR
7.  Deploy Application to Amazon EKS
8.  Install Prometheus & Grafana
9.  Send Slack Notification

## 📊 Monitoring

-   **Prometheus** collects Kubernetes metrics.
-   **Grafana** visualizes infrastructure and application metrics.

## 🔐 Security

-   SonarCloud code quality analysis
-   Trivy image vulnerability scanning
-   Jenkins Credentials for secrets management

<!-- ## 📸 Suggested Screenshots

-   Jenkins Pipeline Success
-   SonarCloud Dashboard
-   Trivy Scan Output
-   Amazon ECR Repository
-   Amazon EKS Workloads
-   Grafana Dashboard
-   Prometheus Targets
-   Slack Notifications -->

## 🚀 Future Improvements

-   Cluster Autoscaler
-   Horizontal Pod Autoscaler
-   Fluent Bit + CloudWatch Logs
-   HTTPS with ACM & Route 53
-   GitOps using Argo CD

## 👤 Author

**Jyotiprakash Khuntia**

DevOps Engineer

## 📄 License

This repository is intended for learning, demonstration, and portfolio
purposes..
