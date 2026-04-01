# Azure Data Platform IaC

This repository contains the Infrastructure as Code (IaC) and GitOps configurations for a production-grade Azure Data Platform. It is designed to demonstrate senior-level cloud engineering practices including multi-environment orchestration, Zero Trust networking, identity-first security, and declarative Kubernetes management.

## Architecture Highlights
- **Infrastructure Orchestration:** OpenTofu + Terragrunt for DRY, scalable deployments across `dev` and `prod`.
- **Zero Trust Networking:** Azure VNet isolating all components. ADLS, KeyVault, and PostgreSQL are accessed exclusively via Private Endpoints. Default-deny Network Security Groups and Kubernetes Network Policies.
- **Identity-First Security:** AKS leverages SystemAssigned Managed Identities and OIDC Issuer for Workload Identity, eliminating hardcoded service principal secrets from Kubernetes pods.
- **Push-Based GitOps:** Kubernetes cluster state strictly matches the repository. We implement Stage 1 "Push-Based GitOps" via GitHub Actions, running validation and `kubectl apply` continuously for all manifests in the `k8s/` directory without requiring cluster-side agents.
- **DevSecOps:** GitHub Actions pipeline with `checkov` for IaC static analysis, `kubeval` for manifest validation, OIDC federation for Azure authentication, and distinct environment approval gates.

## Directory Structure
- `.github/workflows/ci-cd.yml` - Production CI/CD pipeline.
- `docs/` - Architecture documentation, GitOps maturity models, and interview prep.
- `infra/` - Terragrunt environment configurations (`live/`) and OpenTofu modules (`modules/`).
- `k8s/` - GitOps cluster state (`base/` for platform resources, `apps/` for workloads).
- `scripts/` - Automation utilities (Checkov scan).

## Getting Started

### 1. Prerequisites
- `az` CLI
- `tofu` (OpenTofu >= 1.5)
- `terragrunt`
- `kubectl`

### 2. Deploy Infrastructure (Dev)
```bash
az login
cd infra/live/dev

# Terragrunt will automatically use 'tofu' as we configured in root.hcl
terragrunt run --all init
terragrunt run --all apply
```
This deploys the VNet, KeyVault, ADLS Gen2, PostgreSQL Flexible Server, and an AKS cluster with Workload Identity enabled.

### 3. Retrieve Cluster Credentials
```bash
az aks get-credentials --resource-group te-data-dev-rg --name te-dev-aks
```

### 4. Deploy Kubernetes Manifests (Push GitOps)
Instead of manual commands, our CI/CD pipeline acts as the GitOps engine. For local testing, you can simulate the pipeline by applying the base cluster configurations directly:
```bash
kubectl apply -f ../../../k8s/base/
```
These manifests will automatically provision namespaces, resource quotas, default-deny network policies, and Workload Identity ServiceAccounts.

---
**Interview Prep:** Please review `docs/INTERVIEW_PREP.md` and `docs/GITOPS.md` for a complete breakdown of the architectural decisions, deployment instructions, and expected senior-level interview Q&A.
