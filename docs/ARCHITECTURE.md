# Architecture and Workflow

## Goals
- Establish a secure, modular Azure data platform
- Support Infrastructure as Code and GitOps via Terragrunt
- Manage AKS Namespaces for multi-team tenancy
- Protect credentials with Azure KeyVault
- Ensure DevSecOps with Checkov in CI

## Azure Services
- **ADLS Gen2**: storage account with hierarchical namespace
- **PostgreSQL Flexible Server**: private endpoint + no public access
- **KeyVault**: key management, secrets and access policies
- **Networking**: VNet/Subnet, NSG, private endpoints

## Kubernetes
- Use existing centrally managed AKS for TE-TC
- Define `namespace` resources and RBAC in `k8s/` (not yet created)
- Use ArgoCD/Flux (GitOps) to sync k8s manifests from Git repo

### Push-Based GitOps Workflow

Adopt Push-Based GitOps to operate Kubernetes workloads using typical CI/CD pipelines (GitHub Actions). Key points:

- **Repository as source-of-truth:** Keep all declarative Kubernetes manifests in the `k8s/base/` directory. Any change to cluster state must come from git commits/PRs.
- **Pull request-based change control:** Use PRs for changes. CI runs linters and `kubeval` checks. Only merge after approvals.
- **Pipeline Execution:** Upon merge, GitHub Actions authenticates against Azure via OIDC (no stored secrets) and executes `kubectl apply` directly against the cluster.
- **Secrets management:** Never store plaintext secrets in git. Use Workload Identity (OIDC) to federate pod permissions directly to Azure AD, rendering passwords obsolete.

This CI/CD based model gives repeatable, auditable deployments and acts as the perfect foundational stepping stone before moving up the maturity curve to Pull-Based GitOps (ArgoCD).

## Maintenance
- Use Terragrunt in each environment folder for drift detection
- Keep state in Azure Storage (remote state backend)
- Rotate secrets in KeyVault and access via managed identities

## Best practices
- Separate `dev/prod` configs
- Minimal privileges for service principals
- Enable diagnostics for ADLS and PostgreSQL
- `checkov` and `terragrunt validate` on every PR
