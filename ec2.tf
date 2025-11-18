############################################
# SSH KeyPair
############################################
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${path.module}/${var.key_public_file}")
}

############################################
# EC2 Instance - Application server
############################################
resource "aws_instance" "baekgwa_blog_application_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_application_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.baekgwa_ec2_profile.name

  user_data = templatefile("${path.module}/scripts/user_data.tpl", {
    set_timezone         = file("${path.module}/scripts/set-timezone.sh")
    install_docker       = file("${path.module}/scripts/install-docker.sh")
    install_git          = file("${path.module}/scripts/install-git.sh")
    install_nginx        = file("${path.module}/scripts/install-nginx-ssl.sh")
    install_database     = file("${path.module}/scripts/install-database.sh")
    install_aws_cli      = file("${path.module}/scripts/install-aws-cli.sh")
    register_backup_cron = file("${path.module}/scripts/register-backup-cron.sh")

    rdbms_root_password  = var.rdbms_root_password
    rdbms_username       = var.rdbms_username
    rdbms_password       = var.rdbms_password
    rdbms_port           = var.rdbms_port
    mysql_query_log_path = var.mysql_query_log_path
    redis_password       = var.redis_password
    redis_port           = var.redis_port
  })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = {
    Name = "baekgwa_blog-ec2"
  }
}

############################################
# EC2 Instance - ELK Server
############################################
resource "aws_instance" "baekgwa_blog_elk_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_elk_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.baekgwa_ec2_profile.name # 동일한 IAM 프로필 재활용

  # ELK 전용 user_data 템플릿 사용
  user_data = templatefile("${path.module}/scripts/user_data_elk.tpl", {
    set_timezone   = file("${path.module}/scripts/set-timezone.sh")
    install_docker = file("${path.module}/scripts/install-docker.sh")
    install_git    = file("${path.module}/scripts/install-git.sh")
    install_nginx  = file("${path.module}/scripts/install-nginx-elk-ssl.sh")
    install_elk    = file("${path.module}/scripts/install-elk.sh")

    elastic_search_port    = var.elastic_search_port
    kibana_port            = var.kibana_port
    logstash_port          = var.logstash_port
    elasticsearch_username = var.elasticsearch_username
    elasticsearch_password = var.elasticsearch_password
    elasticsearch_hosts    = var.elasticsearch_hosts
    kibana_username        = var.kibana_username
    kibana_password        = var.kibana_password
  })

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
  }

  tags = {
    Name = "baekgwa_blog-elk-ec2"
  }
}

############################################
# EIP Association - Application Server
############################################
resource "aws_eip_association" "baekgwa_blog_application_eip_assoc" {
  instance_id   = aws_instance.baekgwa_blog_application_server.id
  allocation_id = var.allocation_application_id
}

############################################
# EIP Association - ELK Server
############################################
resource "aws_eip_association" "baekgwa_blog_elk_eip_assoc" {
  instance_id   = aws_instance.baekgwa_blog_elk_server.id
  allocation_id = var.allocation_elk_id
}

############################################
# IAM Role for EC2 (S3 Access)
############################################
resource "aws_iam_role" "baekgwa_ec2_role" {
  name = "baekgwa-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# IAM Policy Attachment (S3 Full Access)
############################################
resource "aws_iam_role_policy_attachment" "baekgwa_ec2_s3_policy_attach" {
  role       = aws_iam_role.baekgwa_ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

############################################
# Instance Profile for EC2
############################################
resource "aws_iam_instance_profile" "baekgwa_ec2_profile" {
  name = "baekgwa-ec2-profile"
  role = aws_iam_role.baekgwa_ec2_role.name
}

############################################
# Route 53 Private Record for ELK (NEW)
############################################
resource "aws_route53_record" "elk_dns" {
  zone_id = aws_route53_zone.private.zone_id

  # Application 서버가 접속할 도메인 이름
  name = "elk.${aws_route53_zone.private.name}"

  type = "A" # IP 주소를 매핑하는 A 레코드
  ttl  = 300 # DNS 캐시 시간 (초)

  # ELK 인스턴스가 생성되면, 그 Private IP를 가져와서 레코드로 등록
  records = [aws_instance.baekgwa_blog_elk_server.private_ip]
}
