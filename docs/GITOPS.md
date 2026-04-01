# Push-Based GitOps

This repository utilizes a **Push-Based GitOps** methodology using GitHub Actions. Every base resource deployed to the cluster (namespaces, resource quotas, network policies, RBAC, workload identity) is managed declaratively from the `k8s/base/` directory.

## The Push-Based Workflow

All changes to the cluster must follow this workflow:

1.  **Create a PR:** Modify the `k8s/base/` YAML files (e.g., update a network policy).
2.  **CI Validation:** GitHub Actions runs `kubeval --strict` to validate the manifests before merge.
3.  **Merge:** Upon merge to `main`, GitHub Actions triggers the deployment pipeline.
4.  **Auto-Push:** The `kubernetes-deploy` job authenticates to Azure via OIDC, gets the AKS cluster credentials, and executes `kubectl apply -f k8s/base/`.

## Interview Preparation (GitOps Talking Points)

-   **Q: What is the difference between Push-Based GitOps and Pull-Based GitOps (ArgoCD/Flux)?**
    -   *A:* "In Push-Based GitOps, our CI/CD pipeline (GitHub Actions) pushes changes to the cluster using `kubectl apply`. The pipeline has cluster-admin authority. In Pull-Based GitOps, an agent (ArgoCD) runs *inside* the cluster, constantly polling the Git repository and pulling changes down. The CI pipeline never touches the cluster."
    
-   **Q: Why choose Push-Based GitOps for this platform as a Stage 1 strategy?**
    -   *A:* "Push-Based GitOps is the perfect initial step on the GitOps maturity curve. It offers the core benefits of GitOps — version-controlled infra, automated deployments, and PR-driven workflows — without the operational overhead of managing a complex tool like ArgoCD or dealing with custom resource definitions (CRDs)."

-   **Q: When would you migrate this platform to ArgoCD?**
    -   *A:* "We transition to ArgoCD when we hit limitations in the Push-based model. Specifically, when we need **Automated Drift Reconciliation**. If a rogue user manually deletes a Namespace via the CLI, a Push-pipeline won't fix it until the *next* time someone merges code. ArgoCD detects the drift and recreates it instantly via its 'Self-Heal' loop."

-   **Q: How do you handle application deployments (like Airflow or Kafka) in this model?**
    -   *A:* "Since these are Helm charts, we would add standard `helm upgrade --install` steps into our GitHub Actions pipeline, right after the base manifests are applied. This explicitly codifies the application layer in our pipeline."
