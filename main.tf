locals {
  s3endpoint           = format("http://%s:9000", aws_instance.aws9_minio.private_ip)
  s3endpointlocal      = "http://127.0.0.1:9000"
  friendly_name_prefix = random_string.friendly_name.id
  tfe_hostname         = "${local.friendly_name_prefix}${var.tfe_hostname}"
  tfe_jump_hostname    = "${local.friendly_name_prefix}${var.tfe_hostname_jump}"
}

resource "random_string" "friendly_name" {
  length  = 4
  upper   = false
  numeric = false
  special = false
}

provider "aws" {
  region = var.region
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9"
  }
}

resource "aws_subnet" "subnet_private1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet1
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "subnet_private2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet3
  availability_zone = "eu-central-1c"
}

resource "aws_subnet" "subnet_public1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet2
  availability_zone = "eu-central-1b"
}

resource "aws_subnet" "subnet_public2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.cidr_subnet4
  availability_zone = "eu-central-1c"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9"
  }
}

resource "aws_eip" "aws9" {
  vpc      = true
  instance = aws_instance.aws9.id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_eip" "aws9jump" {
  vpc      = true
  instance = aws_instance.aws9jump.id
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_eip" "aws9nat" {
  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.aws9nat.id
  subnet_id     = aws_subnet.subnet_public1.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9"
  }
}

resource "aws_route_table" "aws9-private" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9-private"
  }
}

resource "aws_route_table" "aws9-public" {
  vpc_id = aws_vpc.vpc.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9-public"
  }
}

resource "aws_route_table_association" "aws9-private" {
  subnet_id      = aws_subnet.subnet_private1.id
  route_table_id = aws_route_table.aws9-private.id
}

resource "aws_route_table_association" "aws9-public" {
  subnet_id      = aws_subnet.subnet_public1.id
  route_table_id = aws_route_table.aws9-public.id
}

resource "aws_security_group" "aws9-internal-sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.friendly_name_prefix}-aakulov-aws9-internal-sg"
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9-internal-sg"
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.aws9-lb-sg.id]
  }

  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 8800
    to_port         = 8800
    protocol        = "tcp"
    security_groups = [aws_security_group.aws9-lb-sg.id]
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 9000
    to_port   = 9000
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 8800
    to_port   = 8800
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    self      = true
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.aws9-public-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "aws9-public-sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.friendly_name_prefix}-aakulov-aws9-public-sg"
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9-public-sg"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_route53_zone" "aws9" {
  name         = var.domain_name
  private_zone = false
}

resource "cloudflare_record" "aws9" {
  zone_id = var.cloudflare_zone_id
  name    = local.tfe_hostname
  type    = "CNAME"
  ttl     = 1
  value   = aws_lb.aws9.dns_name
}

resource "cloudflare_record" "aws9jump" {
  zone_id    = var.cloudflare_zone_id
  name       = local.tfe_jump_hostname
  type       = "A"
  ttl        = 1
  value      = aws_eip.aws9jump.public_ip
  depends_on = [aws_instance.aws9jump, aws_eip.aws9jump]
}

resource "aws_db_subnet_group" "aws9" {
  name       = "${local.friendly_name_prefix}-aakulov-aws9"
  subnet_ids = [aws_subnet.subnet_public1.id, aws_subnet.subnet_public2.id, aws_subnet.subnet_private1.id, aws_subnet.subnet_private2.id]
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9"
  }
}

resource "aws_db_instance" "aws9" {
  allocated_storage      = 20
  max_allocated_storage  = 100
  engine                 = "postgres"
  engine_version         = var.engine_version
  db_name                = "mydbtfe"
  username               = "postgres"
  password               = var.db_password
  instance_class         = var.db_instance_type
  db_subnet_group_name   = aws_db_subnet_group.aws9.name
  vpc_security_group_ids = [aws_security_group.aws9-internal-sg.id]
  skip_final_snapshot    = true
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9"
  }
}

data "template_file" "configure_minio_sh" {
  template = file("templates/configure_minio.sh.tpl")
  vars = {
    minio_secret_key = var.minio_secret_key
    minio_access_key = var.minio_access_key
    s3bucket         = var.s3_bucket
  }
}

