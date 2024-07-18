# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for eks with karpenter. The common variables for each environment to
# deploy eks with karpenter are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract out common variables for reuse
  env = local.environment_vars.locals.environment

  # Extract the variables we need for easy access
  region     = local.region_vars.locals.region
  cidr       = local.environment_vars.locals.cidr
  eks_name   = local.environment_vars.locals.eks_name
  env-region = "${local.env}-${local.region}"
  vpc_cidr   = local.cidr

  tags = {
    Clustername = "${local.eks_name}"
    // GithubRepo  = "central-infrastructure"
    // GithubOrg   = "pnjlavtech"
  }

  # Expose the base source URL so different versions of the module can be deployed in different environments. This will
  # be used to construct the source URL in the child terragrunt configurations.
  base_source_url = "git::https://github.com/pnjlavtech/tf-aws-modules.git//modules/eks"
}




# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. This defines the parameters that are common across all
# environments.
# ---------------------------------------------------------------------------------------------------------------------