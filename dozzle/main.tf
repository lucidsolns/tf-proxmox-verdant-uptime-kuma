/*

*/


/*
  A random password for the dozzle user.
*/
resource "random_password" "dozzle" {
  for_each = var.user

  length  = 32    # number of characters
  special = false # include special chars
}

/*
  Generate a bcrypt hash of the dozzle user password. This will be part
  of the user.yaml file mounted in the dozzle container for 'simple' authentication.

  see:
    - https://registry.terraform.io/providers/viktorradnai/bcrypt/latest/docs/resources/hash
*/
resource "bcrypt_hash" "dozzle" {
  for_each = var.user

  cleartext = random_password.dozzle[each.key].result
}


locals {
  /*
    Create a dozzle users.yaml file content.

    see:
        - https://dozzle.dev/guide/authentication
        - https://developer.hashicorp.com/terraform/language/functions/yamlencode
  */
  dozzle_users_yaml = yamlencode({
    users = {
      for username, user in var.user :
      username => {
        email    = user.email
        name     = user.name
        password = bcrypt_hash.dozzle[username].id
      }
    }
  })

  /*
    Encode this YAML file as a base64 encoded data URL, so it can be easily and
    opaquely included into the butane configuration.

  */
  dozzle_user_yaml_data_uri = "data:text/plain;base64,${base64encode(local.dozzle_users_yaml)}"
}

