variable "user" {
  description = "A map of dozzle users to their email address and name"
  type = map(object({
    email = string
    name  = string
  }))
  default = {
    admin : {
      email : "dozzle@lucidsolutions.co.nz"
      name : "Admin"
    }
  }
}
