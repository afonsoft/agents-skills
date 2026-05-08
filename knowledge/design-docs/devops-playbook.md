# DevOps Playbook

This document contains patterns, best practices, and implementation guides for DevOps, CI/CD pipelines, and infrastructure automation.

## Overview

Comprehensive guide for building robust DevOps practices including CI/CD pipelines, infrastructure as code, container orchestration, and monitoring strategies.

## Quick Reference

| Practice | Purpose | Key Tools | Complexity |
|----------|---------|-----------|------------|
| **CI/CD Pipeline** | Automated testing & deployment | Jenkins, GitHub Actions, GitLab CI | Medium |
| **IaC** | Infrastructure management | Terraform, CloudFormation, Pulumi | Medium |
| **Container Orchestration** | Application deployment | Kubernetes, Docker Swarm | High |
| **Monitoring** | System observability | Prometheus, Grafana, ELK | Medium |
| **Security Scanning** | Vulnerability detection | SonarQube, Trivy, Snyk | Medium |

## CI/CD Pipeline Patterns

### Pattern 1: Multi-Stage Pipeline

- **When to use**: Complex applications requiring multiple validation stages
- **Implementation**: Build → Test → Security → Deploy
- **Code Example**:
```yaml
# .github/workflows/ci-cd.yml
name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

env:
  NODE_VERSION: '18'
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}
      image-digest: ${{ steps.build.outputs.digest }}
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run linting
      run: npm run lint
    
    - name: Run unit tests
      run: npm run test:unit
    
    - name: Generate coverage report
      run: npm run test:coverage
    
    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v3
    
    - name: Build application
      run: npm run build
    
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=sha,prefix={{branch}}-
    
    - name: Build and push Docker image
      id: build
      uses: docker/build-push-action@v5
      with:
        context: .
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max

  security-scan:
    runs-on: ubuntu-latest
    needs: build
    steps:
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: ${{ needs.build.outputs.image-tag }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  integration-tests:
    runs-on: ubuntu-latest
    needs: build
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run integration tests
      env:
        DATABASE_URL: postgresql://postgres:postgres@localhost:5432/testdb
      run: npm run test:integration

  deploy-staging:
    runs-on: ubuntu-latest
    needs: [build, security-scan, integration-tests]
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
    - name: Deploy to staging
      run: |
        echo "Deploying to staging environment"
        # Deployment logic here
        kubectl set image deployment/app app=${{ needs.build.outputs.image-tag }} -n staging

  deploy-production:
    runs-on: ubuntu-latest
    needs: [build, security-scan, integration-tests]
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Deploy to production
      run: |
        echo "Deploying to production environment"
        # Production deployment logic
        kubectl set image deployment/app app=${{ needs.build.outputs.image-tag }} -n production
```

- **Pros**: Automated quality gates, consistent deployments, fast feedback
- **Cons**: Pipeline complexity, maintenance overhead

### Pattern 2: Blue-Green Deployment

