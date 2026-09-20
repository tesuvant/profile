# Cloud Resume Infrastructure

This repository hosts the infrastructure and automation code powering my personal online resume and portfolio, built with modern cloud-native tooling and DevOps practices.

## 🚀 Purpose

This project showcases how a personal website can be built and deployed using **Infrastructure as Code (IaC)**, **CI/CD**, and best practices from **FinOps**, **GitOps**, and **cloud automation** — all in a highly maintainable and cost-efficient way.

## 🔧 Tech Stack / Buzzwords Used

- **Terraform** – Infrastructure as Code to manage Azure resources.
- **GitHub Actions** – CI/CD pipeline for testing, building, and deploying.
- **GitOps** – All changes flow through git-based workflows and PRs.
- **FinOps** – Resource provisioning and cleanup with cost in mind.
- **Azure Cloud** – Hosting static website using Azure Static Web Apps (Free plan).
- **Codespaces** – Cloud-based development with a pre-configured dev environment.
- **AI** – AI-enhanced content generation and suggestions.
- **HTML/CSS Frameworks** – Lightweight styling from various CSS themes.
- **Secrets Management** with GitHub Secrets
- **Security** via Checkov and TFLint
- Obfuscation techniques for personal data (JavaScript)

## 🔁 Workflow

## 🌐 Custom domain and HTTPS

The site is hosted by Azure Static Web Apps on its Free plan. Azure provisions and
renews HTTPS certificates for both `<custom-domain>` and `www.<custom-domain>`
automatically; no purchased certificate is required and HTTP should redirect to
HTTPS.

Delegate the domain to the Azure DNS name servers shown for the Terraform
managed zone at your domain registrar. Terraform creates the Azure DNS zone,
the apex alias record, the apex validation TXT record, and the `www` CNAME
record; registrar configuration and name-server delegation remain outside
Terraform.

```text
Host: @
Target: the Static Web App resource (Azure DNS alias)

Host: www
Target: <the Static Web App default hostname>
```

Terraform configures both `<custom-domain>` and `www.<custom-domain>` in Azure.
The apex hostname uses TXT-token validation and the `www` hostname uses CNAME
validation. After DNS is visible, Azure provisions the managed HTTPS
certificates. If the DNS zone, records, or custom domains already exist, import
the existing resources before applying:

```bash
terraform import azurerm_dns_zone.site \
  /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/dnszones/<custom-domain>

terraform import azurerm_dns_cname_record.www \
  /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/dnszones/<custom-domain>/CNAME/www

terraform import azurerm_dns_a_record.apex \
  /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/dnszones/<custom-domain>/A/@

terraform import azurerm_dns_txt_record.apex_validation \
  /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/dnszones/<custom-domain>/TXT/_dnsauth

terraform import azurerm_static_web_app_custom_domain.www \
  /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Web/staticSites/<static-app-name>/customDomains/www.<custom-domain>

terraform import azurerm_static_web_app_custom_domain.apex \
  /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Web/staticSites/<static-app-name>/customDomains/<custom-domain>
```

Both hostnames serve the same site. DNS records do not redirect one hostname to
the other; use an application-level redirect if a single canonical hostname is
required.

The deployment workflow retrieves the Static Web App deployment token after
Azure login, so no additional Static Web Apps secret is needed.

The Terraform state storage account is managed as a protected resource with
`prevent_destroy = true`. It is separate from the Static Web App region because
Azure Static Web Apps does not support `northeurope`; the site uses `westeurope`
while the recovered state account remains in `northeurope`.

If the recovered state does not already contain the storage account resource,
import it before applying:

```bash
terraform import azurerm_storage_account.web_storage \
  /subscriptions/<subscription-id>/resourceGroups/profile/providers/Microsoft.Storage/storageAccounts/827be54aprofile
```

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

---

## 💰 Testing Azure Alert

- Create some traffic and wait for alert
- Verdict: ✅
<img width="1005" height="63" alt="image" src="https://github.com/user-attachments/assets/58d0857d-e259-4a4f-9485-f644cc16207d" />
<img width="357" height="427" alt="image" src="https://github.com/user-attachments/assets/6375bfb3-b05e-4337-a32e-4f11566ca5e7" />


## 💰 Testing Cost Alert

- Create a dummy ACI
- Verdict: ✅
<img width="647" alt="image" src="https://github.com/user-attachments/assets/ad1b58cd-f53e-41e6-a61e-db4a3b7448e6" />
