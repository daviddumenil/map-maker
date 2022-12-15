variable "organization_id" {
    description = "The ID of your organization in GCP."
}

variable "billing_account" {
    description = "ID of billing account for mgmt project"
}

variable "workload_pool_id" {
    description = "ID for workload identity pool (customer MS tenant id)"
}

variable "enable_apis" {
    description = "Which APIs to enable for this project."
    type        = list(string)
    default     = ["iam.googleapis.com", 
                   "cloudresourcemanager.googleapis.com",
                   "sts.googleapis.com",
                   "iamcredentials.googleapis.com",
                   "compute.googleapis.com",
                   "container.googleapis.com",
                   "sqladmin.googleapis.com", 
				   "apikeys.googleapis.com", 
				   "cloudkms.googleapis.com"]
}

variable "project_id_prefix" {
    description = "Project id prefix, org id is appended"
    default     = "mdc-mgmt-proj-"
}

variable "project_name" {
    description = "Default Project Name"
    default     = "MDC Management Project"
}