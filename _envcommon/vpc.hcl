# ---------------------------------------------------------------------------------------------------------------------
# COMMON TERRAGRUNT CONFIGURATION
# This is the common component configuration for vpc. The common variables for each environment to
# deploy vpc are defined here. This configuration will be merged into the environment configuration
# via an include block.
# ---------------------------------------------------------------------------------------------------------------------

locals {
  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Extract the variables we need for easy access
  cidr       = local.environment_vars.locals.cidr
  eks_clus   = local.region_vars.locals.eks_clus
  eks_name   = local.environment_vars.locals.eks_name
  eks_fname  = "${local.eks_name}-${local.eks_clus}-${local.region}" # "dev-eks-a-us-west-2"
  env        = local.environment_vars.locals.environment
  region     = local.region_vars.locals.region
  // gh_token   = get_env("GH_PAT")
  vpc_cidr   = local.cidr

  tags = {
    created-date     = "2024-09-08"
    created-by       = "jay"
    clustername      = local.eks_fname
    env              = local.env
    region           = local.region
    github-repo      = "tf-aws-modules"
    tf-module        = "vpc"
  }

  # Expose the base source URL so different versions of the module can be deployed in different environments. 
  # This will be used to construct the source URL in the child terragrunt configurations.
  // base_source_url = "git::https://github.com/pnjlavtech/terragrunt-infrastructure-modules.git//modules/vpc"
  base_source_url = "git::https://github.com/pnjlavtech/tf-aws-modules.git//vpc"
  // this would be needed if the repo was private
  // base_source_url = "git::https://jazzlyj:${gh_token}@github.com/pnjlavtech/terragrunt-infrastructure-modules.git//modules/vpc"

  //  Set cidr_subnet newbits and netnums values to be common across all environments
  public_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 0),
    cidrsubnet(local.vpc_cidr, 6, 1),
    cidrsubnet(local.vpc_cidr, 6, 2),
  ]

  private_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 4),
    cidrsubnet(local.vpc_cidr, 6, 5),
    cidrsubnet(local.vpc_cidr, 6, 6),
  ]

  intra_subnets = [
    cidrsubnet(local.vpc_cidr, 6, 7),
    cidrsubnet(local.vpc_cidr, 6, 8),
    cidrsubnet(local.vpc_cidr, 6, 9),
  ]

}




# ---------------------------------------------------------------------------------------------------------------------
# MODULE PARAMETERS
# These are the variables we have to pass in to use the module. 
# This defines the parameters that are common across all environments.
# ---------------------------------------------------------------------------------------------------------------------
inputs = {
  cidr                                            = local.cidr
  intra_subnets                                   = local.intra_subnets
  name                                            = "${local.env}-${local.region}-vpc"
  private_subnets                                 = local.private_subnets
  public_subnets                                  = local.public_subnets
  intra_subnet_tags = {
    env                   = "${local.env}"
    fullname              = "${local.env}-vpc-subnet-intra-${local.region}" 
    module-component      = "subnet"
    module-component-type = "subnet-intra"
  }
  private_subnet_tags = {
    env                               = "${local.env}"
    fullname                          = "${local.env}-vpc-subnet-private-${local.region}" 
    module-component                  = "subnet"
    module-component-type             = "subnet-private"
    "karpenter.sh/discovery"          = "${local.eks_fname}"
    "kubernetes.io/role/internal-elb" = 1
  }
  public_subnet_tags = {
    env                                        = "${local.env}"
    fullname                                   = "${local.env}-vpc-subnet-public-${local.region}" 
    // "kubernetes.io/cluster/${local.eks_fname}" = "shared"
    "kubernetes.io/role/elb"                   = 1
    module-component                           = "subnet"
    module-component-type                      = "subnet-public"
  }

}
