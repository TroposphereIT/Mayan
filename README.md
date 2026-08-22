# Mayan EDMS on AWS

## Overview

This repository contains the architecture, Infrastructure as Code (IaC), Kubernetes configuration, Helm deployment, CI/CD workflows, and operational documentation used to deploy **Mayan EDMS** as a cloud-native workload on **Amazon Web Services (AWS)**.

The project uses **Amazon Elastic Kubernetes Service (EKS)** as the primary container orchestration platform and is designed around DevOps, Infrastructure as Code, security, availability, scalability, and repeatable deployment practices.

The architecture is intended to provide a **manageable, scalable, reproducible, and predictable** platform for deploying and operating Mayan EDMS.

---

## Architecture Objectives

The AWS Mayan platform is designed to:

* Deploy Mayan EDMS on **Amazon EKS**
* Use Kubernetes and **Helm** for application deployment and lifecycle management
* Provide secure external HTTPS access to Mayan
* Deploy AWS infrastructure through **Terraform**
* Maintain infrastructure and application configuration in **GitHub**
* Implement automated validation and deployment using **GitHub Actions**
* Separate AWS infrastructure, Kubernetes platform configuration, and Mayan application deployment
* Support persistent document and application storage
* Provide highly available database and supporting services
* Integrate logging, monitoring, security, and operational controls
* Support repeatable Dev, Test, and Production deployments

---

## High-Level Architecture

```text
                         Internet
                            |
                         Route 53
                            |
                       ACM Certificate
                            |
                    AWS ALB / NLB
                            |
                  Kubernetes Ingress
                            |
                    Amazon EKS Cluster
                            |
                 +----------+----------+
                 |                     |
           Mayan Service          Mayan Pods
                                      |
             +------------------------+----------------------+
             |                        |                      |
        PostgreSQL                 Redis                RabbitMQ
          / RDS                / ElastiCache          / Amazon MQ
             |
             +------------------------+
                                      |
                               Mayan Application
                                      |
                         +------------+------------+
                         |                         |
                    S3 Storage                 EFS / EBS
                         |
                    Documents/Data

Supporting AWS Services:

    Amazon ECR
    AWS IAM / EKS Pod Identity
    AWS Secrets Manager
    Amazon CloudWatch
    AWS Load Balancer Controller
```

---

## Core Technologies

| Technology              | Purpose                                |
| ----------------------- | -------------------------------------- |
| AWS                     | Cloud infrastructure platform          |
| Amazon EKS              | Managed Kubernetes platform            |
| Kubernetes              | Container orchestration                |
| Helm                    | Mayan application deployment           |
| Terraform               | Infrastructure as Code                 |
| GitHub                  | Source control and platform repository |
| GitHub Actions          | CI/CD pipeline automation              |
| Amazon ECR              | Container image repository             |
| Amazon VPC              | Network architecture                   |
| AWS ALB/NLB             | External application access            |
| Route 53                | DNS                                    |
| AWS Certificate Manager | TLS certificates                       |
| Amazon RDS              | PostgreSQL database                    |
| Amazon S3               | Object/document storage                |
| Amazon EBS/EFS          | Kubernetes persistent storage          |
| ElastiCache             | Redis services                         |
| Amazon MQ               | RabbitMQ messaging option              |
| CloudWatch              | Logging and monitoring                 |
| Secrets Manager         | Application secrets                    |
| IAM / EKS Pod Identity  | AWS workload authorization             |

---

# Repository Structure

```text
Mayan/
│
├── README.md
│
├── terraform/
│   ├── environments/
│   │   ├── dev/
│   │   └── prod/
│   │
│   └── modules/
│       ├── vpc/
│       ├── eks/
│       ├── ecr/
│       ├── rds/
│       ├── s3/
│       ├── iam/
│       ├── route53/
│       └── monitoring/
│
├── helm/
│   └── mayan/
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│
├── kubernetes/
│   ├── namespaces/
│   ├── ingress/
│   ├── storage/
│   └── secrets/
│
├── scripts/
│   ├── bootstrap.sh
│   ├── validate.sh
│   └── deploy.sh
│
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml
│       ├── terraform-apply.yml
│       ├── helm-validate.yml
│       └── deploy-mayan.yml
│
└── docs/
    ├── architecture.md
    ├── networking.md
    ├── deployment.md
    └── operations.md
```

