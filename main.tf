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

  butane_conf         = "${path.module}/butane.tftpl"
  butane_snippet_path = "${path.module}/config"
  butane_variables = {
    DB_ROOT_PASSWORD        = random_password.db_root_password.result
    DB_UPTIME_KUMA_PASSWORD = random_password.db_owncloud_password.result
    DOZZLE_USERS_YAML_URI   = module.dozzle_users.yaml_data_uri
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

module dozzle_users {
  source = "./dozzle"
}

output dozzle_passwords {
  value = module.dozzle_users.passwords
  sensitive = true
}