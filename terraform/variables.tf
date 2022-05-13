variable "client_id" {}
variable "client_secret" {}
variable "ssh_public_key" {}

variable "environment" {
  default = "dev"
}

variable "location" {
  default = "centralindia"
}

variable "node_count" {
  default = 2
}

variable "dns_prefix" {
  default = "k8stest"
}

variable "cluster_name" {
  default = "k8stest"
}

variable "resource_group" {
  default = "k8stest_rg"
}

variable "api_key_vault" {
  default = "zipcodeApiKeyVault"
}

variable "api_key_vault_secret" {
  default = "zipcodeApiKeyVaultSecret"
}