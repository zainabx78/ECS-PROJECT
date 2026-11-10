# ECSv1 Acceptance Criteria (Bare Minimum)

> **Note:** If any of these are missing, you'll be asked to complete them before review.

---

## 1. Repository

Your repo structure must contain:

- [ ] A proper `README.md`
- [ ] App source code
- [ ] Your own Dockerfile (not copied from elsewhere)
- [ ] Terraform code using modules
- [ ] CI/CD pipeline definitions

---

## 2. README

Your README must include:

- [ ] Project Overview
- [ ] App Demo (with HTTPS visible in the browser)
- [ ] Local Setup
- [ ] Architecture Diagram (must show different scopes, VPC, subnets, ALB, ECS, ECR, ACM, etc.)
- [ ] Project Structure
- [ ] Pipeline Screenshots (all pipelines should show as working)

---

## 3. Infrastructure

Most resources must be created using Terraform (with some exceptions).

### Minimum Requirements

- [ ] Custom VPC
- [ ] Subnets
- [ ] ECS (Fargate or EC2)
- [ ] Application Load Balancer
- [ ] HTTPS using ACM
- [ ] Certificate created automatically via Terraform
- [ ] Terraform modules (no single giant file)

### Terraform State (Mandatory)

- [ ] Remote backend (S3)
- [ ] State locking through either:
  - S3 native locking (best and easier), **or**
  - DynamoDB (deprecated)

> ⚠️ **No backend = sent back.**

---

## 4. CI/CD

**Minimum: 3 pipelines**

| Pipeline | Purpose | Required? |
|---|---|---|
| Application Pipeline | Pushes image to ECR | ✅ Required |
| Terraform Pipeline | Deploys infrastructure | ✅ Required |
| Terraform Destroy Pipeline | Destroys infrastructure | ✅ Required |
| Terraform Plan Pipeline | Validation, linting, security checks, `terraform plan` | ⭐ Recommended |

> If any of the required pipelines are missing, you'll be asked to add them first.

---

## 5. Fail Checklist

You will be sent back if you have any of the following:

- ❌ No README or a weak README
- ❌ No architecture diagram
- ❌ Hardcoded secrets
- ❌ No Terraform backend
- ❌ No state locking
- ❌ No domain
- ❌ No modules
- ❌ No HTTPS
- ❌ No pipelines / failed pipelines
- ❌ Copied Dockerfile
- ❌ Obvious AI-generated content




improvementS: 

- Need to remove the password from the dockerfile. and secure it using a .env file.. 