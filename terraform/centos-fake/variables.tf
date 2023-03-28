variable "hostname" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type = string
}

variable "datacenter_name" {
  type = string
  default = "IL Datacenter"
}

variable "datastore_name" {
  type = string
  default = "vmfs02-Do-Reservation"
}

variable "compute_cluster_name" {
  type = string
  default = "IL Main Cluster"
}

variable "compute_cluster_host" {
  type = string
  default = "esxi-01.qualisystems.local"
}

variable "wait_for_ip" {
  type = number
  default = 120
} 

variable "wait_for_net" {
  type = number
  default = 120
} 

variable "networks" {
  type        = string
  description = "Provided interfaces"
  default = "LAB/Do.(85)"
}

variable "virtual_machine_template_name" {
  type = string
}

variable "virtual_machine_name" {
  type = string
  default = "vm started by a script"
}

variable "virtual_machine_folder" {
  type = string
  default = "Do-Reservations-ESXI-01"
}

variable "linked_clone" {
  type = bool
  default = false
}

variable "connection_port" {
  type = string
  default = "3389"
}

variable "connection_protocol" {
  type = string
  default = "rdp"
}

variable "qualix_ip" {
  type = string
  default = "192.168.42.238"
}

variable "VM_username" {
  type = string
}

variable "VM_password" {
  type = string
}
