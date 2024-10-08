# Infrastructure-CICD for Terragrunt using Github Actions Deployted into AWS 

This repo, along with the [terragrunt-infrastructure-modules](https://github.com/pnjlavtech/terragrunt-infrastructure-modules), 
show an example file/folder structure you can use with [Terragrunt](https://github.com/gruntwork-io/terragrunt) to keep your
[Terraform](https://www.terraform.io) code DRY. For background information, 
check out the [Keep your code DRY](https://github.com/gruntwork-io/terragrunt#keep-your-terraform-code-dry) 
section of the Terragrunt documentation.

This repo shows an example of how to use the modules from the `terragrunt-infrastructure-modules` repo to
deploy infra (vpc, eks, iam and argocd) across three environments (qa, stage, prod) and two AWS accounts
(non-prod, prod), all with minimal duplication of code. That's because there is just a single copy of
the code, defined in the `terragrunt-infrastructure-modules` repo, and in this repo, we solely define
`terragrunt.hcl` files that reference that code (at a specific version, too!) and fill in variables specific to each
environment.

Be sure to read through [the Terragrunt documentation on DRY
Architectures](https://terragrunt.gruntwork.io/docs/features/keep-your-terragrunt-architecture-dry/) to understand the
features of Terragrunt used in this folder organization.

The GH Actions pipeline also makes use of tflint for linting and Checkov for SCA (policy as code)
## Tflint
[tflint action](https://github.com/marketplace/actions/setup-tflint)

## Checkov
Checkov scans cloud infrastructure configurations to find misconfigurations before they're deployed.

Checkov is a static code analysis tool for infrastructure as code (IaC) and also a software composition analysis (SCA) tool for images and open source packages.

It scans cloud infrastructure provisioned using Terraform, Terraform plan, Cloudformation, AWS SAM, Kubernetes, Helm charts, Kustomize, Dockerfile, Serverless, Bicep, OpenAPI or ARM Templates and detects security and compliance misconfigurations using graph-based scanning.

It performs Software Composition Analysis (SCA) scanning which is a scan of open source packages and images for Common Vulnerabilities and Exposures (CVEs).

[checkov action](https://github.com/marketplace/actions/checkov-github-action)


## GH Actions
CICD is using:

* Composite action
   * action.yaml
NOTE: GH Composite actions using other actions complicates things.

Cant use if 

if you want to use if then you have to use run 
 

* Workflow calling composite actions







## How do you deploy the infrastructure in this repo?


### Pre-requisites

1. Install [Terraform](https://www.terraform.io) version `1.5.3` or newer and
   [Terragrunt](https://github.com/gruntwork-io/terragrunt) version `v0.52.0` or newer.
2. Update the `bucket` parameter in the root `terragrunt.hcl`. We use S3 [as a Terraform
   backend](https://opentofu.org/docs/language/settings/backends/s3/) to store your
   state, and S3 bucket names must be globally unique. The name currently in
   the file is already taken, so you'll have to specify your own. Alternatives, you can
   set the environment variable `TG_BUCKET_PREFIX` to set a custom prefix.
3. Update the `account_name` parameters in [`non-prod/account.hcl`](/non-prod/account.hcl) and
   [`prod/account.hcl`](/prod/account.hcl) with the names of accounts you want to use for non production and 
   production workloads, respectively.
4. Create several variables in including theAWS credentials using one of the supported [authentication
   mechanisms](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html).



### Deploying a single module
1. In the tg_yaml env: section set "working_dir" to the module and location to be deployed (e.g. `cd non-prod/us-west-2/qa/vpc`).


### Deploying all modules in a region
1. In the tg_yaml env: section set "working_dir" to the location to be deployed (e.g. `cd non-prod/us-west-2`).


### Testing the infrastructure after it's deployed

After each module is finished deploying, it will write a bunch of outputs to the screen. For example, the ASG will
output something like the following:

```
Outputs:

asg_name = tf-asg-00343cdb2415e9d5f20cda6620
asg_security_group_id = sg-d27df1a3
elb_dns_name = webserver-example-prod-1234567890.us-east-1.elb.amazonaws.com
elb_security_group_id = sg-fe62ee8f
url = http://webserver-example-prod-1234567890.us-east-1.elb.amazonaws.com:80
```

A minute or two after the deployment finishes, and the servers in the ASG have passed their health checks, you should
be able to test the `url` output in your browser or with `curl`:

```
curl http://webserver-example-prod-1234567890.us-east-1.elb.amazonaws.com:80

Hello, World
```

Similarly, the MySQL module produces outputs that will look something like this:

```
Outputs:

arn = arn:aws:rds:us-east-1:1234567890:db:tofu-00d7a11c1e02cf617f80bbe301
db_name = mysql_prod
endpoint = tofu-1234567890.abcdefghijklmonp.us-east-1.rds.amazonaws.com:3306
```

You can use the `endpoint` and `db_name` outputs with any MySQL client:

```
mysql --host=tofu-1234567890.abcdefghijklmonp.us-east-1.rds.amazonaws.com:3306 --user=admin --password mysql_prod
```






## How is the code in this repo organized?

The code in this repo uses the following folder hierarchy:

```
account
 └ _global
 └ region
    └ _global
    └ environment
       └ resource
```

Where:

* **Account**: At the top level are each of your AWS accounts, such as `stage-account`, `prod-account`, `mgmt-account`,
  etc. If you have everything deployed in a single AWS account, there will just be a single folder at the root (e.g.
  `main-account`).

* **Region**: Within each account, there will be one or more [AWS
  regions](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-regions-availability-zones.html), such as
  `us-east-1`, `eu-west-1`, and `ap-southeast-2`, where you've deployed resources. There may also be a `_global`
  folder that defines resources that are available across all the AWS regions in this account, such as IAM users,
  Route 53 hosted zones, and CloudTrail.

* **Environment**: Within each region, there will be one or more "environments", such as `qa`, `stage`, etc. Typically,
  an environment will correspond to a single [AWS Virtual Private Cloud (VPC)](https://aws.amazon.com/vpc/), which
  isolates that environment from everything else in that AWS account. There may also be a `_global` folder
  that defines resources that are available across all the environments in this AWS region, such as Route 53 A records,
  SNS topics, and ECR repos.

* **Resource**: Within each environment, you deploy all the resources for that environment, such as EC2 Instances, Auto
  Scaling Groups, ECS Clusters, Databases, Load Balancers, and so on. Note that the code for most of these
  resources lives in the [terragrunt-infrastructure-modules-example repo](https://github.com/pnjlavtech/terragrunt-infrastructure-modules).

## Creating and using root (account) level variables

In the situation where you have multiple AWS accounts or regions, you often have to pass common variables down to each
of your modules. Rather than copy/pasting the same variables into each `terragrunt.hcl` file, in every region, and in
every environment, you can inherit them from the `inputs` defined in the root `terragrunt.hcl` file.
