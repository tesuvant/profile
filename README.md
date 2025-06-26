# Cloud Resume Infrastructure

This repository hosts the infrastructure and automation code powering my personal online resume and portfolio, built with modern cloud-native tooling and DevOps practices.

## 🚀 Purpose

This project showcases how a personal website can be built and deployed using **Infrastructure as Code (IaC)**, **CI/CD**, and best practices from **FinOps**, **GitOps**, and **cloud automation** — all in a highly maintainable and cost-efficient way.

## 🔧 Tech Stack / Buzzwords Used

- **Terraform** – Infrastructure as Code to manage Azure resources.
- **GitHub Actions** – CI/CD pipeline for testing, building, and deploying.
- **GitOps** – All changes flow through git-based workflows and PRs.
- **FinOps** – Resource provisioning and cleanup with cost in mind.
- **Azure Cloud** – Hosting static website using Azure Storage and Azure CDN.
- **Codespaces** – Cloud-based development with a pre-configured dev environment.
- **AI** – AI-enhanced content generation and suggestions.
- **HTML/CSS Frameworks** – Lightweight styling from various CSS themes.
- **Secrets Management** with GitHub Secrets
- **Security** via Checkov and TFLint
- Obfuscation techniques for personal data (JavaScript)

## 🔁 Workflow

### Branch Strategy

- `main` – Protected branch. All deployments are triggered from here.
- `dev` – Development and feature work happen here. PRs are merged into `main`.


## 🔁 CI/CD Pipelines

This repository uses GitHub Actions to automate Terraform deployment using a two-branch strategy: `dev` for testing and validation, and `main` for production deployments.

---

### 🛠️ `dev` Branch Workflow – Terraform Dev Check

**Trigger Events**
- On every `push` to the `dev` branch.
- On every `pull_request` targeting `dev`.

**Jobs**
- ✅ **Checkout Code**
- 🔐 **Azure Login**  
- 🔍 **Terraform Format Check**  
  Ensures `.tf` files follow standard formatting using `terraform fmt -check`.

- 🔍 **TFLint**  
  Runs [TFLint](https://github.com/terraform-linters/tflint) to catch syntax errors, unused declarations, and best practice violations.

- 🛡️ **Checkov**  
  Executes [Checkov](https://www.checkov.io/) scans for Terraform security misconfigurations.

- ⚙️ **Terraform Init & Plan**  
  Initializes Terraform and validates the plan output without applying any changes.

**Purpose**  
To validate infrastructure code changes for correctness, style, and security before merging into `main`.

---

### 🚀 `main` Branch Workflow – Terraform Main Deployment

**Trigger Event**
- On every `push` to the `main` branch.

**Jobs**
- ✅ **Checkout Code**
- 🔐 **Azure Login**  

- ⚙️ **Terraform Init & Plan**  
  Prepares and displays the changes to be applied.

- 🚀 **Terraform Apply**  
  Automatically applies the infrastructure changes with `terraform apply -auto-approve`.

- 🧼 **Azure Logout**  
  Cleans up Azure credentials using `az logout`, even if previous steps fail.
