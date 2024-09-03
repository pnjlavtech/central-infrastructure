# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# This is the configuration for Terragrunt, a thin wrapper for Terraform and OpenTofu that helps keep your code DRY and
# maintainable: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

# Include the root `terragrunt.hcl` configuration. The root configuration contains settings that are common across all
# components and environments, such as how to configure remote state.
include "root" {
  path = find_in_parent_folders()
}

# Include the envcommon configuration for the component. The envcommon configuration contains settings that are common
# for the component across all environments.
include "envcommon" {
  path   = "${dirname(find_in_parent_folders())}/_envcommon/eks-iam.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose = true
}

# Configure the version of the module to use in this environment. This allows you to promote new versions one
# environment at a time (e.g., qa -> stage -> prod).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v0.1.4--eks-iam"
}


locals {
  tags = merge(include.envcommon.locals.tags, 
    {"tf-module-tag" = "v0.1.4--eks-iam"}
  )
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    cluster_name   = "eks"
    oidc_provider  = "oidc-provider"
  }
  // mock_outputs_allowed_terraform_commands = ["plan"]
}


inputs = {
  cluster_name  = dependency.eks.outputs.cluster_name
  oidc_provider = dependency.eks.outputs.oidc_provider
  tags          = locals.tags
  // public_domain = include.envcommon.locals.public_domain
}
