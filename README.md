Deploying a Azure Windows 
============

Deploy a Windows VM, located inside a subnet and with a public IP address

Update the storage_image_reference / sku to change the Windows version to Windows Server 2019/2016/2012 R2 

Sample code compatible with **AzureRM v1.x**



Terraform Steps:
=======================
Install terraform: First of all we have to install terraform on the machine from where the code will be executed. In this case, this is the Azure DevOps agent.

Terraform init: Run terraform init command to initialize the working directory which contains terraform configuration files

Terraform plan: This command creates an execution plan of the configurations

Terraform validate: This command validates the configuration files in the working directory

Terraform apply: This command applies the changes as per the configuration files to reach the desired sta
