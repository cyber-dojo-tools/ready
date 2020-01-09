#!/bin/bash -Eeu

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
# substitute environment-variables
cat /tmp/docker-compose.yml | envsubst > /tmp/docker-compose.yml2
# convery yaml to json
yq r --tojson /tmp/docker-compose.yml2 > /tmp/docker-compose.json
# extract service names
readonly names=$(cat /tmp/docker-compose.json | jq '.services | to_entries[] | .key')
for name in ${names}; do
  port=$(cat /tmp/docker-compose.json | jq .services.${name}.export)
  if [ "${port}" != 'null' ]; then
    bare_name=$(echo "${name}" | tr -d '"') # strip leading/trailing "
    wait_briefly_until_ready "${bare_name}:${port}"
  fi
done
