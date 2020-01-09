#!/bin/bash

readonly MY_DIR="$( cd "$( dirname "${0}" )" && pwd )"

# - - - - - - - - - - - - - - - - - - - - - -
wait_briefly_until_ready()
{
  local -r name_port="${1}" # eg runner:4597
  local -r max_tries=20
  printf "Waiting until ${name_port} is ready"
  for _ in $(seq ${max_tries}); do
    if curl_ready ${name_port}; then
      printf '.OK\n'
      return
    else
      printf .
      sleep 0.1
    fi
  done
  printf 'FAIL\n'
  echo "not ready after ${max_tries} tries"
  if [ -f "$(ready_filename)" ]; then
    ready_response
  fi
  exit 42
}

# - - - - - - - - - - - - - - - - - - -
curl_ready()
{
  local -r name_port="${1}" # eg runner:4597
  local -r url="http://${name_port}/ready?"
  rm -f "$(ready_filename)"
  curl \
    --fail \
    --output $(ready_filename) \
    --silent \
    -X GET \
    "${url}"
  [ "$?" == '0' ] && [ "$(ready_response)" == '{"ready?":true}' ]
}

# - - - - - - - - - - - - - - - - - - -
ready_response()
{
  cat "$(ready_filename)"
}

# - - - - - - - - - - - - - - - - - - -
ready_filename()
{
  printf /tmp/curl-ready-output
}

# - - - - - - - - - - - - - - - - - - -
set_versioner_env_vars()
{
  cat > /tmp/.env
  set -a
  source /tmp/.env
  set +a
}

# - - - - - - - - - - - - - - - - - - -
set_versioner_env_vars
cat /tmp/docker-compose.yml | envsubst
# Now need to
# 1) set export: in original docker-compose.yml
# 2) harvest service names and port numbers, eg runner:4597
#    How????

wait_briefly_until_ready "${1}"
