#!/bin/bash
set -e
set -u

echo "[INFO] 시스템 타임존을 'Asia/Seoul'로 설정합니다."
timedatectl set-timezone Asia/Seoul
echo "[SUCCESS] 타임존 변경 완료. 현재 시간: $(date)"