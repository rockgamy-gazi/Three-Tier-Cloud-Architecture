# 🏗️ Three-Tier AWS Cloud Architecture — Vertical E-Commerce Platform

> **Production-grade, highly available 3-tier cloud infrastructure deployed on AWS using Terraform (Infrastructure as Code)**  
> Built as part of MSc Cloud Computing — University of East London (Module CN7026)

---

## 📐 Architecture Overview

This project provisions a fully functional, secure, and scalable **3-tier cloud architecture** on AWS for a vertical e-commerce platform. All infrastructure is defined and deployed using **Terraform (HCL)** — no manual console configuration.

The architecture separates concerns across three isolated tiers:

| Tier | Layer | AWS Services |
|------|-------|-------------|
| **Tier 1** | Presentation | Route 53, CloudFront (CDN), S3, AWS WAF |
| **Tier 2** | Application | EC2 (t3.micro), Auto Scaling Group, Application Load Balancer |
| **Tier 3** | Database | Amazon RDS (MySQL) Multi-AZ, ElastiCache (Redis) |

---

## 🗺️ Architecture Diagram

```
Users
  │
  ├── Route 53 (DNS)
  ├── CloudFront (CDN)
  ├── S3 (Static Assets)
  └── AWS WAF (Web Application Firewall)
          │
    ┌─────▼──────────────────────────────┐
    │     AWS Region: eu-west-2 (London)  │
    │     VPC: 10.0.0.0/16               │
    │                                     │
    │  ┌─────────────────────────────┐   │
    │  │  Application Load Balancer  │   │
    │  └──────────┬──────────────────┘   │
    │             │                       │
    │   ┌─────────▼──────────────┐       │
    │   │  AZ: eu-west-2a        │  AZ: eu-west-2b  │
    │   │  Public Subnet         │  Public Subnet    │
    │   │  10.0.1.0/24           │  10.0.2.0/24      │
    │   │  [NAT Gateway]         │  [NAT Gateway]    │
    │   │                        │                   │
    │   │  Private App Subnet    │  Private App Subnet│
    │   │  10.0.3.0/24           │  10.0.4.0/24      │
    │   │  [EC2 + Auto Scaling]  │  [EC2 + Auto Scaling]│
    │   │                        │                   │
    │   │  Private DB Subnet     │  Private DB Subnet │
    │   │  10.0.5.0/24           │  10.0.6.0/24      │
    │   │  [RDS Primary]         │  [RDS Standby]    │
    │   └────────────────────────┘                   │
    │                                                 │
    │  Security & Compliance: CloudWatch, CloudTrail, IAM │
    └─────────────────────────────────────────────────┘
```

---

## 📁 Repository Structure

```
Three-Tier-Cloud-Architecture/
│
├── provider.tf          # AWS provider configuration (region: eu-west-2)
├── variables.tf         # Input variables for parameterised deployment
├── VPC.tf               # VPC, subnets, Internet Gateway, NAT Gateway, route tables
├── Compute.tf           # EC2 instances, Launch Template, Auto Scaling Group
├── load_balancer.tf     # Application Load Balancer, Target Group, Listeners
├── database.tf          # RDS MySQL Multi-AZ, DB Subnet Group, ElastiCache
├── security_groups.tf   # Security Groups for each tier (ALB, App, DB)
└── .terraform.lock.hcl  # Terraform dependency lock file
```

---

## ☁️ AWS Services Used

### Networking
- **VPC** — Custom VPC with CIDR `10.0.0.0/16`
- **Subnets** — 6 subnets across 2 AZs: 2 public, 2 private (app), 2 private (DB)
- **Internet Gateway** — Enables public inbound/outbound traffic
- **NAT Gateway** — Outbound internet access for private subnets (e.g. payment gateway calls)
- **Route Tables** — Separate routing for public and private tiers

### Compute
- **EC2 (t3.micro)** — Application servers deployed in private subnets
- **Auto Scaling Group** — Automatically scales EC2 instances based on demand
- **Application Load Balancer (ALB)** — Distributes traffic across AZs; internet-facing

### Database
- **Amazon RDS (MySQL)** — Multi-AZ deployment with synchronous replication and automatic failover
- **Amazon ElastiCache (Redis)** — In-memory caching to reduce DB load under peak traffic

### Security
- **AWS WAF** — Protects against common web exploits and bot traffic
- **Security Groups** — Layered firewall rules per tier (ALB → App → DB)
- **AWS IAM** — Role-based access control for all services
- **Private Subnets** — Backend tiers have no direct internet exposure

### Content Delivery & DNS
- **Amazon Route 53** — DNS routing
- **Amazon CloudFront** — Global CDN for low-latency content delivery
- **Amazon S3** — Static asset hosting (product images, CSS, JS)

### Monitoring & Compliance
- **Amazon CloudWatch** — Metrics, alarms, and dashboards
- **AWS CloudTrail** — Audit logs and compliance tracking

---

## 🚀 Deployment

### Prerequisites
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.0
- AWS CLI configured with appropriate IAM credentials
- AWS account with permissions to create VPC, EC2, RDS, and related resources

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/rockgamy-gazi/Three-Tier-Cloud-Architecture.git
cd Three-Tier-Cloud-Architecture

# 2. Initialise Terraform
terraform init

# 3. Review the execution plan
terraform plan

# 4. Deploy the infrastructure
terraform apply

# 5. Destroy when done (to avoid charges)
terraform destroy
```

---

## 💰 Cost Estimate (eu-west-2 — London)

| Service | Configuration | Est. Monthly Cost |
|---------|--------------|-------------------|
| Amazon EC2 | 2x t3.micro + EBS (Auto Scaling) | ~$0.00 (Free Tier) |
| Amazon VPC | Custom VPC, Subnets, IGW, Route Tables | ~$19.50 |
| Application Load Balancer | 1x ALB across 2 AZs | ~$19.71 |
| NAT Gateway | 1x NAT (730hrs + data) | ~$35.77 |
| Amazon RDS (MySQL) | db.t3.micro Multi-AZ + Storage | ~$30.50 |
| Amazon S3 | Standard bucket (~10GB) | ~$0.24 |
| Amazon Route 53 | 1 Hosted Zone + DNS queries | ~$0.50 |
| **Total** | **Production Prototype Baseline** | **~$106.22/month** |

---

## 🔐 Security Design

- All application and database servers are deployed in **private subnets** — no direct internet access
- **NAT Gateway** provides controlled outbound access for private tier (e.g. payment gateway API calls via PayPal)
- **AWS WAF** filters malicious traffic before it reaches the load balancer
- **Security Groups** enforce least-privilege communication between tiers
- **Multi-AZ RDS** ensures data is never lost during an AZ failure

---

## 📚 References

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Amazon VPC User Guide](https://docs.aws.amazon.com/vpc/)
- [Amazon EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [Amazon RDS Documentation](https://docs.aws.amazon.com/rds/)
- Buyya, R., Broberg, J. and Goscinski, A. (2011) *Cloud Computing: Principles and Paradigms*. Wiley.

---

## 👨‍💻 Author

**Abdulla Gazi**  
MSc Cloud Computing — University of East London  
AWS Certified Cloud Practitioner  
[LinkedIn](https://linkedin.com/in/abdulla-gazi-166337243) | [GitHub](https://github.com/rockgamy-gazi)
