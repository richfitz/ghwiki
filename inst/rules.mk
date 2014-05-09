# Make Rscript less braindead by loading the methods package
# RSCRIPT_PKGS := $(shell Rscript -e 'library(methods);writeLines(Sys.getenv("R_DEFAULT_PACKAGES"))')
# RSCRIPT = Rscript --default-packages="${RSCRIPT_PKGS},methods"
RSCRIPT = Rscript

GHWIKI_PATH := $(shell ${RSCRIPT} -e "ghwiki:::path()")
KNIT_SH = ${GHWIKI_PATH}/knit.sh
WIKI_SH = ${GHWIKI_PATH}/wiki.sh

# Lots of GNU extensions here I think.
# TODO: Skip blank lines and comments when reading .wiki_scripts
SCRIPTS = $(shell cat .wiki_scripts)
TARGETS = $(patsubst %.R,%.md, ${SCRIPTS})
TARGETS_RMD = $(patsubst %.R,%.Rmd, ${SCRIPTS})

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
	rm -f ${TARGETS} ${TARGETS_RMD}
	rm -rf figure cache

wiki_clone:
	${WIKI_SH} clone
wiki_update:
	${WIKI_SH} update
wiki_publish:
	${WIKI_SH} publish
wiki_reset:
	${WIKI_SH} reset
wiki_rollback:
	${WIKI_SH} rollback

.PHONY: all clean wiki_clone wiki_update wiki_reset wiki_publish wiki_rollback
.SECONDARY: ${TARGETS} ${TARGETS_RMD}
