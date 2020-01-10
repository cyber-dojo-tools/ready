# ready

- Work in progress.
- Investigating the idea of an image to check if docker containers
are ready, as determined by `curl` calls.

For example, with env-vars determined by `cyberdojo/versioner:latest`,
suppose the docker-compose.yml file for ragger looks like this:

```yml
version: '3.7'
services:
  ragger:
    ...
    export: ${CYBER_DOJO_RAGGER_PORT}
  runner:
    ...
    export: ${CYBER_DOJO_RUNNER_PORT}
```

then a call such as this:

```bash
docker run --rm cyberdojo/versioner:latest \
|
docker run \
  --rm \
  -i \
  --network ragger_default \
  --volume ~/repos/cyber-dojo/ragger/docker-compose.yml:/tmp/docker-compose.yml:ro \
  cyberdojotools/ready
```

would make 20 attempts (at 0.1 second intervals) to receive `{'ready?':true}`
responses from curl calls to each of
- http://ragger:5537/ready?
- http://runner:4597/ready?

Note the second `docker run`
- must not use -t since the input is not a `tty`
- must run in the same `network` as the services it probes for readyness