---

# AWS Network Architecture

The platform will use a dedicated AWS VPC spanning multiple Availability Zones.

A typical production design will include:

```text
AWS VPC
│
├── Availability Zone 1
│   ├── Public Subnet
│   │      └── ALB / NAT Gateway
│   │
│   └── Private Subnet
│          └── EKS Worker Nodes
│
├── Availability Zone 2
│   ├── Public Subnet
│   │      └── ALB / NAT Gateway
│   │
│   └── Private Subnet
│          └── EKS Worker Nodes
│
└── Data Subnets
       ├── RDS PostgreSQL
       └── Supporting data services
```

EKS worker nodes should not require direct inbound Internet exposure.

External application access will terminate through an AWS-managed load balancer.

---

# External Application Access

Mayan will be published using an AWS load balancer integrated with Kubernetes.

Preferred HTTP/HTTPS architecture:

```text
Internet
   |
Route 53
   |
AWS Certificate Manager
   |
Application Load Balancer
   |
AWS Load Balancer Controller
   |
Kubernetes Ingress
   |
Mayan Kubernetes Service
   |
Mayan Pods
```

This provides external application access without exposing individual EKS nodes or Kubernetes pods directly to the Internet.

---

# Kubernetes Platform

Amazon EKS provides the Kubernetes control plane.

The EKS environment will host the Mayan application workloads and supporting Kubernetes services.

Initial Kubernetes components include:

* Mayan namespace
* Mayan deployments
* Kubernetes services
* Kubernetes ingress
* AWS Load Balancer Controller
* PersistentVolumeClaims
* Storage classes
* Kubernetes configuration
* Helm releases
* Secrets integration
* Health probes
* Resource requests and limits

Production deployments should support multiple Mayan replicas where supported by the application architecture.

---

# Helm Deployment

Mayan application deployment will be managed through Helm.

```text
helm/
└── mayan/
    ├── Chart.yaml
    ├── values.yaml
    └── templates/
```

Helm will manage application-level Kubernetes resources including:

* Deployments
* Services
* Ingress
* Persistent storage
* Configuration
* Secrets references
* Resource limits
* Health checks

Environment-specific configuration should be maintained separately from the base Helm chart.

---

# Infrastructure as Code

AWS infrastructure will be provisioned through **Terraform**.

Terraform modules will be used for major platform components.

```text
terraform/modules/

vpc/
eks/
ecr/
rds/
s3/
iam/
route53/
monitoring/
```

Environment-specific Terraform configuration will be stored under:

```text
terraform/environments/

dev/
prod/
```

Terraform state should be stored remotely using an AWS-backed state configuration with appropriate state locking, encryption, versioning, and access controls.

---

# CI/CD

GitHub Actions will provide the CI/CD workflow for infrastructure and application deployment.

## Pull Request

```text
Developer
    |
Git Branch
    |
Pull Request
    |
    +-- Terraform Format
    +-- Terraform Validate
    +-- Terraform Plan
    +-- Helm Lint
    +-- Helm Template Validation
    +-- Security Validation
    |
Code Review
```

## Merge / Deployment

```text
Merge to Main
     |
GitHub Actions
     |
     +-- Terraform Apply
     |
     +-- AWS Infrastructure
     |
     +-- EKS Platform
     |
     +-- Helm Deployment
     |
     +-- Mayan
     |
     +-- Deployment Validation
```

Production Terraform apply and application deployment should support approval controls before changes are implemented.

---

# Security

Security will be integrated throughout the platform rather than implemented as a separate deployment phase.

Primary controls include:

* IAM least privilege
* EKS Pod Identity / workload-specific AWS permissions
* Private EKS worker nodes
* Security Groups
* Network segmentation
* TLS encryption
* ACM certificates
* Encryption at rest
* AWS Secrets Manager
* ECR image scanning
* Terraform security validation
* Kubernetes security controls
* Centralized logging
* CloudWatch monitoring
* Audit logging
* Vulnerability remediation processes

Credentials and secrets must **never be committed to the GitHub repository**.

---

# Persistent Storage

Mayan requires persistent storage for application and document data.

The AWS architecture may utilize multiple storage technologies depending on the workload.

### Amazon S3

