---
name: k8s-devops
description: Kubernetes and Helm expertise for container orchestration, chart development, GitOps workflows, troubleshooting, and cloud-native best practices
---

## Kubernetes & Helm Engineering

Load this skill when working on Kubernetes manifests, Helm charts, or cloud-native infrastructure.

## Kubernetes Architecture & Operations

### Workload Types
- **Deployment**: Stateless apps with rolling updates (most common)
- **StatefulSet**: Stateful apps needing stable network identity and persistent storage
- **DaemonSet**: One pod per node (log collectors, monitoring agents)
- **Job / CronJob**: One-off or scheduled batch tasks
- **Custom Resources (CRDs)**: Extend the API with domain-specific types + Operators

### Essential Resource Patterns
- Always set **resource requests and limits** -- requests for scheduling, limits for protection
- Always include **liveness and readiness probes** -- prevent routing to unhealthy pods
- Use **Pod Disruption Budgets** for availability during upgrades
- Set **security contexts**: `runAsNonRoot: true`, `readOnlyRootFilesystem: true`, drop capabilities
- Use **`topologySpreadConstraints`** or **pod anti-affinity** for high availability

### Networking
- **Service types**: ClusterIP (internal), NodePort (dev/debug), LoadBalancer (cloud), ExternalName (CNAME alias)
- **Ingress**: Use ingress controllers (nginx, traefik, istio gateway) for HTTP routing, TLS termination
- **NetworkPolicies**: Default-deny ingress/egress, then allow specific flows -- treat as firewall rules
- **Service mesh** (Istio, Linkerd): For mTLS, traffic splitting, observability -- adds complexity, use only when needed

### Storage
- **PersistentVolumeClaims**: Use StorageClasses for dynamic provisioning
- **CSI drivers**: For cloud-native storage (EBS, GCE PD, Azure Disk)
- **emptyDir**: For scratch space (lost on pod restart)
- **ConfigMaps/Secrets**: For config injection; Secrets are base64-encoded, not encrypted -- use external secrets operators for production

## Helm Chart Development

### Chart Structure
```
mychart/
  Chart.yaml          # Metadata, version, dependencies
  values.yaml         # Default values with comments
  values.schema.json  # JSON Schema for values validation
  templates/
    _helpers.tpl      # Shared template definitions
    deployment.yaml
    service.yaml
    ingress.yaml
    hpa.yaml
    NOTES.txt         # Post-install message
  charts/             # Subcharts (dependencies)
  tests/              # Helm test pods
```

### Templating Best Practices
- **`_helpers.tpl`**: Define `chart.name`, `chart.fullname`, `chart.labels` as reusable templates
- **`values.yaml`**: Comment every value; use sensible defaults; validate with JSON Schema
- **Conditional resources**: `{{- if .Values.ingress.enabled }}` for optional components
- **Resource naming**: Use `{{ include "chart.fullname" . }}` consistently
- **Labels**: Always include `app.kubernetes.io/name`, `app.kubernetes.io/instance`, `app.kubernetes.io/version`

### Helm Hooks
- `pre-install` / `post-install`: DB migrations, seed data
- `pre-upgrade` / `post-upgrade`: Schema migrations, cache warming
- `pre-delete`: Backup before teardown
- **Hook weight**: Controls execution order within same hook type
- **Hook delete policy**: `before-hook-creation` to clean up old hook jobs

### Dependencies
```yaml
# Chart.yaml
dependencies:
  - name: postgresql
    version: "~13.0"
    repository: "https://charts.bitnami.com/bitnami"
    condition: postgresql.enabled   # Toggle dependency via values
```

## GitOps Workflows

### ArgoCD / Flux
- **App-of-Apps** pattern: One ArgoCD Application manages other Applications
- **Helm values per environment**: Use overlays or separate values files (`values-prod.yaml`)
- **Sync policies**: Auto-sync for dev/staging, manual sync for production
- **Drift detection**: Alert on out-of-band changes, auto-correct or report
- **Sealed Secrets** or **External Secrets Operator** for secret management in Git

## Cloud-Native Practices

### Observability Stack
- **Prometheus + Grafana**: Metrics collection, dashboards, alerting
- **Jaeger / Tempo**: Distributed tracing
- **Loki**: Log aggregation (pairs with Grafana)
- **ServiceMonitor CRDs**: Auto-discover metrics endpoints via labels

### Progressive Delivery
- **Rolling update**: Default strategy, controlled by `maxSurge` and `maxUnavailable`
- **Blue-green**: Two full deployments, switch traffic via Service selector
- **Canary**: Gradual traffic shifting via Istio VirtualService or Argo Rollouts
- **Argo Rollouts**: Advanced deployment strategies with analysis and automatic rollback

### Resource Optimization
- **HPA**: Scale on CPU/memory or custom metrics
- **VPA**: Right-size requests automatically (use in recommendation mode first)
- **Cluster Autoscaler / Karpenter**: Scale nodes based on pending pod demand
- **Resource quotas**: Per-namespace limits to prevent noisy neighbors
- **LimitRanges**: Default requests/limits for pods that don't specify them

## Troubleshooting Methodology

1. **Gather Information**: `kubectl describe pod/svc/node`, `kubectl logs`, `kubectl events`
2. **Layer-by-Layer**: Work through compute -> networking -> storage -> config
3. **Common Commands**:
   ```bash
   kubectl get pods -o wide                    # Pod status and node placement
   kubectl describe pod <name>                 # Events, conditions, probe status
   kubectl logs <pod> -c <container> --previous  # Logs from crashed container
   kubectl exec -it <pod> -- /bin/sh           # Shell into running container
   kubectl port-forward svc/<name> 8080:80     # Local access to cluster service
   kubectl top pods                            # CPU/memory usage
   kubectl get events --sort-by=.lastTimestamp  # Recent cluster events
   ```
4. **Root Cause Analysis**: Explain *why* the issue occurs, not just the fix
5. **Prevention**: Suggest monitoring rules, probes, or resource changes to prevent recurrence

## Security

- **Pod Security Standards**: Enforce `restricted` profile via PodSecurity admission
- **RBAC**: Least privilege -- separate ServiceAccounts per workload, namespace-scoped roles
- **Network Policies**: Default deny, explicit allow per service communication path
- **Image security**: Pull from trusted registries, pin image digests, scan with trivy/grype
- **Secrets**: Never in plain YAML -- use Sealed Secrets, External Secrets, or Vault

## YAML Standards

- 2-space indentation, consistent formatting
- Include comments explaining non-obvious configurations
- Resource limits, health checks, and security contexts on every workload by default
- Semantic versioning for chart versions
- Follow Kubernetes naming conventions (lowercase, hyphens, max 63 chars)

## When to Use This Skill

- Writing or reviewing Kubernetes manifests or Helm charts
- Designing deployment strategies (rolling, canary, blue-green)
- Troubleshooting pod failures, networking issues, or storage problems
- Setting up GitOps workflows with ArgoCD/Flux
- Configuring monitoring, scaling, or security policies
