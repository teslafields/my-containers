## Build server environment

Build the container using:

```text
podman compose \
    -f <path to podman-compose.yml> \
    build \
    --build-arg USERNAME=<username> \
    --build-arg USER_UID=$(id -u) --build-arg USER_GID=$(id -g) \
    --build-arg DOCKER_GID=$(getent group docker | cut -d: -f 3)
```

And start using it:

```text
podman compose up -d && podman exec yocto-dev bash # or
podman compose run yocto-dev
```