- **When to use**: Zero-downtime deployments, quick rollback capability
- **Implementation**: Parallel environments with traffic switching
- **Code Example**:
```bash
#!/bin/bash
# blue-green-deploy.sh

set -e

ENVIRONMENT=${1:-staging}
IMAGE_TAG=${2:-latest}
NAMESPACE=${3:-default}

BLUE_DEPLOYMENT="app-blue"
GREEN_DEPLOYMENT="app-green"
SERVICE="app-service"

echo "Starting blue-green deployment to $ENVIRONMENT with image $IMAGE_TAG"

# Determine which environment is currently active
ACTIVE_DEPLOYMENT=$(kubectl get service $SERVICE -n $NAMESPACE -o jsonpath='{.spec.selector.color}' 2>/dev/null || echo "blue")

if [ "$ACTIVE_DEPLOYMENT" = "blue" ]; then
    CURRENT_DEPLOYMENT=$BLUE_DEPLOYMENT
    NEW_DEPLOYMENT=$GREEN_DEPLOYMENT
    NEW_COLOR="green"
else
    CURRENT_DEPLOYMENT=$GREEN_DEPLOYMENT
    NEW_DEPLOYMENT=$BLUE_DEPLOYMENT
    NEW_COLOR="blue"
fi

echo "Current active deployment: $CURRENT_DEPLOYMENT"
echo "New deployment: $NEW_DEPLOYMENT (color: $NEW_COLOR)"

# Update the inactive deployment with new image
echo "Updating $NEW_DEPLOYMENT with new image"
kubectl set image deployment/$NEW_DEPLOYMENT app=$IMAGE_TAG -n $NAMESPACE

# Wait for the new deployment to be ready
echo "Waiting for $NEW_DEPLOYMENT to be ready..."
kubectl rollout status deployment/$NEW_DEPLOYMENT -n $NAMESPACE --timeout=300s

# Run health checks on the new deployment
echo "Running health checks on $NEW_DEPLOYMENT"
NEW_POD=$(kubectl get pods -n $NAMESPACE -l color=$NEW_COLOR -o jsonpath='{.items[0].metadata.name}')
kubectl exec $NEW_POD -n $NAMESPACE -- curl -f http://localhost:3000/health

# Switch traffic to the new deployment
echo "Switching traffic to $NEW_DEPLOYMENT"
kubectl patch service $SERVICE -n $NAMESPACE -p '{"spec":{"selector":{"color":"'$NEW_COLOR'"}}}'

# Wait for traffic switch to propagate
sleep 10

# Verify the switch was successful
echo "Verifying traffic switch"
for i in {1..5}; do
    if curl -f http://$SERVICE.$NAMESPACE.svc.cluster.local/health; then
        echo "Health check passed"
        break
    else
        echo "Health check failed, attempt $i/5"
        sleep 5
    fi
done

# Scale down the old deployment
echo "Scaling down $CURRENT_DEPLOYMENT"
kubectl scale deployment $CURRENT_DEPLOYMENT --replicas=0 -n $NAMESPACE

echo "Blue-green deployment completed successfully"
echo "Active deployment: $NEW_DEPLOYMENT"
```

- **Pros**: Zero downtime, instant rollback, testing in production
- **Cons**: Double resource requirements, complexity

## Infrastructure as Code Patterns

### Pattern 3: Terraform Module Structure

- **When to use**: Reusable infrastructure components, team collaboration
- **Implementation**: Modular Terraform with consistent structure
- **Code Example**:
```hcl
# modules/web-app/main.tf
variable "app_name" {
  type        = string
  description = "Name of the application"
}

variable "environment" {
  type        = string
  description = "Environment (dev, staging, prod)"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where resources will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs for load balancer"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "min_size" {
  type        = number
  description = "Minimum number of instances"
  default     = 2
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances"
  default     = 10
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances"
  default     = 2
}

# Security group
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.app_name}-${var.environment}-"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-sg"
    Environment = var.environment
  }
}

# Launch template
resource "aws_launch_template" "web_lt" {
  name_prefix   = "${var.app_name}-${var.environment}-"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(templatefile("${path.module}/user-data.sh", {
    app_name = var.app_name
  }))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.app_name}-${var.environment}"
      Environment = var.environment
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = var.desired_capacity
  max_size           = var.max_size
  min_size           = var.min_size
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.web_tg.arn]

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.app_name}-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

# Load Balancer
resource "aws_lb" "web_lb" {
  name               = "${var.app_name}-${var.environment}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.subnet_ids

  tags = {
    Name        = "${var.app_name}-${var.environment}-lb"
    Environment = var.environment
  }
}

# Target Group
resource "aws_lb_target_group" "web_tg" {
  name     = "${var.app_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "${var.app_name}-${var.environment}-tg"
    Environment = var.environment
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "web_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Outputs
output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.web_lb.dns_name
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.web_tg.arn
}
```

- **Pros**: Reusability, consistency, version control
- **Cons**: Learning curve, state management

### Pattern 4: Kubernetes Manifests with Helm