Preferred for object/document storage where supported by Mayan.

### Amazon EBS

Used for block-based persistent Kubernetes volumes where appropriate.

### Amazon EFS

Used where shared filesystem access across multiple Kubernetes workloads is required.

Storage selection will be validated against Mayan EDMS application requirements before the production architecture is finalized.

---

# Database

Production deployments should use an external PostgreSQL database rather than coupling the primary production database lifecycle directly to the EKS cluster.

Preferred architecture:

```text
Mayan Pods
     |
Private AWS Network
     |
Amazon RDS
     |
PostgreSQL
```

RDS provides AWS-managed capabilities for database availability, backup, recovery, patching, monitoring, and scaling.

---

# Monitoring and Operations

The platform will integrate AWS and Kubernetes monitoring.

Initial monitoring will include:

* EKS cluster health
* Kubernetes node health
* Pod health
* Application availability
* CPU utilization
* Memory utilization
* Storage utilization
* Load balancer health
* Database availability
* Application logs
* Kubernetes logs
* AWS service logs

Amazon CloudWatch will provide the initial centralized AWS monitoring and logging platform.

Additional Kubernetes-native monitoring can be integrated as requirements evolve.

---

# Availability and Resilience

The production platform will be designed around multiple AWS Availability Zones.

Key availability objectives include:

* Multi-AZ networking
* Multiple EKS worker nodes
* Kubernetes workload distribution
* Application health probes
* Load balancer health checks
* RDS availability
* Persistent data protection
* Automated workload recovery
* Infrastructure reproducibility through Terraform
* Application reproducibility through Helm

The objective is to minimize single points of failure and provide a platform capable of automatically recovering from common infrastructure and application failures.

---

# Deployment Phases

## Phase 1 — Core Platform

Build the initial working Mayan AWS environment:

```text
VPC
 ↓
EKS
 ↓
Worker Nodes
 ↓
AWS Load Balancer Controller
 ↓
Helm
 ↓
Mayan Pods
 ↓
External Endpoint
```

**Goal:** Successfully access Mayan through an externally published AWS endpoint.

## Phase 2 — Persistent Data Services

Implement:

* PostgreSQL / RDS
* Persistent document storage
* S3
* EBS/EFS where required
* Redis
* RabbitMQ

## Phase 3 — DNS and Security

Implement:

* Route 53
* ACM certificates
* HTTPS
* Secrets Manager
* IAM / EKS Pod Identity
* Security policies
* Image and infrastructure scanning

## Phase 4 — CI/CD

Implement GitHub Actions for:

* Terraform validation
* Terraform plan
* Terraform apply
* Helm validation
* Mayan deployment
* Deployment verification

## Phase 5 — Production Hardening

Implement:

* Multi-AZ resilience
* Monitoring
* Logging
* Alerting
* Backup/recovery
* Security validation
* Capacity planning
* Operational procedures
* MOPs/runbooks

---

# Initial Deployment Goal

The first milestone is intentionally focused on establishing a functional end-to-end Kubernetes deployment:

> **GitHub → Terraform → AWS → EKS → Helm → Mayan → AWS Load Balancer → External Access**

Once this path is operational and validated, additional production services will be introduced incrementally.

---

# Platform Engineering Principles

The project follows several core engineering principles:

**Manageable** — The platform must be straightforward to operate and troubleshoot.

**Scalable** — Infrastructure and application capacity must be capable of expanding with workload demand.

**Reproducible** — Infrastructure and application deployments must be reproducible through Terraform, Kubernetes, Helm, and CI/CD.

**Predictable** — Deployment and operational behavior should be consistent across environments.

Infrastructure changes should be performed through code wherever practical rather than manual console configuration.

---

# Project

**Mayan EDMS AWS Kubernetes Deployment**

Repository: `TroposphereIT/Mayan`

Platform: Amazon Web Services

Container Platform: Amazon EKS / Kubernetes

Infrastructure as Code: Terraform

Application Deployment: Helm

Source Control: GitHub

CI/CD: GitHub Actions

---

## Status

**Current Phase:** AWS architecture and EKS platform design.

**Next Milestone:** Deploy the initial AWS VPC and EKS environment, install the AWS Load Balancer Controller, deploy Mayan using Helm, and validate external application access.
