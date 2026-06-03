# Migration to 0.13.0

## Introduced Pod Anti-Affinity Configuration

Version 0.13.0 introduces a new pod anti-affinity configuration that is **enabled by default** with soft rules (`enabled: true`, `required: false`).
This helps improve availability by distributing pods across different nodes in your Kubernetes cluster.

The new configuration is available for both SSR (server-side rendering) and nginx/cache deployments:

```yaml
podAntiAffinity:
  enabled: true
  required: false

cache:
  podAntiAffinity:
    enabled: true
    required: false
```

### Breaking Change for Custom Affinity Rules

> [!IMPORTANT]
> If you currently have custom `podAntiAffinity` rules defined within your `affinity` configuration, the new default setting will create a conflict.

The Helm chart merges the custom `affinity` configuration with the new `podAntiAffinity` template output. If both define `podAntiAffinity:` at the same level, **the chart's rules will overwrite your custom rules**.

#### Example of Affected Configuration

If your current configuration looks like this:

```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
            - key: app
              operator: In
              values:
                - my-custom-app
        topologyKey: "kubernetes.io/hostname"
```

This will conflict with the new default `podAntiAffinity.enabled: true` setting.

#### Migration Options

You have two options to resolve this:

**Option 1: Disable the Chart's Pod Anti-Affinity**

If you want to keep your existing custom anti-affinity rules as-is, disable the chart's built-in feature:

```yaml
podAntiAffinity:
  enabled: false

affinity:
  podAntiAffinity:
    # your existing custom rules
    requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector: ...
```

**Option 2: Use the Chart's Configuration**

If the chart's pod anti-affinity configuration meets your needs, remove your custom rules from `affinity` and configure the chart's options instead:

```yaml
podAntiAffinity:
  enabled: true
  required: true # or false for soft rules

affinity: {} # or other affinity rules (nodeAffinity, podAffinity, etc.)
```

### Non-Breaking Scenarios

The following configurations are **not affected** by this change:

- Custom `affinity` rules that **only** define `nodeAffinity` or `podAffinity` (without `podAntiAffinity`)
- Deployments without any custom `affinity` configuration
- Deployments that already had `podAntiAffinity.enabled` explicitly set to `false`

### Verifying Your Deployment

After upgrading to 0.13.0, you can verify the applied affinity rules by checking the deployed pods:

```bash
kubectl get deployment <release-name>-pwa-main -o yaml | grep -A 20 affinity
kubectl get deployment <release-name>-pwa-cache -o yaml | grep -A 20 affinity
```

Ensure the `podAntiAffinity` section matches your expectations and does not contain duplicate or conflicting rules.
