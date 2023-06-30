#!/usr/bin/env bash

set -eo pipefail

cmd=$(basename "$0")

setuser builduser \
	bash -c "source /var/build/poky/oe-init-build-env && export BB_ENV_EXTRAWHITE=\"${BB_ENV_EXTRAWHITE} MACHINE SSTATE_DIR SSTATE_MIRRORS SSH_AUTH_SOCK\" && ${cmd} $*"
