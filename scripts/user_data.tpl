#!/bin/bash
set -e

# --- 공통 변수 선언 ---
export RDBMS_ROOT_PASSWORD="${rdbms_root_password}"
export RDBMS_USERNAME="${rdbms_username}"
export RDBMS_PASSWORD="${rdbms_password}"
export RDBMS_PORT="${rdbms_port}"
export MYSQL_QUERY_LOG_PATH="${mysql_query_log_path}"
export REDIS_PASSWORD="${redis_password}"
export REDIS_PORT="${redis_port}"

# --- 스크립트 실행 ---
${set_timezone}
${install_docker}
${install_git}
${install_nginx}
${install_database}
${register_backup_cron}