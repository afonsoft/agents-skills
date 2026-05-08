# Cloud Platforms Guide

This document contains patterns, best practices, and implementation guides for major cloud platforms and multi-cloud strategies.

## Overview

Comprehensive guide for AWS, Azure, Google Cloud development patterns, cost optimization, and cloud security compliance.

## Quick Reference

| Platform | Best For | Key Services | Complexity |
|----------|----------|--------------|------------|
| **AWS** | Enterprise scale | Lambda, EC2, S3, RDS | Medium |
| **Azure** | Microsoft integration | Functions, App Service, Cosmos DB | Medium |
| **GCP** | Data/AI workloads | Cloud Functions, GKE, BigQuery | Medium |
| **Multi-cloud** | Vendor diversity | Terraform, Kubernetes | High |

## AWS Patterns & Best Practices

### Pattern 1: Serverless Architecture

- **When to use**: Event-driven workloads, variable traffic, cost optimization
- **Implementation**: Lambda + API Gateway + DynamoDB/S3
- **Code Example**:
```yaml
# serverless.yml
service: user-service

provider:
  name: aws
  runtime: nodejs18.x
  region: us-east-1

functions:
  createUser:
    handler: src/users.create
    events:
      - http:
          path: users
          method: post
    environment:
      TABLE_NAME: ${self:custom.tableName}

resources:
  Resources:
    UsersTable:
      Type: AWS::DynamoDB::Table
      Properties:
        TableName: ${self:custom.tableName}
        AttributeDefinitions:
          - AttributeName: id
            AttributeType: S
        KeySchema:
          - AttributeName: id
            KeyType: HASH
        BillingMode: PAY_PER_REQUEST
```

- **Pros**: Cost effective, auto-scaling, no server management
- **Cons**: Cold starts, execution limits, vendor lock-in

### Pattern 2: Event-Driven Architecture

- **When to use**: Microservices, data pipelines, async processing
- **Implementation**: EventBridge + SNS + SQS + Lambda
- **Code Example**:
```python
import json
import boto3

def lambda_handler(event, context):
    # Process event
    for record in event['Records']:
        message = json.loads(record['body'])
        
        # Business logic
        result = process_order(message)
        
        # Publish result event
        event_bridge = boto3.client('events')
        event_bridge.put_events(
            Entries=[{
                'Source': 'com.myapp.orders',
                'DetailType': 'OrderProcessed',
                'Detail': json.dumps(result)
            }]
        )
    
    return {'statusCode': 200}
```

- **Pros**: Loose coupling, scalability, resilience
- **Cons**: Complexity, debugging challenges, eventual consistency

### Pattern 3: Infrastructure as Code

- **When to use**: Reproducible environments, compliance, team collaboration
- **Implementation**: CloudFormation or CDK
- **Code Example**:
```python
# CDK Stack
from aws_cdk import (
    Stack,
    aws_lambda as _lambda,
    aws_apigateway as apigw,
    aws_dynamodb as dynamodb
)

class UserServiceStack(Stack):
    def __init__(self, scope, id, **kwargs):
        super().__init__(scope, id, **kwargs)
        
        # DynamoDB table
        table = dynamodb.Table(
            self, "UsersTable",
            partition_key=dynamodb.Attribute(
                name="id", type=dynamodb.AttributeType.STRING
            ),
            billing_mode=dynamodb.BillingMode.PAY_PER_REQUEST
        )
        
        # Lambda function
        handler = _lambda.Function(
            self, "UserHandler",
            runtime=_lambda.Runtime.NODEJS_18_X,
            code=_lambda.Code.from_asset("lambda"),
            handler="users.handler",
            environment=dict(TABLE_NAME=table.table_name)
        )
        
        # API Gateway
        api = apigw.LambdaRestApi(
            self, "UserApi",
            handler=handler,
            proxy=True
        )
        
        # Grant permissions
        table.grant_read_write_data(handler)
```

- **Pros**: Version control, repeatability, documentation
- **Cons**: Learning curve, state management complexity

## Azure Patterns & Best Practices

### Pattern 1: PaaS Web Application

