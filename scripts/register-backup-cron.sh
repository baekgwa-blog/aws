#!/bin/bash
set -e

echo "[INFO] MySQL 백업 cron 등록 시작"

BACKUP_DIR="/home/ubuntu/backups/mysql"
BACKUP_SCRIPT_PATH="${BACKUP_DIR}/mysql_backup.sh"
CONTAINER_NAME="baekgwa-blog-database"
DB_NAME="baekgwa_blog"
RETENTION_DAYS=30
S3_BUCKET="baekgwa-blog-s3-bucket"

# 백업 디렉토리 생성
mkdir -p "$BACKUP_DIR"

# 백업 스크립트 생성
sudo tee $BACKUP_SCRIPT_PATH > /dev/null <<'EOF'
#!/bin/bash
set -e

source /etc/environment

BACKUP_DIR="/home/ubuntu/backups/mysql"
CONTAINER_NAME="baekgwa-blog-database"
DB_NAME="baekgwa_blog"
DATE=$(date +"%Y%m%d")
RETENTION_DAYS=30
S3_BUCKET="baekgwa-blog-s3-bucket"
BACKUP_FILE="${BACKUP_DIR}/${DATE}_backup.sql.gz"

mkdir -p "$BACKUP_DIR"

echo "[INFO] $(date): Starting MySQL backup (compressed)..."

# mysqldump 결과를 gzip으로 압축하면서 stderr는 무시
docker exec -i "$CONTAINER_NAME" mysqldump -u root -p"${RDBMS_ROOT_PASSWORD}" "$DB_NAME" 2>/dev/null | gzip > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
  echo "[SUCCESS] Backup completed: $BACKUP_FILE"
else
  echo "[ERROR] Backup failed" >&2
  exit 1
fi

# 30일 이상된 백업 삭제
find "$BACKUP_DIR" -type f -name "*.sql.gz" -mtime +${RETENTION_DAYS} -delete
echo "[INFO] Old backups cleaned up"

# S3 업로드
if command -v aws >/dev/null 2>&1; then
  echo "[INFO] Uploading backup to S3..."
  aws s3 cp "$BACKUP_FILE" "s3://${S3_BUCKET}/mysql_backups/" --only-show-errors
  if [ $? -eq 0 ]; then
    echo "[SUCCESS] Backup uploaded to S3: s3://${S3_BUCKET}/mysql_backups/$(basename $BACKUP_FILE)"
  else
    echo "[ERROR] S3 upload failed" >&2
  fi
else
  echo "[WARNING] AWS CLI not found, skipping S3 upload."
fi
EOF

sudo chmod +x $BACKUP_SCRIPT_PATH
sudo chown ubuntu:ubuntu $BACKUP_SCRIPT_PATH

# 환경 변수 등록
if ! grep -q "RDBMS_ROOT_PASSWORD" /etc/environment; then
  echo "RDBMS_ROOT_PASSWORD=${RDBMS_ROOT_PASSWORD}" | sudo tee -a /etc/environment
fi

# cron 등록 (root 계정)
CRON_LINE="0 3 * * * /home/ubuntu/backups/mysql/mysql_backup.sh >> /var/log/mysql_backup.log 2>&1"
( sudo crontab -l 2>/dev/null | grep -v 'mysql_backup.sh' ; echo "$CRON_LINE" ) | sudo crontab -

echo "[SUCCESS] MySQL 백업 cron 등록 완료"
