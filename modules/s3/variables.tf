variable "source_region" {
description = "AWS region for the source S3 bucket and KMS key"
  type        = string
}

variable "destination_region" {
  description = "AWS region for the destination S3 bucket and KMS key"
  type        = string
}

variable "source_bucket_name" {
  description = "Name of the source S3 bucket"
  type        = string
}

variable "destination_bucket_name" {
  description = "Name of the destination S3 bucket"
  type        = string
}
