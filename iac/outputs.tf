output "vm_names" {
  description = "Names of provisioned VMs"
  value       = keys(proxmox_virtual_environment_vm.exam_vms)
}

output "vm_ids" {
  description = "VM IDs"
  value = {
    for name, vm in proxmox_virtual_environment_vm.exam_vms :
    name => vm.vm_id
  }
}

output "vm_ipv4_addresses" {
  description = "IPv4 addresses of the VMs"
  value = {
    for name, vm in proxmox_virtual_environment_vm.exam_vms :
    name => vm.ipv4_addresses
  }
}
