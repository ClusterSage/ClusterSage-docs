# Fluent Bit

ClusterWatch uses Fluent Bit as a DaemonSet to collect pod logs from every node.

## Configuration

The chart tails `/var/log/containers/*.log`, parses CRI logs, enriches with Kubernetes metadata, and sends JSON over HTTP to the local collector Service at `/logs`.

Mounted host paths:

- `/var/log`
- `/var/log/containers`
- `/var/lib/docker/containers` when present

## Defaults

- Memory buffer limit: `10MB`.
- Filesystem buffering: `/buffers` emptyDir.
- Retry limit: `False`, so transient backend outages keep retrying through the collector path.
- Agent namespace logs excluded by default with `fluentbit.excludeAgentNamespace: true`.

## Verify

```bash
kubectl get daemonset clusterwatch-fluent-bit -n clusterwatch-agent
kubectl logs -n clusterwatch-agent -l app.kubernetes.io/component=fluent-bit
kubectl describe configmap clusterwatch-fluent-bit -n clusterwatch-agent
```
