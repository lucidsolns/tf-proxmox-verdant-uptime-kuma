terraform {
  required_version = ">= 1.13.2"

  required_providers {
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