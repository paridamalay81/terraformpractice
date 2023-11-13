variable "iam-user-policy-map" {
  default = {
    "user 1" = ["policy1", "policy2"],
    "user 2" = ["policy1"]
  }
}

locals {
  association-map = merge([
    for user, policies in var.iam-user-policy-map : {
      for policy in policies :
        "${user}-${policy}" => {
          "user"   = user
          "policy" = policy
        }
    }
  ]...)
}

output "association-map" {
  value = local.association-map
}