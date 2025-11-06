# Talos Discovery Service

A containerized deployment of the [Talos Discovery Service](https://github.com/mpepping/discovery-service) with a Helm chart for Kubernetes.

> [!NOTE]
> This project includes <https://github.com/mpepping/discovery-service> which is a rewrite of the original Talos [Discovery Service](https://github.com/siderolabs/discovery-service). It is not affiliated with or endorsed by the Talos Linux project.

## Overview

The Discovery Service provides cluster membership and KubeSpan peer information for Talos Linux clusters. This repository packages the service into a container image and provides a Helm chart for easy deployment.

## Building the Container Image

Build the Docker image:

```bash
docker build -t ghcr.io/mpepping/talos-discovery-service:latest .
```

The Dockerfile uses a multi-stage build:

- **Build stage**: Clones the discovery-service repository and compiles the Go binary
- **Runtime stage**: Creates a minimal Alpine-based image with the binary

## Running the Container

Run the container locally:

```bash
docker run -p 3000:3000 -p 3001:3001 ghcr.io/mpepping/talos-discovery-service:latest
```

The service exposes two ports:

- **3000**: gRPC API
- **3001**: HTTP API

## Deploying with Helm

### Installation

Deploy the chart from the local directory:

```bash
helm install discovery-service ./chart
```

Or install from the OCI registry:

```bash
helm install discovery-service oci://ghcr.io/mpepping/helm-talos-discovery-service --version 1.0.0
```

### Configuration

Key configuration options in `chart/values.yaml`:

```yaml
replicaCount: 2 # Number of replicas

image:
  repository: ghcr.io/mpepping/talos-discovery-service
  tag: "latest"

service:
  type: ClusterIP
  grpcPort: 3000
  httpPort: 3001

ingress:
  enabled: false # Enable ingress
  className: ""
  hosts:
    - host: discovery.example.com
      paths:
        - path: /
          pathType: Prefix
          port: 3001

resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Example: Enable Ingress

Create a `custom-values.yaml`:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: discovery.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
          port: 3001
  tls:
    - secretName: discovery-tls
      hosts:
        - discovery.yourdomain.com
```

Deploy with custom values:

```bash
helm install discovery-service ./chart -f custom-values.yaml
```

## Upgrading

From local chart:

```bash
helm upgrade discovery-service ./chart
```

From OCI registry:

```bash
helm upgrade discovery-service oci://ghcr.io/mpepping/helm-talos-discovery-service --version 1.0.0
```

## Uninstalling

```bash
helm uninstall discovery-service
```

## Configure Talos to Use Your Instance

Update your Talos machine configuration to point to your custom discovery service endpoint:

```yaml
cluster:
  discovery:
    enabled: true
    registries:
      service:
        endpoint: https://your-discovery-service.example.com
```

To disable the default public service:

```yaml
cluster:
  discovery:
    enabled: true
    registries:
      service:
        disabled: true
```

## Service Architecture

- **Stateless**: All data is ephemeral and stored in memory
- **TTL**: Node information expires after 30 minutes without updates
- **Security**: Operates on encrypted data blobs without access to encryption keys

## Additional Resources

- [Talos Discovery Service GitHub](https://github.com/mpepping/discovery-service)
- [Talos Linux Documentation](https://www.talos.dev/)