data "template_cloudinit_config" "aws9_minio_cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "configure_minio.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.configure_minio_sh.rendered
  }
}

resource "aws_instance" "aws9_minio" {
  ami                         = var.ami_minio
  instance_type               = var.instance_type_minio
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.aws9-internal-sg.id]
  subnet_id                   = aws_subnet.subnet_private1.id
  associate_public_ip_address = true
  user_data                   = data.template_cloudinit_config.aws9_minio_cloudinit.rendered
  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9-minio"
  }
}

data "local_sensitive_file" "sslcert" {
  filename = var.ssl_cert_path
}

data "local_sensitive_file" "sslkey" {
  filename = var.ssl_key_path
}

data "local_sensitive_file" "sslchain" {
  filename = var.ssl_chain_path
}

data "local_sensitive_file" "sslfullchaincert" {
  filename = var.ssl_fullchain_cert_path
}

data "template_file" "install_tfe_minio_sh" {
  template = file("templates/install_tfe_minio.sh.tpl")
  vars = {
    enc_password     = var.enc_password
    hostname         = local.tfe_hostname
    release_sequence = var.release_sequence
    pgsqlhostname    = aws_db_instance.aws9.address
    pgsqlpassword    = var.db_password
    pguser           = aws_db_instance.aws9.username
    s3bucket         = var.s3_bucket
    s3region         = var.region
    cert_pem         = data.local_sensitive_file.sslfullchaincert.content
    key_pem          = data.local_sensitive_file.sslkey.content
    minio_secret_key = var.minio_secret_key
    minio_access_key = var.minio_access_key
    s3endpoint       = local.s3endpoint
  }
}

data "template_cloudinit_config" "aws9_cloudinit" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "install_tfe.sh"
    content_type = "text/x-shellscript"
    content      = data.template_file.install_tfe_minio_sh.rendered
  }
}

resource "aws_instance" "aws9" {
  ami                         = var.ami
  instance_type               = var.instance_type
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.aws9-internal-sg.id]
  subnet_id                   = aws_subnet.subnet_private1.id
  associate_public_ip_address = true
  user_data                   = data.template_cloudinit_config.aws9_cloudinit.rendered
  iam_instance_profile        = aws_iam_instance_profile.aakulov-aws9-ec2-s3.id
  depends_on = [
    aws_instance.aws9_minio
  ]
  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9"
  }
}

resource "aws_eip_association" "aws9" {
  instance_id   = aws_instance.aws9.id
  allocation_id = aws_eip.aws9.id
}

resource "aws_eip_association" "aws9jump" {
  instance_id   = aws_instance.aws9jump.id
  allocation_id = aws_eip.aws9jump.id
}

resource "aws_instance" "aws9jump" {
  ami                         = var.ami
  instance_type               = var.instance_type_jump
  key_name                    = var.key_name
  vpc_security_group_ids      = [aws_security_group.aws9-public-sg.id]
  subnet_id                   = aws_subnet.subnet_public1.id
  associate_public_ip_address = true
  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 2
  }
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9jump"
  }
}

resource "aws_acm_certificate" "aws9" {
  private_key       = data.local_sensitive_file.sslkey.content
  certificate_body  = data.local_sensitive_file.sslcert.content
  certificate_chain = data.local_sensitive_file.sslchain.content
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "aws9-443" {
  name        = "${local.friendly_name_prefix}-aakulov-aws9-443"
  port        = 443
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  slow_start  = 900
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path                = "/"
    port                = 8800
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    protocol            = "HTTPS"
    matcher             = "200,302,303"
  }
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
}

resource "aws_lb_target_group" "aws9-8800" {
  name        = "${local.friendly_name_prefix}-aakulov-aws9-8800"
  port        = 8800
  protocol    = "HTTPS"
  vpc_id      = aws_vpc.vpc.id
  target_type = "instance"
  slow_start  = 900
  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path                = "/"
    port                = 8800
    healthy_threshold   = 6
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    protocol            = "HTTPS"
    matcher             = "200,302,303"
  }
  stickiness {
    enabled = true
    type    = "lb_cookie"
  }
}

