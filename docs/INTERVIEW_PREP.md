# Azure Data Platform Deployment & Senior Interview Preparation Guide

This guide provides a structured walkthrough for deploying the `azure-data-platform-iac` project, highlighting the architectural decisions and "Senior-level" insights expected during a Cloud/DevOps Engineer interview.

---

## 🏗️ Phase 0: Architectural Narrative (The "Big Picture")

Before touching the terminal, you must be able to explain **why** this specific stack was chosen.

**Senior Insight:** We use **Terragrunt** to solve the "DRY" (Don't Repeat Yourself) problem across multiple environments. It dynamically generates remote state and provider blocks, and cleanly handles dependency chains (e.g., Network -> KeyVault -> AKS).

### Architecture Highlights:
- **Zero Trust Networking:** Resources are isolated in a VNet with Default-Deny NSGs.
- **Identity-First Security:** No hardcoded passwords. We dynamically generate PostgreSQL credentials and store them in Key Vault. Pods authenticate via **Workload Identity**.
- **Push-Based GitOps:** Kubernetes state is managed entirely via our GitHub Actions pipeline running `kubectl apply` upon PR merge. This is an optimal "Stage 1" GitOps maturity model before introducing ArgoCD.

---

## 🛠️ Phase 1: Local Environment Setup

### Prerequisites
- **Azure CLI (`az`)**
- **OpenTofu** (or Terraform 1.5+)
- **Terragrunt (v1.0.0+)**
- **kubectl**

### ❓ Senior Interview Questions:
- **Q: Why OpenTofu over Terraform?** 
  - *A:* Open source, community-driven roadmap, drop-in replacement.
- **Q: How do you handle multi-subscription deployments?**
  - *A:* Use Terragrunt's `env.hcl` files to dynamically switch the `subscription_id` in the dynamically generated provider block.

---

## 🚀 Phase 2: Deploying Infrastructure

We deploy the `dev` stack explicitly using Terragrunt's dependency DAG.

```bash
cd infra/live/dev
terragrunt run --all init
terragrunt run --all apply
```

### ❓ Senior Interview Questions:
- **Q: How do you prevent "State Locking" issues?** 
  - *A:* Azure RM backend natively handles state locking using leases on the storage blob. 
- **Q: How do you handle secrets during the IaC phase?** 
  - *A:* We generate passwords via the `random_password` provider and write them straight to Key Vault. We never pass plain-text `inputs`.

---

## ☸️ Phase 3: Push-Based GitOps Bootstrapping

Once the infrastructure is up, the CI/CD pipeline takes over the Kubernetes configuration.

### The Push-Based Workflow
Currently, we rely on GitHub Actions (`.github/workflows/ci-cd.yml`). When code merges to `main`, Job 5 (`kubernetes-deploy`) automatically:
1. Logs into Azure via federated OIDC credentials.
2. Retrieves AKS credentials.
3. Runs `kubectl apply -f k8s/base/` to instantiate Namespaces, Quotas, and Network Policies.

### ❓ Senior Interview Questions:
- **Q: Why start with Push-Based GitOps over ArgoCD?** 
  - *A:* "It's an iterative maturity model. Early on, push-based pipelines using `kubectl apply` provide the core benefits of GitOps (auditability, code review) with zero cluster overhead and zero new tooling curves. Once the team matures, we migrate to ArgoCD for advanced 'self-healing' drift reconciliation."

---

## 🛡️ Phase 4: Observability & Security Persistence

### Step 1: Managed Identities
Ensure you can explain how a Pod in the `data-platform` namespace accesses ADLS.
- **Mechanism:** The Pod uses a `ServiceAccount` bound to an Azure Client ID. AKS OIDC issuer validates the token.

### Step 2: Continuous Security
- **Branch Protection:** Merges require `checkov` and `kubeval` to pass.

## 📝 Final Senior Interview "Checklist"

1.  **Blast Radius Reduction:** We separated network from compute via micro-states in Terragrunt.
2.  **Scalability:** Prod is simply an `env.hcl` override away from Dev.
3.  **Cost Management:** We use burstable SKUs (`Standard_B2ms`) for dev.
4.  **Auditability:** Every infra change is tracked via PRs.

**Good luck tomorrow! You've got this.**
