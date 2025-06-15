# Cloud Resume Infrastructure

This repository hosts the infrastructure and automation code powering my personal online resume and portfolio, built with modern cloud-native tooling and DevOps practices.

## 🚀 Purpose

This project showcases how a personal website can be built and deployed using **Infrastructure as Code (IaC)**, **CI/CD**, and best practices from **FinOps**, **GitOps**, and **cloud automation** — all in a highly maintainable and cost-efficient way.

## 🧠 Tech Stack / Buzzwords Used

- **Terraform** – Infrastructure as Code to manage Azure resources.
- **GitHub Actions** – CI/CD pipeline for testing, building, and deploying.
- **GitOps** – All changes flow through git-based workflows and PRs.
- **FinOps** – Resource provisioning and cleanup with cost in mind.
- **Azure Cloud** – Hosting static website using Azure Storage and Azure CDN.
- **Codespaces** – Cloud-based development with a pre-configured dev environment.
- **AI** – AI-enhanced content generation and suggestions.
- **HTML/CSS Frameworks** – Lightweight styling from various CSS themes.

## 🔁 Workflow

### Branch Strategy

- `main` – Protected branch. All deployments are triggered from here.
- `dev` – Development and feature work happen here. PRs are merged into `main`.

### CI/CD Pipeline

#### On Pull Requests to `main`:
- Lint and validate Terraform code.
- Run any defined tests or static checks.
- Requires passing checks before merge.

#### On Push to `main`:
- Run `terraform plan` and `apply` to deploy infrastructure.
- Upload updated static website content to Azure Blob Storage and purge Azure CDN cache.

## 🔧 Project Structure

