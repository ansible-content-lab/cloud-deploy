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
  default     = "pppp"
}

variable "gcp_prefix" {
  description = "The prefix to place in front of all gcp resources"
  type        = string
  default     = "ffff"
}

variable "machine_type" {
  description = "The instance type to use for the cloud instance"
  type        = string
  default     = "xxxx"
}

variable "gcp_key" {
  description = "The path to the service account key that will be used to authenticate with GCP"
  type        = string
  default     = "mmmm"
}

variable "gcp_project" {
  description = "The name of the GCP project that this script will operate on"
  type        = string
  default     = "nnnn"
}

variable "application" {
  description = "The application being installed on the linux instances"
  type        = string
  default     = "xxxx"
}

variable "tower_username" {
  description = "The username to log into Ansible Tower"
  type        = string
  default     = "xxxx"
}

variable "tower_password" {
  description = "The password to log into Ansible Tower"
  type        = string
  default     = "xxxx"
}

variable "tower_ssh_username" {
  description = "The ssh username for the Ansible Tower server"
  type        = string
  default     = "xxxx"
}

variable "tower_ssh_key" {
  description = "The ssh private key for the Ansible Tower server"
  type        = string
  default     = "xxxx"
}

variable "tower_ssh_password" {
  description = "The ssh password for the Ansible Tower server"
  type        = string
  default     = "xxxx"
}

variable "tower_hostname" {
  description = "The ssh hostname for the Ansible Tower server"
  type        = string
  default     = "xxxx"
}
