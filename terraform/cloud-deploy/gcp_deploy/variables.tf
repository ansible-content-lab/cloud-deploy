variable "num_instances" {
  description = "The number of instances to deploy in the public cloud"
  type        = number
  default     = 1
}

variable "gcp_disk_image" {
  description = "The image ID to use for the cloud instance"
  type        = string
  default     = "xxxx"
}

variable "gcp_region" {
  description = "The GCP region to operate in"
  type        = string
  default     = "xxxx"
}

variable "gcp_prefix" {
  description = "The prefix to place in front of all gcp resources"
  type        = string
  default     = "xxxx"
}

variable "machine_type" {
  description = "The instance type to use for the cloud instance"
  type        = string
  default     = "xxxx"
}

variable "gcp_key" {
  description = "The path to the service account key that will be used to authenticate with GCP"
  type        = string
  default     = "xxxx"
}

variable "gcp_project" {
  description = "The name of the GCP project that this script will operate on"
  type        = string
  default     = "xxxx"
}

variable "application" {
  description = "The application being installed on the linux instances"
  type        = string
  default     = "xxxx"
}
