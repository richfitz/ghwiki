#!/bin/sh
GHWIKI_PATH=$(Rscript -e "ghwiki:::path()")
WIKI_SH=${GHWIKI_PATH}/scripts.sh
$WIKI_SH "$@"
