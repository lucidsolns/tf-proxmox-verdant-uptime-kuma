terraform {
  required_version = ">= 1.13.2"

  /**

    see:
      - https://registry.terraform.io/providers/bpg/proxmox/latest/docs
   */
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.83.2"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    /*
      Support to create a simple bcrypt password for dozzle

      see:
        - https://registry.terraform.io/providers/viktorradnai/bcrypt/latest
    */
    bcrypt = {
      source  = "viktorradnai/bcrypt"
      version = "0.1.2"
    }
  }
}

/**
   Configure the provider with SSH agent support, and hack in a username.

   TODO: Create a terraform user, and use an API token
 */
provider "proxmox" {

  endpoint = var.pm_api_url
  username = var.pm_user
  password = var.pm_password
  insecure = true
  ssh {
    agent    = true
    username = var.ssh_username
  }
}