- **When to use**: Web applications, APIs, rapid development
- **Implementation**: App Service + Azure SQL + Application Insights
- **Code Example**:
```json
{
  "type": "Microsoft.Web/sites",
  "apiVersion": "2022-03-01",
  "name": "[parameters('siteName')]",
  "location": "[resourceGroup().location]",
  "properties": {
    "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', parameters('hostingPlanName'))]",
    "siteConfig": {
      "appSettings": [
        {
          "name": "APPLICATIONINSIGHTS_CONNECTION_STRING",
          "value": "[reference('microsoft.insights/components/webappname', '2015-05-01').ConnectionString]"
        }
      ]
    }
  }
}
```

- **Pros**: Managed platform, integrated services, easy scaling
- **Cons**: Vendor lock-in, less control than IaaS

### Pattern 2: Microservices with AKS

- **When to use**: Complex applications, container orchestration
- **Implementation**: Azure Kubernetes Service + Azure Container Registry
- **Code Example**:
```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
spec:
  replicas: 3
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: user-service
        image: myregistry.azurecr.io/user-service:latest
        ports:
        - containerPort: 80
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-secret
              key: url
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
spec:
  selector:
    app: user-service
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

- **Pros**: Container orchestration, scalability, portability
- **Cons**: Complexity, operational overhead

## Google Cloud Platform Patterns

### Pattern 1: Data Processing Pipeline

- **When to use**: Big data analytics, ETL, machine learning
- **Implementation**: Cloud Functions + BigQuery + Dataflow
- **Code Example**:
```python
# Cloud Function for data transformation
def process_data(event, context):
    """Triggered by a change to a Cloud Storage bucket."""
    import pandas as pd
    from google.cloud import bigquery
    
    # Read data from Cloud Storage
    client = storage.Client()
    bucket = client.bucket(event['bucket'])
    blob = bucket.blob(event['name'])
    data = blob.download_as_string()
    
    # Transform data
    df = pd.read_csv(data)
    transformed_df = transform_data(df)
    
    # Load to BigQuery
    bq_client = bigquery.Client()
    table_id = 'my-project.my_dataset.my_table'
    
    job = bq_client.load_table_from_dataframe(
        transformed_df, table_id
    )
    job.result()
```

- **Pros**: Scalable data processing, integrated ML capabilities
- **Cons**: Cost at scale, learning curve

### Pattern 2: ML Model Deployment

- **When to use**: ML model serving, predictions at scale
- **Implementation**: Vertex AI + Cloud Storage + Cloud Functions
- **Code Example**:
```python
# Vertex AI model deployment
from google.cloud import aiplatform

def deploy_model():
    aiplatform.init(project='my-project', location='us-central1')
    
    model = aiplatform.Model.upload(
        display_name="my-model",
        artifact_uri="gs://my-bucket/model-artifacts/",
        serving_container_image_uri="us-docker.pkg.dev/vertex-ai/prediction/tf2-cpu.2-8:latest"
    )
    
    endpoint = model.deploy(
        machine_type="n1-standard-4",
        min_replica_count=1,
        max_replica_count=5
    )
    
    return endpoint
```

- **Pros**: Managed ML platform, auto-scaling, monitoring
- **Cons**: Platform-specific, cost considerations

## Multi-Cloud Strategies

### Pattern 1: Terraform Multi-Cloud

- **When to use**: Vendor diversity, cost optimization, resilience
- **Implementation**: Terraform modules + workspaces
- **Code Example**:
```hcl
# main.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

# AWS resources
module "aws_webapp" {
  source = "./modules/aws-webapp"
  environment = var.environment
}

