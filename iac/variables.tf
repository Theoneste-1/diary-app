variable "proxmox_api_url" {
  description = "Proxmox API endpoint"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "Proxmox API token ID"
  type        = string
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
}

variable "proxmox_node" {
  description = "Proxmox node name"
  type        = string
  default     = "Server1"
}

variable "template_id" {
  description = "VM template ID"
  type        = number
  default     = 9002
}

variable "storage" {
  description = "Proxmox storage"
  type        = string
  default     = "local-lvm"
}

variable "pool_id" {
  description = "Proxmox resource pool"
  type        = string
  default     = "exam-c2"
}

variable "vm_username" {
  description = "Username to create on the VMs"
  type        = string
}

variable "vm_password" {
  description = "Password to create on the VMs"
  type        = string
  sensitive   = true
}

variable "vm_configs" {
  description = "VM configurations"
  type = map(object({
    vm_id  = number
    cores  = number
    memory = number
    disk   = number
  }))
}

variable "network_bridge" {
  description = "Proxmox network bridge"
  type        = string
  default     = "vmbr0"
}
