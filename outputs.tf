output "ec2_public_ip" {
  description = "EC2 고정 퍼블릭 IP"
  value = var.fixed_public_ip
}

output "ssh_keygen_reset_command" {
  description = "SSH Known Hosts 초기화 명령어"
  value       = "ssh-keygen -R ${var.fixed_public_ip}"
}

output "ssh_connect_command" {
  description = "SSH 접속 명령어"
  value       = "ssh -i ./baekgwa-blog-key.pem ubuntu@${var.fixed_public_ip}"
}