- **When to use**: Complex Kubernetes deployments, environment management
- **Implementation**: Helm charts with value overrides
- **Code Example**:
```yaml
# Chart.yaml
apiVersion: v2
name: web-app
description: A Helm chart for web application
type: application
version: 0.1.0
appVersion: "1.0.0"

# values.yaml
replicaCount: 2

image:
  repository: nginx
  pullPolicy: IfNotPresent
  tag: ""

service:
  type: ClusterIP
  port: 80

ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: chart-example.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi

autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80

# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "web-app.fullname" . }}
  labels:
    {{- include "web-app.labels" . | nindent 4 }}
spec:
  {{- if not .Values.autoscaling.enabled }}
  replicas: {{ .Values.replicaCount }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "web-app.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      {{- with .Values.podAnnotations }}
      annotations:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      labels:
        {{- include "web-app.selectorLabels" . | nindent 8 }}
    spec:
      {{- with .Values.imagePullSecrets }}
      imagePullSecrets:
        {{- toYaml . | nindent 8 }}
      {{- end }}
      securityContext:
        {{- toYaml .Values.podSecurityContext | nindent 8 }}
      containers:
        - name: {{ .Chart.Name }}
          securityContext:
            {{- toYaml .Values.securityContext | nindent 12 }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
          imagePullPolicy: {{ .Values.image.pullPolicy }}
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
          livenessProbe:
            httpGet:
              path: /
              port: http
          readinessProbe:
            httpGet:
              path: /
              port: http
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

- **Pros**: Environment management, templating, packaging
- **Cons**: Complexity, learning curve

## Container Orchestration

### Pattern 5: Kubernetes Multi-Environment Setup

- **When to use**: Multiple environments, consistent deployment strategy
- **Implementation**: Namespaces, ConfigMaps, Secrets management
- **Code Example**:
```yaml
# namespaces.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
  labels:
    environment: development
---
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    environment: staging
---
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    environment: production

# configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: development
data:
  DATABASE_URL: "postgresql://dev-user:dev-pass@postgres-dev:5432/devdb"
  LOG_LEVEL: "debug"
  FEATURE_FLAGS: "new-ui,experimental-api"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: staging
data:
  DATABASE_URL: "postgresql://staging-user:staging-pass@postgres-staging:5432/stagingdb"
  LOG_LEVEL: "info"
  FEATURE_FLAGS: "new-ui"
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
  namespace: production
data:
  DATABASE_URL: "postgresql://prod-user:prod-pass@postgres-prod:5432/proddb"
  LOG_LEVEL: "warn"
  FEATURE_FLAGS: ""

# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: development
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: myapp:latest
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: app-config
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: staging
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: myapp:latest
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: app-config
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-app
        image: myapp:latest
        ports:
        - containerPort: 3000
        envFrom:
        - configMapRef:
            name: app-config
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

- **Pros**: Environment isolation, resource management, scalability
- **Cons**: Operational complexity, resource overhead

## Monitoring & Observability

### Pattern 6: Prometheus + Grafana Stack

- **When to use**: Comprehensive monitoring, alerting, visualization
- **Implementation**: Prometheus for metrics, Grafana for dashboards
- **Code Example**:
```yaml
# prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

rule_files:
  - "alert_rules.yml"

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - alertmanager:9093

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
        action: keep
        regex: true
      - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_path]
        action: replace
        target_label: __metrics_path__
        regex: (.+)

  - job_name: 'node-exporter'
    kubernetes_sd_configs:
      - role: endpoints
    relabel_configs:
      - source_labels: [__meta_kubernetes_service_name]
        action: keep
        regex: node-exporter

# alert_rules.yml
groups:
  - name: application.rules
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_total{status=~"5.."}[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value }} errors per second"

      - alert: HighMemoryUsage
        expr: (container_memory_usage_bytes / container_spec_memory_limit_bytes) > 0.9
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: "High memory usage"
          description: "Memory usage is above 90%"

      - alert: PodCrashLooping
        expr: rate(kube_pod_container_status_restarts_total[15m]) > 0
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Pod is crash looping"
          description: "Pod {{ $labels.pod }} is restarting frequently"
```

- **Pros**: Rich metrics, flexible querying, alerting
- **Cons**: Storage requirements, complexity

## Security & Compliance

### Pattern 7: Security Scanning Pipeline

