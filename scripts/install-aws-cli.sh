#!/bin/bash
set -e

echo "[INFO] AWS CLI 설치 스크립트 시작"

# 1. AWS CLI 최신 버전 설치 (Ubuntu/Debian 기준)
if ! command -v aws >/dev/null 2>&1; then
  echo "[INFO] AWS CLI 설치 중..."
  apt-get update -y
  apt-get install -y unzip curl
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  unzip -o /tmp/awscliv2.zip -d /tmp
  /tmp/aws/install
else
  echo "[INFO] AWS CLI는 이미 설치됨"
fi

# 2. AWS CLI 버전 확인
aws --version

# 3. IAM Role 확인
if curl -s http://169.254.169.254/latest/meta-data/iam/info >/dev/null; then
  echo "[INFO] IAM Role이 연결되어 있습니다. AWS CLI 자격 증명 설정은 생략합니다."
else
  echo "[WARNING] IAM Role이 감지되지 않았습니다."
  echo "[WARNING] IAM Role이 없으면 S3 업로드가 동작하지 않습니다."
fi

echo "[SUCCESS] AWS CLI 설치 완료"
