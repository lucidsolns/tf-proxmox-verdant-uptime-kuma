/*
  Provide the dozzle admin password. Use the following command to get the password
  from the terraform state file:

  Because the passwords is a map/object, use the following command to get the value.
       terraform output -json dozzle_passwords

  Note: If it were a string, this would be required.
       terraform output -raw dozzle_passwords

  add something like the this to get the passwords as an output:
  ```terraform
    output dozzle_passwords {
      value = module.dozzle_users.passwords
      sensitive = true
    }
  ```
*/
output "passwords" {
  description = "Map of usernames to their generated Dozzle passwords"
  value = {
    for username, pw in random_password.dozzle :
    username => pw.result
  }
  sensitive = true
}


output "yaml_data_uri" {
  description = "The dozzle users file yaml with passwords"
  value = local.dozzle_user_yaml_data_uri
}
