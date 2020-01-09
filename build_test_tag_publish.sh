#!/bin/bash -Eeu

readonly ROOT_DIR="$( cd "$( dirname "${0}" )" && pwd )"

#- - - - - - - - - - - - - - - - - - - - - - - - -
build_image()
{
  docker build \
    --tag cyberdojotools/ready \
    "${ROOT_DIR}/app"
}

# You have to specify the network so the service name
# is available as the curl hostname.

# You can specify -it in the 2nd docker run as the input
# is a piped file and not a tty

build_image

docker run \
  --rm \
  cyberdojo/versioner:latest \
  sh -c 'cat /app/.env' \
|
docker run \
  --rm \
  -i \
  --network ragger_default \
  --volume ~/repos/cyber-dojo/ragger/docker-compose.yml:/tmp/docker-compose.yml:ro \
  cyberdojotools/ready \
  ragger:5537
