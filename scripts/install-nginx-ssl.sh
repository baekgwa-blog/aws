# Nginx 설치
apt-get update -y
apt-get install -y nginx

# Certbot (Let's Encrypt 클라이언트) 설치
apt-get install -y certbot python3-certbot-nginx

# Nginx 기본 설정 백업
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak

# Nginx 기본 서버 블록 작성
cat <<EOT > /etc/nginx/sites-available/default
server {
    listen 80;
    server_name blog.baekgwa.site;

    location /_next/ {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Cookie \$http_cookie;
    }

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
        proxy_set_header Cookie \$http_cookie;
    }
}

server {
    listen 80;
    server_name blog.api.baekgwa.site;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header Cookie \$http_cookie;
    }
}
EOT

# Nginx 리로드
systemctl reload nginx

# Certbot으로 SSL 인증서 발급 + 자동 nginx 설정
while true; do
  certbot --nginx \
    -d blog.baekgwa.site \
    -d blog.api.baekgwa.site \
    --non-interactive --agree-tos -m ksu9801@gmail.com && break

  echo "Certbot 실패, 5분 후 재시도..."
  sleep 300
done

# redirect method 기억하도록 308로 변경
sed -i 's/return 301 /return 308 /g' /etc/nginx/sites-available/default
nginx -t && systemctl reload nginx
