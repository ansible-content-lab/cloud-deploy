variable "num_instances" {
  description = "The number of instances to deploy in the public cloud"
  type        = number
  default     = 1
}

variable "ec2_image_id" {
  description = "The image ID to use for the cloud instance"
  type        = string
  default     = "xxxx"
}

variable "machine_type" {
  description = "The instance type to use for the cloud instance"
  type        = string
  default     = "xxxx"
}

variable "access_key" {
  description = "The access key associates with the AWS account"
  type        = string
  default     = "xxxx"
}

variable "secret_key" {
  description = "The secret key associated with the AWS account"
  type        = string
  default     = "xxxx"
}
