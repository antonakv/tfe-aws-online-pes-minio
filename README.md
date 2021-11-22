# tfe-aws-online-s3db
Terraform Enterprise online install on AWS with S3 and Postgresql db

This manual is dedicated to install Terraform Enterprise online install on AWS with S3 and Postgresql db.

## Requirements

- Hashicorp terraform recent version installed
[Terraform installation manual](https://learn.hashicorp.com/tutorials/terraform/install-cli)

- git installed
[Git installation manual](https://git-scm.com/download/mac)

- Amazon AWS account credentials saved in .aws/credentials file
[Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

- Configured AWS Route53 DNS zone for domain `myname.hashicorp-success.com`
[Amazon Route53: Working with public hosted zones](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/AboutHZWorkingWith.html)

- Created Amazon EC2 key pair for Linux instance
[Create a key pair using Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

## Preparation 

- Clone git repository

```bash
git clone https://github.com/antonakv/tfe-aws-online-s3db.git
```

Expected command output looks like this:

```bash
Cloning into 'tfe-aws-online-s3db'...
remote: Enumerating objects: 12, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 12 (delta 1), reused 3 (delta 0), pack-reused 0
Receiving objects: 100% (12/12), done.
Resolving deltas: 100% (1/1), done.
```

- Change folder to tfe-aws-online-s3db

```bash
cd tfe-aws-online-s3db
```

- Create file testing.tfvars with following contents

```
key_name         = "aakulov"
ami              = "ami-086128e34136c3375"
instance_type    = "t3.2xlarge"
db_instance_type = "db.t3.medium"
region           = "eu-central-1"
cidr_vpc         = "10.5.0.0/16"
cidr_subnet1     = "10.5.1.0/24"
cidr_subnet2     = "10.5.2.0/24"
cidr_subnet3     = "10.5.3.0/24"
cidr_subnet4     = "10.5.4.0/24"
db_password      = "dbpwd_HERE"
enc_password     = "encpwd_HERE"
tfe_hostname     = "tfe7.anton.hashicorp-success.com"
```

- Change folder to `pre-req`

Follow `pre-req/README.md` manual to prepare assets on Amazon S3 required for the installation

## Run terraform code

- In the same folder you were before, run 

```bash
terraform init
```

Sample result

```
$ terraform init

Initializing the backend...

Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 3.52"...
- Finding hashicorp/tls versions matching "~> 3.1.0"...
- Finding hashicorp/template versions matching "~> 2.2.0"...
- Installing hashicorp/aws v3.66.0...
- Installed hashicorp/aws v3.66.0 (signed by HashiCorp)
- Installing hashicorp/tls v3.1.0...
- Installed hashicorp/tls v3.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.

```

- Execute `terraform apply`

```

```