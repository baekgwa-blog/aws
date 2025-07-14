set -e

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

# 3. AWS CLI 로그인(자격 증명 설정)
echo "[INFO] AWS CLI 자격 증명 입력 (Access Key, Secret Key, 리전)"
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set region "$AWS_DEFAULT_REGION"

echo "[INFO] AWS CLI 설치 및 로그인(자격증명) 완료!"
