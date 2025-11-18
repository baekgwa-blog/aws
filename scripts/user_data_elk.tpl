#!/bin/bash
set -e

# --- ELK 변수 선언 ---
export ELASTIC_SEARCH_PORT="${elastic_search_port}"
export KIBANA_PORT="${kibana_port}"
export LOGSTASH_PORT="${logstash_port}"
export ELASTICSEARCH_USERNAME='${elasticsearch_username}'
export ELASTICSEARCH_PASSWORD='${elasticsearch_password}'
export ELASTICSEARCH_HOSTS='${elasticsearch_hosts}'
export KIBANA_USERNAME='${kibana_username}'
export KIBANA_PASSWORD='${kibana_password}'

# --- 스크립트 실행 ---
${set_timezone}
${install_docker}
${install_git}
${install_nginx}
${install_elk}