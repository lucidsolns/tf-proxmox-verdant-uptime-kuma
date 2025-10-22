This terraform file is used to configure a password and simple authentication
for the dozzle log viewer.  Dozzle is being used to view the logs until a better
alternative is found (e.g. graylog), and the 
[gelf](https://docs.docker.com/engine/logging/drivers/gelf/) driver is used  for logging.

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


# How to use

Include the module (note: at this stage the module isn't released or versioned):

```terraform
module dozzle_users {
  source = "git::https://github.com/lucidsolns/tf-proxmox-verdant-uptime-kuma.git//dozzle?ref=main"
}
```

Provide an output with the passwords:

```terraform
output dozzle_passwords {
  value = module.dozzle_users.passwords
  sensitive = true
}
```

In this (and all the examples so far), provide the dozzles user file with passwords as a 
data URI to the butane configuration for the VM.

```terraform
butane_variables = {
    DOZZLE_USERS_YAML_URI = module.dozzle_users.yaml_data_uri
}
```

In the butane configuration, write users information to a directory. The directory the file
is written too, will be volume mounted into the dozzle container and must be read-write
as the dozzle container will persist user information in that directory.  The dozzle directory
must exist.

```yaml
  files:
    - path: /srv/dozzle/users.yaml
      overwrite: true
      contents:
        source: ${DOZZLE_USERS_YAML_URI}
  directories:
    - path: /srv/dozzle
```
In the docker compose (or docker run) volume mount the dozzle directory into the container:

```yaml
  dozzle:
    image: amir20/dozzle:latest
    container_name: dozzle
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - /srv/dozzle:/data
```

# Links

- https://registry.terraform.io/providers/viktorradnai/bcrypt/latest
- https://github.com/viktorradnai/terraform-provider-bcrypt
- https://docs.docker.com/engine/logging/drivers/gelf/