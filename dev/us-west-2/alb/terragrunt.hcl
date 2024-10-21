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
  path   = "${dirname(find_in_parent_folders())}/_envcommon/alb.hcl"
  # We want to reference the variables from the included config in this configuration, so we expose it.
  expose = true
}

# Configure the version of the module to use in this environment. This allows you to promote new versions one
# environment at a time (e.g., dev -> stage -> prod).
terraform {
  source = "${include.envcommon.locals.base_source_url}?ref=v0.0.2--alb"
}


dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    vpc_cidr_block = "10.230.0.0/16"
    vpc_id         = "vpc-08f7169617628dd22"
    public_subnets = [
             "subnet-0048819e19ca630b5", 
             "subnet-0d40e9b3d7602d3bb", 
             "subnet-08c154f3a5adccd99" 
    ]
  }
}

dependency "eks" {
  config_path = "../eks"
  mock_outputs = {
    karpenter_node_group = "dev-eks-a-us-west-2:karpenter-20241020202325788000000011"
  }
}


dependency "acm" {
  config_path = "../acm"
  mock_outputs = {
    acm_certificate_arn = "arn:aws:acm:us-west-2:***:certificate/0761d356-0614-4218-8ef2-5924efc25a94"
  }
}


inputs = {
  vpc_cidr_block       = dependency.vpc.outputs.vpc_cidr_block
  vpc_id               = dependency.vpc.outputs.vpc_id
  public_subnets       = dependency.vpc.outputs.public_subnets
  karpenter_node_group = dependency.eks.outputs.eks_managed_node_groups["karpenter"].node_group_autoscaling_group_names[0]
  // karpenter_node_group = eks_managed_node_groups_autoscaling_group_names[0]
  acm_certificate_arn  = dependency.acm.outputs.acm_certificate_arn
  tags                = merge(include.envcommon.locals.tags, 
    {"tf-module-tag" = "v0.0.2--alb"}
  )
}
