# tfe-aws-online-pes
Terraform Enterprise online install on AWS with S3 and Postgresql db

This manual is dedicated to install Terraform Enterprise online install on AWS with S3 and Postgresql db.

## Requirements

- Hashicorp terraform recent version installed
[Terraform installation manual](https://learn.hashicorp.com/tutorials/terraform/install-cli)

- git installed
[Git installation manual](https://git-scm.com/download/mac)

- Amazon AWS account credentials saved in .aws/credentials file
[Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)

- Configured Cloudflare DNS zone for domain `myname.my-domain-here.com`
[Cloudflare DNS](https://developers.cloudflare.com/dns/)

- SSL certificate and SSL key files for the corresponding domain name
[Certbot manual](https://certbot.eff.org/instructions)

- Created Amazon EC2 key pair for Linux instance
[Create a key pair using Amazon EC2](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair)

## Preparation 

- Clone git repository

```bash
git clone https://github.com/antonakv/tfe-aws-online-pes.git
```

Expected command output looks like this:

```bash
Cloning into 'tfe-aws-online-pes'...
remote: Enumerating objects: 12, done.
remote: Counting objects: 100% (12/12), done.
remote: Compressing objects: 100% (12/12), done.
remote: Total 12 (delta 1), reused 3 (delta 0), pack-reused 0
Receiving objects: 100% (12/12), done.
Resolving deltas: 100% (1/1), done.
```

- Change folder to tfe-aws-online-pes

```bash
cd tfe-aws-online-pes
```

- Create file testing.tfvars with following contents

```
key_name                = "aakulov"
ami                     = "ami-086128e34136c3375"
instance_type           = "t3.2xlarge"
db_instance_type        = "db.t3.medium"
region                  = "eu-central-1"
cidr_vpc                = "10.5.0.0/16"
cidr_subnet1            = "10.5.1.0/24"
cidr_subnet2            = "10.5.2.0/24"
cidr_subnet3            = "10.5.3.0/24"
cidr_subnet4            = "10.5.4.0/24"
db_password             = "PUT_your_Value_Here"
enc_password            = "PUT_your_Value_Here"
tfe_hostname            = "PUT_your_Value_Here"
tfe_hostname_jump       = "PUT_your_Value_Here"
release_sequence        = 607
minio_access_key        = "PUT_your_Value_Here"
minio_secret_key        = "PUT_your_Value_Here"
ami_minio               = "ami-0b5de643012fe5385"
instance_type_minio     = "t3.large"
instance_type_jump      = "t3.medium"
s3_bucket               = "aakulov-aws9-tfe-data"
cloudflare_api_token    = "PUT_your_Value_Here"
cloudflare_zone_id      = "PUT_your_Value_Here"
domain_name             = "akulov.cc"
ssl_cert_path           = "PUT_your_Value_Here"
ssl_key_path            = "PUT_your_Value_Here"
ssl_chain_path          = "PUT_your_Value_Here"
ssl_fullchain_cert_path = "PUT_your_Value_Here"
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
$ terraform apply

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.template_cloudinit_config.aws9_cloudinit will be read during apply
  # (config refers to values not yet known)
 <= data "template_cloudinit_config" "aws9_cloudinit"  {
      + base64_encode = true
      + gzip          = true
      + id            = (known after apply)
      + rendered      = (known after apply)

      + part {
          + content      = (known after apply)
          + content_type = "text/x-shellscript"
          + filename     = "install_tfe.sh"
        }
    }

  # data.template_file.install_tfe_minio_sh will be read during apply
  # (config refers to values not yet known)
 <= data "template_file" "install_tfe_minio_sh"  {
      + id       = (known after apply)
      + rendered = (known after apply)
      + template = <<-EOT
            #!/usr/bin/env bash
            mkdir -p /home/ubuntu/install
            
            mkdir -p /home/ubuntu/.aws
            
            echo "
            {
                \"aws_access_key_id\": {
                    \"value\": \"${minio_access_key}\"
                },
                \"aws_instance_profile\": {
                    \"value\": \"0\"
                },
                \"aws_secret_access_key\": {
                    \"value\": \"${minio_secret_key}\"
                },
                \"azure_account_key\": {},
                \"azure_account_name\": {},
                \"azure_container\": {},
                \"azure_endpoint\": {},
                \"backup_token\": {
                    \"value\": \"3e69c0572c1eddf7f232cf60f6b8634194bf40d09aa9535c78430e64df407ec4\"
                },
                \"ca_certs\": {},
                \"capacity_concurrency\": {
                    \"value\": \"10\"
                },
                \"capacity_memory\": {
                    \"value\": \"512\"
                },
                \"custom_image_tag\": {
                    \"value\": \"hashicorp/build-worker:now\"
                },
                \"disk_path\": {},
                \"enable_active_active\": {
                    \"value\": \"0\"
                },
                \"enable_metrics_collection\": {
                    \"value\": \"1\"
                },
                \"enc_password\": {
                    \"value\": \"${enc_password}\"
                },
                \"extern_vault_addr\": {},
                \"extern_vault_enable\": {
                    \"value\": \"0\"
                },
                \"extern_vault_path\": {},
                \"extern_vault_propagate\": {},
                \"extern_vault_role_id\": {},
                \"extern_vault_secret_id\": {},
                \"extern_vault_token_renew\": {},
                \"extra_no_proxy\": {},
                \"force_tls\": {
                    \"value\": \"0\"
                },
                \"gcs_bucket\": {},
                \"gcs_credentials\": {
                    \"value\": \"{}\"
                },
                \"gcs_project\": {},
                \"hairpin_addressing\": {
                    \"value\": \"0\"
                },
                \"hostname\": {
                    \"value\": \"${hostname}\"
                },
                \"iact_subnet_list\": {},
                \"iact_subnet_time_limit\": {
                    \"value\": \"60\"
                },
                \"installation_type\": {
                    \"value\": \"production\"
                },
                \"pg_dbname\": {
                    \"value\": \"mydbtfe\"
                },
                \"pg_extra_params\": {
                    \"value\": \"sslmode=disable\"
                },
                \"pg_netloc\": {
                    \"value\": \"${pgsqlhostname}\"
                },
                \"pg_password\": {
                    \"value\": \"${pgsqlpassword}\"
                },
                \"pg_user\": {
                    \"value\": \"${pguser}\"
                },
                \"placement\": {
                    \"value\": \"placement_s3\"
                },
                \"production_type\": {
                    \"value\": \"external\"
                },
                \"redis_host\": {},
                \"redis_pass\": {
                    \"value\": \"NGVITSiZJKkmtC9ed1XWjScsVZMnXJx5\"
                },
                \"redis_port\": {},
                \"redis_use_password_auth\": {},
                \"redis_use_tls\": {},
                \"restrict_worker_metadata_access\": {
                    \"value\": \"0\"
                },
                \"s3_bucket\": {
                    \"value\": \"${s3bucket}\"
                },
                \"s3_endpoint\": {
                    \"value\": \"${s3endpoint}\"
                },
                \"s3_region\": {
                    \"value\": \"${s3region}\"
                },
                \"s3_sse\": {},
                \"s3_sse_kms_key_id\": {},
                \"tbw_image\": {
                    \"value\": \"default_image\"
                },
                \"tls_ciphers\": {},
                \"tls_vers\": {
                    \"value\": \"tls_1_2_tls_1_3\"
                }
            }
            " > /home/ubuntu/install/settings.json
            
            echo "
            {
                \"DaemonAuthenticationType\":     \"password\",
                \"DaemonAuthenticationPassword\": \"Password1#\",
                \"TlsBootstrapType\":             \"server-path\",
                \"TlsBootstrapHostname\":         \"${hostname}\",
                \"ReleaseSequence\":         ${release_sequence},
                \"TlsBootstrapCert\":             \"/home/ubuntu/install/server.crt\",
                \"TlsBootstrapKey\":              \"/home/ubuntu/install/server.key\",
                \"BypassPreflightChecks\":        true,
                \"ImportSettingsFrom\":           \"/home/ubuntu/install/settings.json\",
                \"LicenseFileLocation\":          \"/home/ubuntu/install/license.rli\"
            }" > /home/ubuntu/install/replicated.conf
            echo "${cert_pem}" > /home/ubuntu/install/server.crt
            echo "${key_pem}" > /home/ubuntu/install/server.key
            IPADDR=$(hostname -I | awk '{print $1}')
            echo "#!/usr/bin/env bash
            chmod 600 /home/ubuntu/install/server.key
            cd /home/ubuntu/install
            aws s3 cp s3://aakulov-aws9-tfe-tfe . --recursive
            curl -# -o /home/ubuntu/install/install.sh https://install.terraform.io/ptfe/stable
            chmod +x install.sh
            sudo rm -rf /usr/share/keyrings/docker-archive-keyring.gpg
            cp /home/ubuntu/install/replicated.conf /etc/replicated.conf
            cp /home/ubuntu/install/replicated.conf /root/replicated.conf
            chown -R ubuntu: /home/ubuntu/install
            
            aws configure set aws_access_key_id ${minio_access_key}
            aws configure set aws_secret_access_key ${minio_secret_key}
            
            aws s3api create-bucket --acl private --bucket ${s3bucket}  --endpoint-url ${s3endpoint}
            aws s3 ls s3://${s3bucket}  --endpoint-url ${s3endpoint}
            
            yes | sudo /usr/bin/bash /home/ubuntu/install/install.sh no-proxy private-address=$IPADDR public-address=$IPADDR
            exit 0
            " > /home/ubuntu/install/install_tfe.sh
            
            echo "#!/usr/bin/env bash
              set -x
              date
              # health check until app becomes ready
              while ! curl -ksfS --connect-timeout 5 \"https://$IPADDR/_health_check\"; do
                sleep 5
              done
              date
            " > /home/ubuntu/install/healthcheck.sh
            
            echo "{
              \"debug\": true
            }
            " > /home/ubuntu/install/daemon.json 
            
            sudo cp /home/ubuntu/install/daemon.json /etc/docker/deamon.json
            
            chmod +x /home/ubuntu/install/install_tfe.sh
            chmod +x /home/ubuntu/install/healthcheck.sh
            
            sh /home/ubuntu/install/healthcheck.sh &> /home/ubuntu/install/hc_tfe.log &
            
            sh /home/ubuntu/install/install_tfe.sh &> /home/ubuntu/install/install_tfe.log
        EOT
      + vars     = {
          + "cert_pem"         = (sensitive)
          + "enc_password"     = (sensitive)
          + "hostname"         = "tfe9.akulov.cc"
          + "key_pem"          = (sensitive)
          + "minio_access_key" = (sensitive)
          + "minio_secret_key" = (sensitive)
          + "pgsqlhostname"    = (known after apply)
          + "pgsqlpassword"    = (sensitive)
          + "pguser"           = "postgres"
          + "release_sequence" = "607"
          + "s3bucket"         = "aakulov-aws9-tfe-data"
          + "s3endpoint"       = (known after apply)
          + "s3region"         = "eu-central-1"
        }
    }

  # aws_acm_certificate.aws9 will be created
  + resource "aws_acm_certificate" "aws9" {
      + arn                       = (known after apply)
      + certificate_body          = (sensitive)
      + certificate_chain         = (sensitive)
      + domain_name               = (known after apply)
      + domain_validation_options = (known after apply)
      + id                        = (known after apply)
      + private_key               = (sensitive value)
      + status                    = (known after apply)
      + subject_alternative_names = (known after apply)
      + tags_all                  = (known after apply)
      + validation_emails         = (known after apply)
      + validation_method         = (known after apply)
    }

  # aws_db_instance.aws9 will be created
  + resource "aws_db_instance" "aws9" {
      + address                               = (known after apply)
      + allocated_storage                     = 20
      + apply_immediately                     = (known after apply)
      + arn                                   = (known after apply)
      + auto_minor_version_upgrade            = true
      + availability_zone                     = (known after apply)
      + backup_retention_period               = (known after apply)
      + backup_window                         = (known after apply)
      + ca_cert_identifier                    = (known after apply)
      + character_set_name                    = (known after apply)
      + copy_tags_to_snapshot                 = false
      + db_name                               = "mydbtfe"
      + db_subnet_group_name                  = "aakulov-aws9"
      + delete_automated_backups              = true
      + endpoint                              = (known after apply)
      + engine                                = "postgres"
      + engine_version                        = "12.7"
      + engine_version_actual                 = (known after apply)
      + hosted_zone_id                        = (known after apply)
      + id                                    = (known after apply)
      + identifier                            = (known after apply)
      + identifier_prefix                     = (known after apply)
      + instance_class                        = "db.t3.medium"
      + kms_key_id                            = (known after apply)
      + latest_restorable_time                = (known after apply)
      + license_model                         = (known after apply)
      + maintenance_window                    = (known after apply)
      + max_allocated_storage                 = 100
      + monitoring_interval                   = 0
      + monitoring_role_arn                   = (known after apply)
      + multi_az                              = (known after apply)
      + name                                  = (known after apply)
      + nchar_character_set_name              = (known after apply)
      + option_group_name                     = (known after apply)
      + parameter_group_name                  = (known after apply)
      + password                              = (sensitive value)
      + performance_insights_enabled          = false
      + performance_insights_kms_key_id       = (known after apply)
      + performance_insights_retention_period = (known after apply)
      + port                                  = (known after apply)
      + publicly_accessible                   = false
      + replica_mode                          = (known after apply)
      + replicas                              = (known after apply)
      + resource_id                           = (known after apply)
      + skip_final_snapshot                   = true
      + snapshot_identifier                   = (known after apply)
      + status                                = (known after apply)
      + storage_type                          = (known after apply)
      + tags                                  = {
          + "Name" = "aakulov-aws9"
        }
      + tags_all                              = {
          + "Name" = "aakulov-aws9"
        }
      + timezone                              = (known after apply)
      + username                              = "postgres"
      + vpc_security_group_ids                = (known after apply)
    }

  # aws_db_subnet_group.aws9 will be created
  + resource "aws_db_subnet_group" "aws9" {
      + arn         = (known after apply)
      + description = "Managed by Terraform"
      + id          = (known after apply)
      + name        = "aakulov-aws9"
      + name_prefix = (known after apply)
      + subnet_ids  = (known after apply)
      + tags        = {
          + "Name" = "aakulov-aws9"
        }
      + tags_all    = {
          + "Name" = "aakulov-aws9"
        }
    }

  # aws_eip.aws9 will be created
  + resource "aws_eip" "aws9" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags_all             = (known after apply)
      + vpc                  = true
    }

  # aws_eip.aws9jump will be created
  + resource "aws_eip" "aws9jump" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags_all             = (known after apply)
      + vpc                  = true
    }

  # aws_eip.aws9nat will be created
  + resource "aws_eip" "aws9nat" {
      + allocation_id        = (known after apply)
      + association_id       = (known after apply)
      + carrier_ip           = (known after apply)
      + customer_owned_ip    = (known after apply)
      + domain               = (known after apply)
      + id                   = (known after apply)
      + instance             = (known after apply)
      + network_border_group = (known after apply)
      + network_interface    = (known after apply)
      + private_dns          = (known after apply)
      + private_ip           = (known after apply)
      + public_dns           = (known after apply)
      + public_ip            = (known after apply)
      + public_ipv4_pool     = (known after apply)
      + tags_all             = (known after apply)
      + vpc                  = true
    }

  # aws_eip_association.aws9 will be created
  + resource "aws_eip_association" "aws9" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip_address   = (known after apply)
      + public_ip            = (known after apply)
    }

  # aws_eip_association.aws9jump will be created
  + resource "aws_eip_association" "aws9jump" {
      + allocation_id        = (known after apply)
      + id                   = (known after apply)
      + instance_id          = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip_address   = (known after apply)
      + public_ip            = (known after apply)
    }

  # aws_iam_instance_profile.aakulov-aws9-ec2-s3 will be created
  + resource "aws_iam_instance_profile" "aakulov-aws9-ec2-s3" {
      + arn         = (known after apply)
      + create_date = (known after apply)
      + id          = (known after apply)
      + name        = "aakulov-aws9-ec2-s3"
      + path        = "/"
      + role        = "aakulov-aws9-iam-role-ec2-s3"
      + tags_all    = (known after apply)
      + unique_id   = (known after apply)
    }

  # aws_iam_role.aakulov-aws9-iam-role-ec2-s3 will be created
  + resource "aws_iam_role" "aakulov-aws9-iam-role-ec2-s3" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ec2.amazonaws.com"
                        }
                      + Sid       = ""
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "aakulov-aws9-iam-role-ec2-s3"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags                  = {
          + "tag-key" = "aakulov-aws9-iam-role-ec2-s3"
        }
      + tags_all              = {
          + "tag-key" = "aakulov-aws9-iam-role-ec2-s3"
        }
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = (known after apply)
          + policy = (known after apply)
        }
    }

  # aws_iam_role_policy.aakulov-aws9-ec2-s3 will be created
  + resource "aws_iam_role_policy" "aakulov-aws9-ec2-s3" {
      + id     = (known after apply)
      + name   = "aakulov-aws9-ec2-s3"
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action   = [
                          + "s3:DeleteObject",
                          + "s3:GetObject",
                          + "s3:PutObject",
                          + "s3:GetBucketLocation",
                          + "s3:ListBucket",
                        ]
                      + Effect   = "Allow"
                      + Resource = "*"
                      + Sid      = "VisualEditor0"
                    },
                  + {
                      + Action   = "s3:*"
                      + Effect   = "Allow"
                      + Resource = "arn:aws:s3:::aakulov-aws9-tfe-tfe"
                      + Sid      = "VisualEditor1"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + role   = (known after apply)
    }

  # aws_instance.aws9 will be created
  + resource "aws_instance" "aws9" {
      + ami                                  = "ami-086128e34136c3375"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.2xlarge"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aakulov"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "aakulov-aws9"
        }
      + tags_all                             = {
          + "Name" = "aakulov-aws9"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id                 = (known after apply)
              + capacity_reservation_resource_group_arn = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = "enabled"
          + http_put_response_hop_limit = 2
          + http_tokens                 = "required"
          + instance_metadata_tags      = "disabled"
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_card_index    = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_instance.aws9_minio will be created
  + resource "aws_instance" "aws9_minio" {
      + ami                                  = "ami-0b5de643012fe5385"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.large"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aakulov"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "aakulov-aws9-minio"
        }
      + tags_all                             = {
          + "Name" = "aakulov-aws9-minio"
        }
      + tenancy                              = (known after apply)
      + user_data                            = "5091584e22574e4a9da1dcb2148ed69c20e2bd05"
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id                 = (known after apply)
              + capacity_reservation_resource_group_arn = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = "enabled"
          + http_put_response_hop_limit = (known after apply)
          + http_tokens                 = "required"
          + instance_metadata_tags      = "disabled"
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_card_index    = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_instance.aws9jump will be created
  + resource "aws_instance" "aws9jump" {
      + ami                                  = "ami-086128e34136c3375"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = true
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t3.medium"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = "aakulov"
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "aakulov-aws9jump"
        }
      + tags_all                             = {
          + "Name" = "aakulov-aws9jump"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)

      + capacity_reservation_specification {
          + capacity_reservation_preference = (known after apply)

          + capacity_reservation_target {
              + capacity_reservation_id                 = (known after apply)
              + capacity_reservation_resource_group_arn = (known after apply)
            }
        }

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + snapshot_id           = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + enclave_options {
          + enabled = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + metadata_options {
          + http_endpoint               = "enabled"
          + http_put_response_hop_limit = 2
          + http_tokens                 = "required"
          + instance_metadata_tags      = "disabled"
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_card_index    = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + kms_key_id            = (known after apply)
          + tags                  = (known after apply)
          + throughput            = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_internet_gateway.igw will be created
  + resource "aws_internet_gateway" "igw" {
      + arn      = (known after apply)
      + id       = (known after apply)
      + owner_id = (known after apply)
      + tags     = {
          + "Name" = "aakulov-aws9"
        }
      + tags_all = {
          + "Name" = "aakulov-aws9"
        }
      + vpc_id   = (known after apply)
    }

  # aws_lb.aws9 will be created
  + resource "aws_lb" "aws9" {
      + arn                        = (known after apply)
      + arn_suffix                 = (known after apply)
      + desync_mitigation_mode     = "defensive"
      + dns_name                   = (known after apply)
      + drop_invalid_header_fields = false
      + enable_deletion_protection = false
      + enable_http2               = false
      + enable_waf_fail_open       = false
      + id                         = (known after apply)
      + idle_timeout               = 60
      + internal                   = false
      + ip_address_type            = (known after apply)
      + load_balancer_type         = "application"
      + name                       = "aakulov-aws9"
      + security_groups            = (known after apply)
      + subnets                    = (known after apply)
      + tags_all                   = (known after apply)
      + vpc_id                     = (known after apply)
      + zone_id                    = (known after apply)

      + subnet_mapping {
          + allocation_id        = (known after apply)
          + ipv6_address         = (known after apply)
          + outpost_id           = (known after apply)
          + private_ipv4_address = (known after apply)
          + subnet_id            = (known after apply)
        }
    }

  # aws_lb_listener.aws9-443 will be created
  + resource "aws_lb_listener" "aws9-443" {
      + arn               = (known after apply)
      + certificate_arn   = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 443
      + protocol          = "HTTPS"
      + ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener.aws9-8800 will be created
  + resource "aws_lb_listener" "aws9-8800" {
      + arn               = (known after apply)
      + certificate_arn   = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 8800
      + protocol          = "HTTPS"
      + ssl_policy        = "ELBSecurityPolicy-FS-1-2-Res-2020-10"
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_listener_rule.aws9-443 will be created
  + resource "aws_lb_listener_rule" "aws9-443" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + listener_arn = (known after apply)
      + priority     = (known after apply)
      + tags_all     = (known after apply)

      + action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + condition {
          + host_header {
              + values = [
                  + "tfe9.akulov.cc",
                ]
            }
        }
    }

  # aws_lb_listener_rule.aws9-8800 will be created
  + resource "aws_lb_listener_rule" "aws9-8800" {
      + arn          = (known after apply)
      + id           = (known after apply)
      + listener_arn = (known after apply)
      + priority     = (known after apply)
      + tags_all     = (known after apply)

      + action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }

      + condition {
          + host_header {
              + values = [
                  + "tfe9.akulov.cc",
                ]
            }
        }
    }

  # aws_lb_target_group.aws9-443 will be created
  + resource "aws_lb_target_group" "aws9-443" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-aws9-443"
      + port                               = 443
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTPS"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 900
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = true
          + healthy_threshold   = 6
          + interval            = 5
          + matcher             = "200,302,303"
          + path                = "/"
          + port                = "8800"
          + protocol            = "HTTPS"
          + timeout             = 2
          + unhealthy_threshold = 2
        }

      + stickiness {
          + cookie_duration = 86400
          + enabled         = true
          + type            = "lb_cookie"
        }
    }

  # aws_lb_target_group.aws9-8800 will be created
  + resource "aws_lb_target_group" "aws9-8800" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + name                               = "aakulov-aws9-8800"
      + port                               = 8800
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTPS"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 900
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = (known after apply)

      + health_check {
          + enabled             = true
          + healthy_threshold   = 6
          + interval            = 5
          + matcher             = "200,302,303"
          + path                = "/"
          + port                = "8800"
          + protocol            = "HTTPS"
          + timeout             = 2
          + unhealthy_threshold = 2
        }

      + stickiness {
          + cookie_duration = 86400
          + enabled         = true
          + type            = "lb_cookie"
        }
    }

  # aws_lb_target_group_attachment.aws9-443 will be created
  + resource "aws_lb_target_group_attachment" "aws9-443" {
      + id               = (known after apply)
      + port             = 443
      + target_group_arn = (known after apply)
      + target_id        = (known after apply)
    }

  # aws_lb_target_group_attachment.aws9-8800 will be created
  + resource "aws_lb_target_group_attachment" "aws9-8800" {
      + id               = (known after apply)
      + port             = 8800
      + target_group_arn = (known after apply)
      + target_id        = (known after apply)
    }

  # aws_nat_gateway.nat will be created
  + resource "aws_nat_gateway" "nat" {
      + allocation_id        = (known after apply)
      + connectivity_type    = "public"
      + id                   = (known after apply)
      + network_interface_id = (known after apply)
      + private_ip           = (known after apply)
      + public_ip            = (known after apply)
      + subnet_id            = (known after apply)
      + tags                 = {
          + "Name" = "aakulov-aws9"
        }
      + tags_all             = {
          + "Name" = "aakulov-aws9"
        }
    }

  # aws_route_table.aws9-private will be created
  + resource "aws_route_table" "aws9-private" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = "0.0.0.0/0"
              + core_network_arn           = ""
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = ""
              + instance_id                = ""
              + ipv6_cidr_block            = ""
              + local_gateway_id           = ""
              + nat_gateway_id             = (known after apply)
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
        ]
      + tags             = {
          + "Name" = "aakulov-aws9-private"
        }
      + tags_all         = {
          + "Name" = "aakulov-aws9-private"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table.aws9-public will be created
  + resource "aws_route_table" "aws9-public" {
      + arn              = (known after apply)
      + id               = (known after apply)
      + owner_id         = (known after apply)
      + propagating_vgws = (known after apply)
      + route            = [
          + {
              + carrier_gateway_id         = ""
              + cidr_block                 = "0.0.0.0/0"
              + core_network_arn           = ""
              + destination_prefix_list_id = ""
              + egress_only_gateway_id     = ""
              + gateway_id                 = (known after apply)
              + instance_id                = ""
              + ipv6_cidr_block            = ""
              + local_gateway_id           = ""
              + nat_gateway_id             = ""
              + network_interface_id       = ""
              + transit_gateway_id         = ""
              + vpc_endpoint_id            = ""
              + vpc_peering_connection_id  = ""
            },
        ]
      + tags             = {
          + "Name" = "aakulov-aws9-public"
        }
      + tags_all         = {
          + "Name" = "aakulov-aws9-public"
        }
      + vpc_id           = (known after apply)
    }

  # aws_route_table_association.aws9-private will be created
  + resource "aws_route_table_association" "aws9-private" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_route_table_association.aws9-public will be created
  + resource "aws_route_table_association" "aws9-public" {
      + id             = (known after apply)
      + route_table_id = (known after apply)
      + subnet_id      = (known after apply)
    }

  # aws_security_group.aws9-internal-sg will be created
  + resource "aws_security_group" "aws9-internal-sg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = -1
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "icmp"
              + security_groups  = []
              + self             = false
              + to_port          = -1
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8800
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8800
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = true
              + to_port          = 443
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 5432
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = true
              + to_port          = 5432
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 8800
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = (known after apply)
              + self             = false
              + to_port          = 8800
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 8800
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = true
              + to_port          = 8800
            },
          + {
              + cidr_blocks      = []
              + description      = ""
              + from_port        = 9000
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = true
              + to_port          = 9000
            },
        ]
      + name                   = "aakulov-aws9-internal-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "aakulov-aws9-internal-sg"
        }
      + tags_all               = {
          + "Name" = "aakulov-aws9-internal-sg"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group.aws9-lb-sg will be created
  + resource "aws_security_group" "aws9-lb-sg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8800
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8800
            },
        ]
      + name                   = "aakulov-aws9-lb-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "aakulov-aws9-lb-sg"
        }
      + tags_all               = {
          + "Name" = "aakulov-aws9-lb-sg"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group.aws9-public-sg will be created
  + resource "aws_security_group" "aws9-public-sg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 443
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 443
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8800
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8800
            },
        ]
      + name                   = "aakulov-aws9-public-sg"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags                   = {
          + "Name" = "aakulov-aws9-public-sg"
        }
      + tags_all               = {
          + "Name" = "aakulov-aws9-public-sg"
        }
      + vpc_id                 = (known after apply)
    }

  # aws_security_group_rule.aws9-lb-sg-to-aws9-internal-sg-allow-443 will be created
  + resource "aws_security_group_rule" "aws9-lb-sg-to-aws9-internal-sg-allow-443" {
      + from_port                = 443
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 443
      + type                     = "egress"
    }

  # aws_security_group_rule.aws9-lb-sg-to-aws9-internal-sg-allow-8800 will be created
  + resource "aws_security_group_rule" "aws9-lb-sg-to-aws9-internal-sg-allow-8800" {
      + from_port                = 8800
      + id                       = (known after apply)
      + protocol                 = "tcp"
      + security_group_id        = (known after apply)
      + self                     = false
      + source_security_group_id = (known after apply)
      + to_port                  = 8800
      + type                     = "egress"
    }

  # aws_subnet.subnet_private1 will be created
  + resource "aws_subnet" "subnet_private1" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-central-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.5.1.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags_all                                       = (known after apply)
      + vpc_id                                         = (known after apply)
    }

  # aws_subnet.subnet_private2 will be created
  + resource "aws_subnet" "subnet_private2" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-central-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.5.3.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags_all                                       = (known after apply)
      + vpc_id                                         = (known after apply)
    }

  # aws_subnet.subnet_public1 will be created
  + resource "aws_subnet" "subnet_public1" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-central-1b"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.5.2.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags_all                                       = (known after apply)
      + vpc_id                                         = (known after apply)
    }

  # aws_subnet.subnet_public2 will be created
  + resource "aws_subnet" "subnet_public2" {
      + arn                                            = (known after apply)
      + assign_ipv6_address_on_creation                = false
      + availability_zone                              = "eu-central-1c"
      + availability_zone_id                           = (known after apply)
      + cidr_block                                     = "10.5.4.0/24"
      + enable_dns64                                   = false
      + enable_resource_name_dns_a_record_on_launch    = false
      + enable_resource_name_dns_aaaa_record_on_launch = false
      + id                                             = (known after apply)
      + ipv6_cidr_block_association_id                 = (known after apply)
      + ipv6_native                                    = false
      + map_public_ip_on_launch                        = false
      + owner_id                                       = (known after apply)
      + private_dns_hostname_type_on_launch            = (known after apply)
      + tags_all                                       = (known after apply)
      + vpc_id                                         = (known after apply)
    }

  # aws_vpc.vpc will be created
  + resource "aws_vpc" "vpc" {
      + arn                                  = (known after apply)
      + cidr_block                           = "10.5.0.0/16"
      + default_network_acl_id               = (known after apply)
      + default_route_table_id               = (known after apply)
      + default_security_group_id            = (known after apply)
      + dhcp_options_id                      = (known after apply)
      + enable_classiclink                   = (known after apply)
      + enable_classiclink_dns_support       = (known after apply)
      + enable_dns_hostnames                 = true
      + enable_dns_support                   = true
      + id                                   = (known after apply)
      + instance_tenancy                     = "default"
      + ipv6_association_id                  = (known after apply)
      + ipv6_cidr_block                      = (known after apply)
      + ipv6_cidr_block_network_border_group = (known after apply)
      + main_route_table_id                  = (known after apply)
      + owner_id                             = (known after apply)
      + tags                                 = {
          + "Name" = "aakulov-aws9"
        }
      + tags_all                             = {
          + "Name" = "aakulov-aws9"
        }
    }

  # cloudflare_record.aws9 will be created
  + resource "cloudflare_record" "aws9" {
      + allow_overwrite = false
      + created_on      = (known after apply)
      + hostname        = (known after apply)
      + id              = (known after apply)
      + metadata        = (known after apply)
      + modified_on     = (known after apply)
      + name            = "tfe9.akulov.cc"
      + proxiable       = (known after apply)
      + proxied         = false
      + ttl             = 1
      + type            = "CNAME"
      + value           = (known after apply)
      + zone_id         = (sensitive)
    }

  # cloudflare_record.aws9jump will be created
  + resource "cloudflare_record" "aws9jump" {
      + allow_overwrite = false
      + created_on      = (known after apply)
      + hostname        = (known after apply)
      + id              = (known after apply)
      + metadata        = (known after apply)
      + modified_on     = (known after apply)
      + name            = "tfe9jump.akulov.cc"
      + proxiable       = (known after apply)
      + proxied         = false
      + ttl             = 1
      + type            = "A"
      + value           = (known after apply)
      + zone_id         = (sensitive)
    }

Plan: 41 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + aws_jump        = "tfe9jump.akulov.cc"
  + aws_url         = "tfe9.akulov.cc"
  + ec2_instance_ip = (known after apply)

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_acm_certificate.aws9: Creating...
aws_vpc.vpc: Creating...
aws_iam_role.aakulov-aws9-iam-role-ec2-s3: Creating...
aws_acm_certificate.aws9: Creation complete after 1s [id=arn:aws:acm:eu-central-1:267023797923:certificate/9d008b24-afdd-41cf-8f41-80f8d3ec2270]
aws_iam_role.aakulov-aws9-iam-role-ec2-s3: Creation complete after 1s [id=aakulov-aws9-iam-role-ec2-s3]
aws_iam_role_policy.aakulov-aws9-ec2-s3: Creating...
aws_iam_instance_profile.aakulov-aws9-ec2-s3: Creating...
aws_iam_role_policy.aakulov-aws9-ec2-s3: Creation complete after 1s [id=aakulov-aws9-iam-role-ec2-s3:aakulov-aws9-ec2-s3]
aws_iam_instance_profile.aakulov-aws9-ec2-s3: Creation complete after 1s [id=aakulov-aws9-ec2-s3]
aws_vpc.vpc: Still creating... [10s elapsed]
aws_vpc.vpc: Creation complete after 12s [id=vpc-015ea87bb48f3d6e5]
aws_internet_gateway.igw: Creating...
aws_subnet.subnet_public1: Creating...
aws_subnet.subnet_public2: Creating...
aws_subnet.subnet_private1: Creating...
aws_subnet.subnet_private2: Creating...
aws_lb_target_group.aws9-8800: Creating...
aws_lb_target_group.aws9-443: Creating...
aws_security_group.aws9-lb-sg: Creating...
aws_security_group.aws9-public-sg: Creating...
aws_lb_target_group.aws9-8800: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-aws9-8800/3b6b4bd117b5b40b]
aws_subnet.subnet_private2: Creation complete after 0s [id=subnet-076d136d7f576de14]
aws_subnet.subnet_private1: Creation complete after 0s [id=subnet-0fa2844340ae575f7]
aws_subnet.subnet_public2: Creation complete after 0s [id=subnet-00bff5b63829eed95]
aws_subnet.subnet_public1: Creation complete after 0s [id=subnet-033c30ebf241b2814]
aws_db_subnet_group.aws9: Creating...
aws_internet_gateway.igw: Creation complete after 0s [id=igw-0bae6d5b7ec35b9e6]
aws_eip.aws9nat: Creating...
aws_route_table.aws9-public: Creating...
aws_lb_target_group.aws9-443: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-aws9-443/f146c34b60af78ee]
aws_eip.aws9nat: Creation complete after 1s [id=eipalloc-0ddce7177b0a3c847]
aws_nat_gateway.nat: Creating...
aws_route_table.aws9-public: Creation complete after 1s [id=rtb-0f629260426cec71a]
aws_route_table_association.aws9-public: Creating...
aws_security_group.aws9-lb-sg: Creation complete after 1s [id=sg-0e169cde357205f1f]
aws_lb.aws9: Creating...
aws_route_table_association.aws9-public: Creation complete after 1s [id=rtbassoc-09d851b220b1a368a]
aws_db_subnet_group.aws9: Creation complete after 2s [id=aakulov-aws9]
aws_security_group.aws9-public-sg: Creation complete after 2s [id=sg-02f693687e45055d0]
aws_instance.aws9jump: Creating...
aws_security_group.aws9-internal-sg: Creating...
aws_security_group.aws9-internal-sg: Creation complete after 2s [id=sg-093c7553e29399b46]
aws_security_group_rule.aws9-lb-sg-to-aws9-internal-sg-allow-8800: Creating...
aws_security_group_rule.aws9-lb-sg-to-aws9-internal-sg-allow-443: Creating...
aws_db_instance.aws9: Creating...
aws_instance.aws9_minio: Creating...
aws_security_group_rule.aws9-lb-sg-to-aws9-internal-sg-allow-8800: Creation complete after 0s [id=sgrule-1385780569]
aws_security_group_rule.aws9-lb-sg-to-aws9-internal-sg-allow-443: Creation complete after 1s [id=sgrule-2471841748]
aws_nat_gateway.nat: Still creating... [10s elapsed]
aws_lb.aws9: Still creating... [10s elapsed]
aws_instance.aws9jump: Still creating... [10s elapsed]
aws_instance.aws9_minio: Still creating... [10s elapsed]
aws_db_instance.aws9: Still creating... [10s elapsed]
aws_instance.aws9jump: Creation complete after 12s [id=i-0d0ca057a108b68ce]
aws_eip.aws9jump: Creating...
aws_eip.aws9jump: Creation complete after 1s [id=eipalloc-096309d4d9167f3b7]
aws_eip_association.aws9jump: Creating...
cloudflare_record.aws9jump: Creating...
aws_eip_association.aws9jump: Creation complete after 1s [id=eipassoc-0da3e83ef497b7117]
aws_instance.aws9_minio: Creation complete after 13s [id=i-04c4ec52c65aa4fca]
cloudflare_record.aws9jump: Creation complete after 2s [id=4517e5bcd28cad69bc85f99b8dc5ec20]
aws_nat_gateway.nat: Still creating... [20s elapsed]
aws_lb.aws9: Still creating... [20s elapsed]
aws_db_instance.aws9: Still creating... [20s elapsed]
aws_nat_gateway.nat: Still creating... [30s elapsed]
aws_lb.aws9: Still creating... [30s elapsed]
aws_db_instance.aws9: Still creating... [30s elapsed]
aws_nat_gateway.nat: Still creating... [40s elapsed]
aws_lb.aws9: Still creating... [40s elapsed]
aws_db_instance.aws9: Still creating... [40s elapsed]
aws_nat_gateway.nat: Still creating... [50s elapsed]
aws_lb.aws9: Still creating... [50s elapsed]
aws_db_instance.aws9: Still creating... [50s elapsed]
aws_nat_gateway.nat: Still creating... [1m0s elapsed]
aws_lb.aws9: Still creating... [1m0s elapsed]
aws_db_instance.aws9: Still creating... [1m0s elapsed]
aws_nat_gateway.nat: Still creating... [1m10s elapsed]
aws_lb.aws9: Still creating... [1m10s elapsed]
aws_db_instance.aws9: Still creating... [1m10s elapsed]
aws_nat_gateway.nat: Still creating... [1m20s elapsed]
aws_lb.aws9: Still creating... [1m20s elapsed]
aws_db_instance.aws9: Still creating... [1m20s elapsed]
aws_nat_gateway.nat: Still creating... [1m30s elapsed]
aws_lb.aws9: Still creating... [1m30s elapsed]
aws_db_instance.aws9: Still creating... [1m30s elapsed]
aws_nat_gateway.nat: Still creating... [1m40s elapsed]
aws_lb.aws9: Still creating... [1m40s elapsed]
aws_db_instance.aws9: Still creating... [1m40s elapsed]
aws_nat_gateway.nat: Creation complete after 1m44s [id=nat-0d56ec4e87073db2b]
aws_route_table.aws9-private: Creating...
aws_route_table.aws9-private: Creation complete after 1s [id=rtb-0b07c7bc673556fdb]
aws_route_table_association.aws9-private: Creating...
aws_route_table_association.aws9-private: Creation complete after 0s [id=rtbassoc-04a80e6797aec328c]
aws_lb.aws9: Still creating... [1m50s elapsed]
aws_db_instance.aws9: Still creating... [1m50s elapsed]
aws_lb.aws9: Still creating... [2m0s elapsed]
aws_db_instance.aws9: Still creating... [2m0s elapsed]
aws_lb.aws9: Still creating... [2m10s elapsed]
aws_db_instance.aws9: Still creating... [2m10s elapsed]
aws_lb.aws9: Still creating... [2m20s elapsed]
aws_db_instance.aws9: Still creating... [2m20s elapsed]
aws_lb.aws9: Still creating... [2m30s elapsed]
aws_db_instance.aws9: Still creating... [2m30s elapsed]
aws_lb.aws9: Still creating... [2m40s elapsed]
aws_db_instance.aws9: Still creating... [2m40s elapsed]
aws_lb.aws9: Still creating... [2m50s elapsed]
aws_db_instance.aws9: Still creating... [2m50s elapsed]
aws_db_instance.aws9: Creation complete after 2m54s [id=terraform-20220425135407071700000001]
data.template_file.install_tfe_minio_sh: Reading...
data.template_file.install_tfe_minio_sh: Read complete after 0s [id=e770a27bc741c88c530a49e6e102d681718ba2dfe52a5662ad85dc01b76a6d86]
data.template_cloudinit_config.aws9_cloudinit: Reading...
data.template_cloudinit_config.aws9_cloudinit: Read complete after 0s [id=2925402976]
aws_instance.aws9: Creating...
aws_lb.aws9: Still creating... [3m0s elapsed]
aws_lb.aws9: Creation complete after 3m1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:loadbalancer/app/aakulov-aws9/760143c5dbe787c5]
cloudflare_record.aws9: Creating...
aws_lb_listener.aws9-443: Creating...
aws_lb_listener.aws9-8800: Creating...
aws_lb_listener.aws9-443: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/app/aakulov-aws9/760143c5dbe787c5/92e7b712a550e713]
aws_lb_listener_rule.aws9-443: Creating...
aws_lb_listener.aws9-8800: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener/app/aakulov-aws9/760143c5dbe787c5/49424e067e9d6e38]
aws_lb_listener_rule.aws9-8800: Creating...
aws_lb_listener_rule.aws9-443: Creation complete after 1s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener-rule/app/aakulov-aws9/760143c5dbe787c5/92e7b712a550e713/c0d69eabb9a8f7fe]
aws_lb_listener_rule.aws9-8800: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:listener-rule/app/aakulov-aws9/760143c5dbe787c5/49424e067e9d6e38/0f4e141bfe336ecc]
cloudflare_record.aws9: Creation complete after 2s [id=0f077dda986718d766d8f107b83a18dd]
aws_instance.aws9: Still creating... [10s elapsed]
aws_instance.aws9: Creation complete after 12s [id=i-09e002a77fa21867a]
aws_lb_target_group_attachment.aws9-443: Creating...
aws_lb_target_group_attachment.aws9-8800: Creating...
aws_eip.aws9: Creating...
aws_lb_target_group_attachment.aws9-8800: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-aws9-8800/3b6b4bd117b5b40b-20220425135713175200000002]
aws_lb_target_group_attachment.aws9-443: Creation complete after 0s [id=arn:aws:elasticloadbalancing:eu-central-1:267023797923:targetgroup/aakulov-aws9-443/f146c34b60af78ee-20220425135713258800000003]
aws_eip.aws9: Creation complete after 1s [id=eipalloc-0c7ff98d8767b6692]
aws_eip_association.aws9: Creating...
aws_eip_association.aws9: Creation complete after 1s [id=eipassoc-04079c969699fad4a]

Apply complete! Resources: 41 added, 0 changed, 0 destroyed.

Outputs:

aws_jump = "tfe9jump.akulov.cc"
aws_url = "tfe9.akulov.cc"
ec2_instance_ip = "10.5.1.229"
```
