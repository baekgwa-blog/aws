#!/bin/bash

# Nginx 설치
apt-get update -y
apt-get install -y nginx

# Certbot (Let's Encrypt 클라이언트) 설치
apt-get install -y certbot python3-certbot-nginx

# Nginx 기본 설정 백업
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Nginx 기본 서버 블록 작성 (HTTP 80 -> HTTPS 리다이렉트는 Certbot이 나중에 처리)
# Kibana (kibana.baekgwa.site) -> 5601
# Elasticsearch (elastic.baekgwa.site) -> 9200
cat <<EOT > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name kibana.baekgwa.site;
    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:5601;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}

server {
    listen 80;
    server_name elastic.baekgwa.site;
    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:9200;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOT

# Nginx 리로드
systemctl reload nginx

# Certbot으로 SSL 인증서 발급 + 자동 nginx 설정
#  --staging
while true; do
  certbot --nginx \
    -d kibana.baekgwa.site \
    -d elastic.baekgwa.site \
    --non-interactive --agree-tos -m ksu9801@gmail.com && break

  echo "Certbot 실패, 5분 후 재시도..."
  sleep 300
done

# 301 Redirect를 308로 변경
sed -i 's/return 301 /return 308 /g' /etc/nginx/sites-available/default
nginx -t && systemctl reload nginx