# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for karpenter. The common variables for each environment to
# deploy karpenter are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  eks_clus   = local.region_vars.locals.eks_clus
  eks_name   = local.environment_vars.locals.eks_name
  eks_fname  = "${local.eks_name}-${local.eks_clus}-${local.region}" # "dev-eks-a-us-west-2"
  env        = local.environment_vars.locals.environment
  region     = local.region_vars.locals.region

  tags = {
    created-date     = "2024-09-08"
    created-by       = "jay"
    clustername      = local.eks_fname
    env              = local.env
    region           = local.region
    github-repo      = "tf-aws-modules"
    tf-module        = "karpenter"
  }


  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::https://github.com/pnjlavtech/tf-aws-modules.git//karpenter"
}


# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------