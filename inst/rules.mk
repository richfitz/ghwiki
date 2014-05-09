# -*- makefile -*-
RSCRIPT = Rscript

GHWIKI_PATH := $(shell ${RSCRIPT} -e "ghwiki:::path()")
KNIT_SH = ${GHWIKI_PATH}/knit.sh
WIKI_SH = ${GHWIKI_PATH}/wiki.sh
SCRIPTS_SH = ${GHWIKI_PATH}/scripts.sh

# Lots of GNU extensions here I think.
TARGETS = $(shell ${SCRIPTS_SH} targets)
TARGETS_RMD = $(shell ${SCRIPTS_SH} generated_Rmd)

# This one is useful only for me, or for other people who use sowsear.
# I think that knitr has something like this built in now.
%.Rmd: %.R
	${RSCRIPT} -e "library(sowsear); sowsear('$<', 'Rmd')"

# This one is more generally useful
%.md: %.Rmd
	${KNIT_SH} $<
%.pdf: %.md
	pandoc $< -o $@
%.docx: %.md
	pandoc $< -o $@
%.html: %.md
	${RSCRIPT} -e "library(markdown);\
	  opts <- setdiff(markdownHTMLOptions(TRUE), 'base64_images');\
	markdownToHTML('$<', '$@', options=opts)"

all: ${TARGETS}

clean:
	rm -f ${TARGETS}
	rm -f ${TARGETS_RMD}
	rm -rf figure cache

wiki_clone:
	${WIKI_SH} clone
wiki_update: all
	${WIKI_SH} update
wiki_publish:
	${WIKI_SH} publish
wiki_reset:
	${WIKI_SH} reset
wiki_rollback:
	${WIKI_SH} rollback

.PHONY: all clean wiki_clone wiki_update wiki_reset wiki_publish wiki_rollback
.SECONDARY: ${TARGETS} ${TARGETS_RMD}
