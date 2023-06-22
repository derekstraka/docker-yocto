#!/bin/bash

cmd=$(basename $0)

setuser builduser \
	bash -c "source /var/build/poky/oe-init-build-env && export BB_ENV_PASSTHROUGH_ADDITIONS=\"${BB_ENV_PASSTHROUGH_ADDITIONS} MACHINE SSTATE_DIR SSTATE_MIRRORS SSH_AUTH_SOCK\" && ${cmd} $*"
