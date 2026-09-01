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
podman compose up -d && podman exec -it yocto-dev bash # or
podman compose run yocto-dev
```

## Dotfiles

Drop your dotfiles (e.g. `.bash_aliases`, `.config/nvim/`) into `./dotfiles/`
in this project, mirroring the layout you want under `$HOME` in the
container. They are baked into the image at build time and seeded into the
persistent home volume on container start -- only for files that don't
already exist there, so edits you make inside the container are never
overwritten.

To re-seed after adding a new dotfile to the repo:
```text
podman compose build && podman compose up -d --force-recreate
```
(existing files in the volume are left untouched; only newly added ones are copied in)

