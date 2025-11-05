variable "instance_type" {
  description = "EC2 인스턴스 타입"
  type        = string
  default     = "t3.small"
}

variable "key_name" {
  description = "AWS 키페어 이름"
  type        = string
  default     = "baekgwa-blog-key"
}

variable "key_public_file" {
  description = "SSH 공개키 파일 경로"
  type        = string
  default     = "baekgwa-blog-key.pem.pub"
}

variable "allowed_ssh_cidr" {
  description = "SSH 허용할 IP 대역"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_http_cidr" {
  description = "8080 포트 허용할 IP 대역"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ami_id" {
  description = "EC2 인스턴스에 사용할 AMI ID"
  type        = string
  default     = "ami-0d5bb3742db8fc264" # 네가 쓴 Ubuntu AMI ID
}

variable "allocation_id" {
  description = "수동 발급 Elastic IP의 Allocation ID"
  type        = string
  default     = "eipalloc-0901c0f075353fcee"
}

variable "fixed_public_ip" {
  description = "고정 퍼블릭 IP 주소"
  type        = string
  default     = "13.209.208.83"
}

variable "root_volume_size" {
  description = "루트 볼륨 사이즈"
  type        = number
  default     = 20
}

variable "root_volume_type" {
  description = "루트 볼륨 타입"
  type        = string
  default     = "gp3"
}

# tfvars
variable "rdbms_root_password" {}
variable "rdbms_username" {}
variable "rdbms_password" {}
variable "rdbms_port" {}
variable "mysql_query_log_path" {}
variable "redis_password" {}
variable "redis_port" {}
