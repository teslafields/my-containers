#!/bin/bash
# Seeds baked-in dotfiles (from /opt/dotfiles-skel, populated at image build
# time from the project's ./dotfiles/ directory) into $HOME on container
# start -- but only for files/dirs that don't already exist there. This
# mirrors /etc/skel behavior: the persistent named volume (yocto-home) keeps
# whatever you've customized across container recreations, while new/missing
# items still get seeded (e.g. after adding a new dotfile to the repo and
# rebuilding the image).
set -euo pipefail

SKEL_DIR="/opt/dotfiles-skel"

if [ -d "${SKEL_DIR}" ]; then
    # cp -n: do not overwrite existing files. --parents-like traversal via cp -a
    # on each top-level entry keeps this simple and safe for both files and dirs.
    find "${SKEL_DIR}" -mindepth 1 -maxdepth 1 | while read -r entry; do
        target="${HOME}/$(basename "${entry}")"
        if [ ! -e "${target}" ]; then
            cp -a "${entry}" "${target}"
        else
            # For directories that already exist, merge in any new files
            # without touching ones you've already customized.
            if [ -d "${entry}" ]; then
                cp -a -n -r "${entry}/." "${target}/" 2>/dev/null || true
            fi
        fi
    done
fi

exec "$@"