# Azure resources
module "azure_webapp" {
  source = "./modules/azure-webapp"
  environment = var.environment
}
```

- **Pros**: Vendor independence, cost optimization, resilience
- **Cons**: Complexity, skill requirements, integration challenges

## Cost Optimization Strategies

### 1. Rightsizing
- Monitor resource utilization
- Use appropriate instance types
- Implement auto-scaling
- Schedule non-production resources

### 2. Storage Optimization
- Use appropriate storage tiers
- Implement lifecycle policies
- Compress and deduplicate data
- Clean up unused resources

### 3. Network Cost Management
- Use CDNs for content delivery
- Optimize data transfer
- Choose right regions
- Implement caching strategies

### 4. Serverless Optimization
- Optimize function memory/cold starts
- Use provisioned concurrency
- Implement efficient code
- Monitor execution times

## Security & Compliance

### Security Best Practices
- Implement IAM least privilege
- Use encryption at rest and in transit
- Enable security monitoring
- Regular security audits
- Network segmentation

### Compliance Frameworks
- **SOC 2**: Security controls
- **ISO 27001**: Information security management
- **GDPR**: Data protection
- **HIPAA**: Healthcare data
- **PCI DSS**: Payment card industry

### Security Implementation Example
```yaml
# Security Group Rules
Resources:
  WebSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: "Security group for web servers"
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 80
          ToPort: 80
          CidrIp: 0.0.0.0/0
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 0.0.0.0/0
      SecurityGroupEgress:
        - IpProtocol: -1
          CidrIp: 0.0.0.0/0
```

## Monitoring & Observability

### Key Metrics to Monitor
- Resource utilization
- Application performance
- Error rates
- Cost metrics
- Security events

### Monitoring Tools
- **AWS**: CloudWatch, X-Ray
- **Azure**: Monitor, Application Insights
- **GCP**: Cloud Monitoring, Cloud Trace
- **Multi-cloud**: Datadog, New Relic

### Alerting Strategy
```yaml
# CloudWatch Alarm
Resources:
  HighCPUAlarm:
    Type: AWS::CloudWatch::Alarm
    Properties:
      AlarmName: "High CPU Utilization"
      AlarmDescription: "CPU utilization is above 80%"
      MetricName: CPUUtilization
      Namespace: AWS/EC2
      Statistic: Average
      Period: 300
      EvaluationPeriods: 2
      Threshold: 80
      ComparisonOperator: GreaterThanThreshold
      AlarmActions:
        - !Ref SNSTopicArn
```

## Disaster Recovery & Backup

### Backup Strategies
- **3-2-1 Rule**: 3 copies, 2 media, 1 offsite
- Automated backups
- Cross-region replication
- Regular restore testing
- Version retention policies

### Disaster Recovery Patterns
- **Pilot Light**: Minimal resources always running
- **Warm Standby**: Scaled-down version always available
- **Hot Standby**: Full replica always running
- **Multi-site**: Active-active across regions

## Migration Strategies

### Migration Approaches
1. **Rehost**: Lift and shift
2. **Replatform**: Lift and reshape
3. **Repurchase**: Drop and shop
4. **Refactor**: Re-architect
5. **Retire**: Decommission
6. **Retain**: Keep on-premises

### Migration Framework
```python
class CloudMigrationFramework:
    def __init__(self):
        self.phases = [
            'assess',
            'mobilize',
            'migrate',
            'optimize',
            'govern'
        ]
    
    def assess_workloads(self):
        """Analyze current infrastructure"""
        return {
            'applications': self.inventory_apps(),
            'dependencies': self.map_dependencies(),
            'costs': self.calculate_tco(),
            'risks': self.assess_risks()
        }
    
    def plan_migration(self, assessment):
        """Create migration plan"""
        return {
            'timeline': self.create_timeline(),
            'resources': self.allocate_resources(),
            'risks': self.mitigation_plan(),
            'success_criteria': self.define_metrics()
        }
```

## Tools & Resources

### Infrastructure as Code
- **Terraform**: Multi-cloud IaC
- **Pulumi**: Code-based IaC
- **AWS CDK**: AWS-specific framework
- **Azure ARM**: Azure templates
- **GCP Deployment Manager**: Google Cloud templates

### DevOps Tools
- **Jenkins**: CI/CD pipelines
- **GitLab CI**: Integrated CI/CD
- **GitHub Actions**: GitHub integration
- **Azure DevOps**: Microsoft ecosystem
- **Google Cloud Build**: GCP integration

### Monitoring & Security
- **Datadog**: Multi-cloud monitoring
- **Splunk**: Log analysis
- **CrowdStrike**: Security monitoring
- **Qualys**: Vulnerability management
- **Tenable**: Security scanning

This guide provides comprehensive patterns for cloud development across major platforms and should be adapted to specific organizational requirements and constraints.
