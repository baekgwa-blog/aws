#!/bin/bash

set -e
set -u

echo "[INFO] ELK Docker 환경 설정 시작"

PROJECT_DIR="/home/ubuntu/server"

# Git 저장소 클론 또는 업데이트
if [ ! -d "$PROJECT_DIR" ]; then
  echo "[INFO] Git 저장소 클론 중... (ELK)"
  git clone https://github.com/baekgwa-blog/server.git "$PROJECT_DIR"
else
  echo "[INFO] Git 저장소 업데이트 중..."
  cd "$PROJECT_DIR"
  git pull origin main
fi

cd "$PROJECT_DIR"

## ---------------------------------------------------
## TODO: 개발 브랜치 사용 (운영 시 제거 필요)
#git fetch origin
#git checkout feat/elk/setupAndMigrationData || true
#git pull origin feat/elk/setupAndMigrationData || true
## ---------------------------------------------------

ELK_DIR="$PROJECT_DIR/docker/elk"
mkdir -p "$ELK_DIR"

# .env 파일 생성 (Docker Compose가 참조함)
# user_data_elk.tpl 에서 export 된 환경 변수들을 사용
cat <<EOF > "$ELK_DIR/.env"
# --- Ports ---
ELASTIC_SEARCH_PORT=$ELASTIC_SEARCH_PORT
KIBANA_PORT=$KIBANA_PORT
LOGSTASH_PORT=$LOGSTASH_PORT
APM_SERVER_PORT=$APM_SERVER_PORT

# --- Elastic & Kibana Auth ---
ELASTICSEARCH_USERNAME=$ELASTICSEARCH_USERNAME
ELASTICSEARCH_PASSWORD=$ELASTICSEARCH_PASSWORD
ELASTICSEARCH_HOSTS=$ELASTICSEARCH_HOSTS

KIBANA_USERNAME=$KIBANA_USERNAME
KIBANA_PASSWORD=$KIBANA_PASSWORD
EOF

echo "[INFO] $ELK_DIR/.env 파일 생성 완료"
chmod 600 "$ELK_DIR/.env"  # 보안상 권한 축소

cd "$ELK_DIR"

echo "[INFO] Docker Compose 실행..."
docker-compose -f elk-docker-compose.yml down --remove-orphans || true
docker-compose -f elk-docker-compose.yml up -d

echo "[SUCCESS] ELK Docker 컨테이너가 성공적으로 실행되었습니다"