resource "aws_lb" "aws9" {
  name                             = "${local.friendly_name_prefix}-aakulov-aws9"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.aws9-lb-sg.id]
  enable_cross_zone_load_balancing = true
  subnets                          = [aws_subnet.subnet_public1.id, aws_subnet.subnet_public2.id]
  enable_deletion_protection       = false
  enable_http2                     = false
}

resource "aws_lb_listener" "aws9-443" {
  load_balancer_arn = aws_lb.aws9.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.aws9.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  depends_on = [
    aws_lb.aws9
  ]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws9-443.arn
  }
}

resource "aws_lb_listener" "aws9-8800" {
  load_balancer_arn = aws_lb.aws9.arn
  port              = "8800"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.aws9.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  depends_on = [
    aws_lb.aws9
  ]
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws9-8800.arn
  }
}

resource "aws_lb_listener_rule" "aws9-8800" {
  listener_arn = aws_lb_listener.aws9-8800.arn
  condition {
    host_header {
      values = [local.tfe_hostname]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws9-8800.arn
  }
}

resource "aws_lb_listener_rule" "aws9-443" {
  listener_arn = aws_lb_listener.aws9-443.arn
  condition {
    host_header {
      values = [local.tfe_hostname]
    }
  }
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws9-443.arn
  }
}

resource "aws_lb_target_group_attachment" "aws9-443" {
  target_group_arn = aws_lb_target_group.aws9-443.arn
  target_id        = aws_instance.aws9.id
  port             = 443
}

resource "aws_lb_target_group_attachment" "aws9-8800" {
  target_group_arn = aws_lb_target_group.aws9-8800.arn
  target_id        = aws_instance.aws9.id
  port             = 8800
}

resource "aws_security_group" "aws9-lb-sg" {
  vpc_id = aws_vpc.vpc.id
  name   = "${local.friendly_name_prefix}-aakulov-aws9-lb-sg"
  tags = {
    Name = "${local.friendly_name_prefix}-aakulov-aws9-lb-sg"
  }

  ingress {
    from_port   = 8800
    to_port     = 8800
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Extra security group rules to avoid Cycle error

resource "aws_security_group_rule" "aws9-lb-sg-to-aws9-internal-sg-allow-443" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.aws9-internal-sg.id
  security_group_id        = aws_security_group.aws9-lb-sg.id
}

resource "aws_security_group_rule" "aws9-lb-sg-to-aws9-internal-sg-allow-8800" {
  type                     = "egress"
  from_port                = 8800
  to_port                  = 8800
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.aws9-internal-sg.id
  security_group_id        = aws_security_group.aws9-lb-sg.id
}

resource "aws_iam_instance_profile" "aakulov-aws9-ec2-s3" {
  name = "${local.friendly_name_prefix}-aakulov-aws9-ec2-s3"
  role = aws_iam_role.aakulov-aws9-iam-role-ec2-s3.name
}

resource "aws_iam_role_policy" "aakulov-aws9-ec2-s3" {
  name = "${local.friendly_name_prefix}-aakulov-aws9-ec2-s3"
  role = aws_iam_role.aakulov-aws9-iam-role-ec2-s3.id
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ],
        "Resource" : "*"
      },
      {
        "Sid" : "VisualEditor1",
        "Effect" : "Allow",
        "Action" : "s3:*",
        "Resource" : "arn:aws:s3:::aakulov-aws9-tfe-tfe"
      }
    ]
  })
}

resource "aws_iam_role" "aakulov-aws9-iam-role-ec2-s3" {
  name = "${local.friendly_name_prefix}-aakulov-aws9-iam-role-ec2-s3"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "${local.friendly_name_prefix}-aakulov-aws9-iam-role-ec2-s3"
  }
}


output "aws_jump" {
  value = cloudflare_record.aws9jump.name
}

output "aws_url" {
  value = cloudflare_record.aws9.name
}

output "ec2_instance_ip" {
  value = aws_instance.aws9.private_ip
}
