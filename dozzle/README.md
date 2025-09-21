This terraform file is used to configure a password and simple authentication
for the dozzle log viewer.

In general, the dozzle container is immutable and doesn't need to store state.
This username information when using the 'simple' authentication is the exception.

This script is part of a series of configurations to deploy dozzle
with authentication. The checklist includes:
- this Terraform module to create a `users.yaml content as a data URI
- butane to write the content to a host yaml file
- docker compose to volume mount the file into the dozzle container

# Butane

This is the butane snippet:
```yaml
- path: /srv/dozzle/users.yaml
  overwrite: true
  contents:
    source: ${DOZZLE_USERS_YAML_URI}
 ```

# Docker compose

The file is volumed mounted with additional space, which creates a directory per user
that is writable.


# Links
- https://registry.terraform.io/providers/viktorradnai/bcrypt/latest
- https://github.com/viktorradnai/terraform-provider-bcrypt