- **When to use**: Automated security validation, vulnerability detection
- **Implementation**: Multiple security tools integrated in CI/CD
- **Code Example**:
```yaml
# security-scan.yml
name: Security Scanning

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]
  schedule:
    - cron: '0 2 * * *'  # Daily at 2 AM

jobs:
  container-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Build Docker image
      run: docker build -t myapp:${{ github.sha }} .
    
    - name: Run Trivy vulnerability scanner
      uses: aquasecurity/trivy-action@master
      with:
        image-ref: myapp:${{ github.sha }}
        format: 'sarif'
        output: 'trivy-results.sarif'
    
    - name: Upload Trivy scan results
      uses: github/codeql-action/upload-sarif@v2
      with:
        sarif_file: 'trivy-results.sarif'

  code-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Run SonarCloud scan
      uses: SonarSource/sonarcloud-github-action@master
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        SONAR_TOKEN: ${{ secrets.SONAR_TOKEN }}

  dependency-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Run Snyk to check for vulnerabilities
      uses: snyk/actions/node@master
      env:
        SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
      with:
        args: --severity-threshold=high

  infrastructure-scan:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
    
    - name: Run tfsec
      uses: aquasecurity/tfsec-action@master
      with:
        args: './infrastructure'
```

- **Pros**: Automated security detection, compliance validation
- **Cons**: False positives, scanning time

## Best Practices

### CI/CD Best Practices
1. **Fast Feedback**: Keep pipeline stages short and parallel
2. **Fail Fast**: Fail early in the pipeline
3. **Immutable Artifacts**: Build once, deploy many times
4. **Environment Parity**: Keep environments consistent
5. **Automated Rollback**: Always have rollback capability

### Infrastructure Best Practices
1. **Version Control**: All infrastructure in version control
2. **Modular Design**: Reusable infrastructure components
3. **State Management**: Proper state file handling
4. **Security First**: Implement security from the start
5. **Cost Optimization**: Monitor and optimize resource usage

### Monitoring Best Practices
1. **Golden Signals**: Monitor latency, traffic, errors, saturation
2. **Structured Logging**: Use structured log formats
3. **Distributed Tracing**: Implement request tracing
4. **Alert Management**: Meaningful alerts with runbooks
5. **SLA/SLO Monitoring**: Track service level objectives

## Common Pitfalls

### Pipeline Pitfalls
- **Long Running Pipelines**: Slow feedback loops
- **Flaky Tests**: Unreliable test suites
- **Manual Interventions**: Too many manual steps
- **Poor Error Handling**: Unclear failure messages

### Infrastructure Pitfalls
- **Drift Detection**: Infrastructure vs code mismatch
- **State Conflicts**: Multiple state file modifications
- **Resource Leaks**: Unused resources not cleaned up
- **Security Oversights**: Missing security configurations

## Tools & Resources

### CI/CD Platforms
- **GitHub Actions**: Integrated with GitHub
- **GitLab CI**: Built-in GitLab feature
- **Jenkins**: Highly customizable
- **Azure DevOps**: Microsoft ecosystem
- **CircleCI**: Cloud-native CI/CD

### Infrastructure Tools
- **Terraform**: Multi-cloud IaC
- **Pulumi**: Code-based IaC
- **Ansible**: Configuration management
- **Packer**: Machine image creation
- **Vagrant**: Development environments

### Container Tools
- **Docker**: Container platform
- **Kubernetes**: Container orchestration
- **Helm**: Kubernetes package manager
- **Docker Compose**: Local development
- **Podman**: Docker alternative

### Monitoring Tools
- **Prometheus**: Metrics collection
- **Grafana**: Visualization
- **ELK Stack**: Log aggregation
- **Jaeger**: Distributed tracing
- **Datadog**: APM and monitoring

### Security Tools
- **SonarQube**: Code quality and security
- **Trivy**: Container vulnerability scanning
- **Snyk**: Dependency vulnerability scanning
- **tfsec**: Infrastructure security scanning
- **OWASP ZAP**: Web application security

This playbook provides comprehensive DevOps patterns and should be adapted to specific organizational requirements and constraints.
