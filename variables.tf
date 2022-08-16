variable "key_name" {
  description = "Name of Amazon EC2 keypair for the specific region"
}
variable "region" {
  description = "Amazon EC2 region"
}
variable "ami" {
  description = "Amazon EC2 ami created with Packer"
}
variable "instance_type" {
  description = "Amazon EC2 instance type"
}

variable "db_instance_type" {
  description = "Amazon EC2 RDS instance type"
}
variable "cidr_vpc" {
  description = "Amazon EC2 VPC net"
}
variable "cidr_subnet1" {
  description = "Amazon EC2 subnet 1"
}
variable "cidr_subnet2" {
  description = "Amazon EC2 subnet 2"
}
variable "cidr_subnet3" {
  description = "Amazon EC2 subnet 3"
}
variable "cidr_subnet4" {
  description = "Amazon EC2 subnet 4"
}
variable "db_password" {
  type        = string
  sensitive   = true
  description = "Amazon RDS database password"
}
variable "enc_password" {
  type        = string
  sensitive   = true
  description = "Terraform Enterprise encryption password"
}
variable "tfe_hostname" {
  type        = string
  description = "Terraform Enterprise hostname"
}
variable "tfe_hostname_jump" {
  type        = string
  description = "Terraform Enterprise jump hostname"
}
variable "release_sequence" {
  type        = number
  description = "Terraform Enterprise release sequence number"
}
variable "minio_access_key" {
  type        = string
  description = "Minio access key"
  sensitive   = true
}
variable "minio_secret_key" {
  type        = string
  description = "Minio secret key"
  sensitive   = true
}
variable "ami_minio" {
  type        = string
  description = "Amazon EC2 Minio ami created with Packer"
}
variable "instance_type_minio" {
  type        = string
  description = "Amazon EC2 Minio instance type"
}
variable "instance_type_jump" {
  type        = string
  description = "Amazon EC2 Jump host instance type"
}
variable "s3_bucket" {
  type        = string
  description = "Name of the Terraform Enterprise S3 bucket"
}
variable "domain_name" {
  type        = string
  description = "Cloudflare domain name"
}
variable "ssl_cert_path" {
  type        = string
  description = "SSL certificate file path"
}
variable "ssl_key_path" {
  type        = string
  description = "SSL key file path"
}
variable "ssl_chain_path" {
  type        = string
  description = "SSL chain file path"
}
variable "ssl_fullchain_cert_path" {
  type        = string
  description = "SSL fullchain cert file path"
}
variable "engine_version" {
  type        = string
  description = "AWS RDS engine version"
}
variable "cloudflare_zone_id" {
  type        = string
  description = "Cloudflare DNS zone id"
}
