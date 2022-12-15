terraform {
  required_providers {
    google = {
        source  = "hashicorp/google"
        version = "~> 4.38.0"
    }
    google-beta = {
        source = "hashicorp/google-beta"
        version = "~> 4.38.0"
    }
  }
}

locals {
  mgmt_project_id = "${var.project_id_prefix}${var.organization_id}"
}

provider "google" {
  project = local.mgmt_project_id
}

provider "google-beta" {
  project = local.mgmt_project_id
}

// Create MDC GCP management project.
resource "google_project" "project" {
  name        = var.project_name
  project_id  = local.mgmt_project_id
  org_id      = var.organization_id
  billing_account = var.billing_account
}

// Enable the requested APIs.
resource "google_project_service" "gcp_apis" {
  count   = length(var.enable_apis)
  project = local.mgmt_project_id
  service = element(var.enable_apis, count.index)
}

// Create a Custom Organization Role
resource "google_organization_iam_custom_role" "ms_custom_role" {
  role_id     = "MDCCustomRole"
  org_id      = var.organization_id 
  title       = "MDCCustomRole"
  description = "Microsoft organization custom role for onboarding"
  permissions = [
        "resourcemanager.folders.get",
        "resourcemanager.folders.list",
        "resourcemanager.projects.get",
        "resourcemanager.projects.list"
        ]
}

// Create MDC GCP AutoProvisioner service account
resource "google_service_account" "onb_project_service_account" {
  account_id   = "mdc-onboarding-sa"
  display_name = "Microsoft Onboarding management service account"
  project      = google_project.project.project_id
}

// Create MDC GCP CSPM service account
resource "google_service_account" "cspm_project_service_account" {
  account_id   = "microsoft-defender-cspm"
  display_name = "Microsoft Defender CSPM"
  project      = google_project.project.project_id
}

// Bind custom role to AutoProvisioner service account
resource "google_organization_iam_member" "onboarding_service_account_binding" {
  role = google_organization_iam_custom_role.ms_custom_role.id
  org_id = var.organization_id
  member = "serviceAccount:${google_service_account.onb_project_service_account.email}"
}

// Bind viewer role to CSPM service account
resource "google_organization_iam_member" "cspm_service_account_binding" {
  role = "roles/viewer"
  org_id = var.organization_id
  member = "serviceAccount:${google_service_account.cspm_project_service_account.email}"
}

// Create workload identity pool 
resource "google_iam_workload_identity_pool" "iam_workload_identity_pool" {
  workload_identity_pool_id = var.workload_pool_id
  display_name              = "Microsoft Defender for Cloud"
  description               = "CSPM Auto Provisioner Workload Identity Pool"
  project                   = google_project.project.project_id
}

// Assign onboarding service account to pool
resource "google_service_account_iam_member" "onb_workload_assignment" {
  service_account_id = google_service_account.onb_project_service_account.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${google_project.project.number}/locations/global/workloadIdentityPools/${var.workload_pool_id}/*"
}

// Assign CSPM service account to pool
resource "google_service_account_iam_member" "cspm_workload_assignment" {
  service_account_id = google_service_account.cspm_project_service_account.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${google_project.project.number}/locations/global/workloadIdentityPools/${var.workload_pool_id}/*"
}

// Create OIDC provider for autoprovisioner
resource "google_iam_workload_identity_pool_provider" "onb_workload_identity_pool_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.iam_workload_identity_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "auto-provisioner"
  description                        = "OIDC identity pool provider for autoprovisioner"
  attribute_mapping                  = {
    "google.subject"                 = "assertion.sub"
    }
  oidc {
    allowed_audiences = ["api://d17a7d74-7e73-4e7d-bd41-8d9525e86cab"]
    issuer_uri        = "https://sts.windows.net/33e01921-4d64-4f8c-a055-5bdaffd5e33d"
  }
}

// Create OIDC provider for CSPM
resource "google_iam_workload_identity_pool_provider" "cspm_workload_identity_pool_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.iam_workload_identity_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "cspm"
  description                        = "OIDC identity pool provider for CSPM"
  attribute_mapping                  = {
    "google.subject"                 = "assertion.sub"
    }
  oidc {
    allowed_audiences = ["api://6e81e733-9e7f-474a-85f0-385c097f7f52"]
    issuer_uri        = "https://sts.windows.net/33e01921-4d64-4f8c-a055-5bdaffd5e33d"
  }
}