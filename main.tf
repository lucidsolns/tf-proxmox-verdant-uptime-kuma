/**
    Uptime Kuma VM

    see:
      - https://uptimekuma.org/
 */
module "uptime_kuma" {
  source  = "lucidsolns/flatcar-vm/proxmox"
  version = "1.0.10"

  vm_name        = "verdant.lucidsolutions.co.nz"
  vm_description = "A Flatcar VM with docker compose running an uptime kuma instance"
  vm_id          = var.vm_id
  node_name      = var.node_name
  tags           = ["uptime-kuma", "flatcar", "dozzle", "watchtower"]
  cpu = {
    cores = 2
    type  = "x86-64-v3"
  }
  memory = {
    dedicated = 1500
  }

  butane_conf         = "${path.module}/verdant.bu.tftpl"
  butane_snippet_path = "${path.module}/config"
  butane_variables = {
    DB_ROOT_PASSWORD        = random_password.db_root_password.result
    DB_UPTIME_KUMA_PASSWORD = random_password.db_owncloud_password.result
    DOZZLE_USERS_YAML_URI       = local.dozzle_user_yaml_data_uri
  }
  bridge  = var.bridge
  vlan_id = var.vlan_id

  persistent_disks = [
    // 2 gigabytes of data for the database
    {
      datastore_id = var.storage_data
      size         = 2
      iothread     = true
      discard      = "on"
      backup       = true
    },
    // 16 GB of data for uptime kuma data/logs
    {
      datastore_id = var.storage_data
      size         = 16
      iothread     = true
      discard      = "on"
      backup       = true
    }
  ]

  storage_images       = var.storage_images
  storage_root         = var.storage_root
  storage_path_mapping = var.storage_path_mapping
}
/*
  Generate a random password to be used for the 'owncloud' user for the db server
*/
resource "random_password" "db_owncloud_password" {
  length  = 32    # number of characters
  special = false # include special chars
}

/*
  Generate a random password to be used for the 'root' user for the db server
*/
resource "random_password" "db_root_password" {
  length  = 32    # number of characters
  special = false # include special chars
}

resource "random_password" "dozzle_admin_password" {
  length  = 32    # number of characters
  special = false # include special chars
}

/*
  Generate a bcrypt hash of the dozzle admin users password. This will be part
  of the user.yaml file mounted in the dozzle container for 'simple' authentication.

  see:
    - https://registry.terraform.io/providers/viktorradnai/bcrypt/latest/docs/resources/hash
*/
resource "bcrypt_hash" "dozzle_admin" {
  cleartext = random_password.dozzle_admin_password.result
}


locals {
  /*
    Create a dozzle users.yaml file content.

    see:
        - https://dozzle.dev/guide/authentication
        - https://developer.hashicorp.com/terraform/language/functions/yamlencode
  */
  dozzle_users_yaml = yamlencode({
    users : {
      admin : {
        email : "dozzle@lucidsolutions.co.nz"
        name : "Admin"
        password : bcrypt_hash.dozzle_admin.id
      }
    }
  })

  /*
    Encode this YAML file as a base64 encoded data URL, so it can be easily and
    opaquely included into the butane configuration.

  */
  dozzle_user_yaml_data_uri = "data:text/plain;base64,${base64encode(local.dozzle_users_yaml)}"
}

/*
  Provide the dozzle admin password. Use the following command to get the password
  from the terraform state file:

       terraform output -raw dozzle_admin_password
*/
output "dozzle_admin_password" {
  description = "The password to use for the admin user for dozzle log viewer"
  value       = random_password.dozzle_admin_password.result
  sensitive   = true
}

