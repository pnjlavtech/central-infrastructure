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
  path   = "${dirname(find_in_parent_folders())}/_envcommon/eks-alb.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose = true
}

# Configure the version of the module to use in this environment. This allows you to promote new versions one
# environment at a time (e.g., dev -> stage -> prod).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v0.0.16--eks-alb"
}


dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_cidr_block = "10.230.0.0/16"
    vpc_id         = "vpc-08f7169617628dd22"
    private_subnets = [
             "subnet-0048819e19ca630b5", 
             "subnet-0d40e9b3d7602d3bb", 
             "subnet-08c154f3a5adccd99" 
    ]
    public_subnets = [
             "subnet-0048819e19ca630b5", 
             "subnet-0d40e9b3d7602d3bb", 
             "subnet-08c154f3a5adccd99" 
    ]
  }
}


dependency "acm" {
  config_path = "../acm"
  mock_outputs = {
    # argo_cert_arn = "arn:aws:acm:us-west-2:123456712345:certificate/0761d356-0614-4218-8ef2-5924efc25a94"
  certificates_arn = {
    "argocd" = "arn:aws:acm:us-west-2:***:certificate/f358f480-2bfe-4691-beb2-44adf6a0058c"
    "eks" = "arn:aws:acm:us-west-2:***:certificate/85455121-7daa-49e8-9643-cee630bcbb1e"
    }
  }
}


inputs = {
  vpc_cidr_block       = dependency.vpc.outputs.vpc_cidr_block
  vpc_id               = dependency.vpc.outputs.vpc_id
  private_subnets      = dependency.vpc.outputs.private_subnets
  public_subnets       = dependency.vpc.outputs.public_subnets
  public_domain_name   = include.envcommon.locals.public_domain
  argo_cert_arn        = dependency.acm.outputs.certificates_arn.argocd
  domain_name_argo     = include.envcommon.locals.domain_name_argo
  tags                 = merge(include.envcommon.locals.tags, 
    {"tf-module-tag" = "v0.0.16--eks-alb"}
  )
}
