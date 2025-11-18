output "ec2_application_public_ip" {
  description = "Application Server 고정 퍼블릭 IP"
  value = var.fixed_application_public_ip
}

output "ec2_elk_public_ip" {
  description = "Elk Server 고정 퍼블릭 IP"
  value = var.fixed_elk_public_ip
}

output "application_server_ssh_keygen_reset_command" {
  description = "Application Server SSH Known Hosts 초기화 명령어"
  value       = "ssh-keygen -R ${var.fixed_application_public_ip}"
}

output "application_server_ssh_connect_command" {
  description = "Application Server SSH 접속 명령어"
  value       = "ssh -i ./baekgwa-blog-key.pem ubuntu@${var.fixed_application_public_ip}"
}

output "elk_server_ssh_keygen_reset_command" {
  description = "ELK Server SSH Known Hosts 초기화 명령어"
  value       = "ssh-keygen -R ${var.fixed_elk_public_ip}"
}

output "elk_server_ssh_connect_command" {
  description = "ELK Server SSH 접속 명령어"
  value       = "ssh -i ./baekgwa-blog-key.pem ubuntu@${var.fixed_elk_public_ip}"
}

output "cloud_init_check" {
  description = "cloud init 확인"
  value       = "cat /var/log/cloud-init-output.log"
}