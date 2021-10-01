###################################
## Deploy Windows VM - Variables ##
####################################

# Windows VM Admin User
variable "windows-vm1-admin-username" {
  type        = string
  description = "Windows VM1 Admin User"
  default     = "tfadmin"
}

# Windows VM Admin Password
variable "windows-vm1-admin-password" {
  type        = string
  description = "Windows VM1 Admin Password"
  default     = "P@ssw0rd"
}

# Windows VM1 Hostname (limited to 15 characters long)
variable "windows-vm1-hostname" {
  type        = string
  description = "Windows VM1 Hostname"
  default     = "vamseewin1"
}

# Windows VM1 Virtual Machine Size
variable "windows-vm1-size" {
  type        = string
  description = "Windows VM1 Size"
  default     = "Standard_B2s"
}

###################################
## Deploy Windows VM2 - Variables ##
####################################

# Windows VM2 Admin User
variable "windows-vm2-admin-username" {
  type        = string
  description = "Windows VM2 Admin User"
  default     = "tfadmin"
}

# Windows VM Admin Password
variable "windows-vm2-admin-password" {
  type        = string
  description = "Windows VM2 Admin Password"
  default     = "P@ssw0rd"
}

# Windows VM2 Hostname (limited to 15 characters long)
variable "windows-vm2-hostname" {
  type        = string
  description = "Windows VM2 Hostname"
  default     = "vamseewin1"
}

# Windows VM2 Virtual Machine Size
variable "windows-vm2-size" {
  type        = string
  description = "Windows VM2 Size"
  default     = "Standard_B2s"
}


##############
## OS Image ##
##############

# Windows Server 2019 SKU used to build VMs
variable "windows-2019-sku" {
  description = "Windows Server 2019 SKU used to build VMs"
  type        = "string"
  default     = "2019-Datacenter"
}

# Windows Server 2016 SKU used to build VMs
variable "windows-2016-sku" {
  description = "Windows Server 2016 SKU used to build VMs"
  type        = "string"
  default     = "2016-Datacenter"
}

# Windows Server 2012 R2 SKU used to build VMs
variable "windows-2012-sku" {
  description = "Windows Server 2012 R2 SKU used to build VMs"
  type        = "string"
  default     = "2012-R2-Datacenter"
}