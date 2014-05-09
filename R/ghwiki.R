##' Initialise a directory to work with my wiki workflow approach
##'
##' @title Initialise Wiki Workflow Directory
##' @param Makefile Filename to add rules to
##' @param clone Try to clone the repository immediately on
##' initialising?
##' @author Rich FitzJohn
##' @export
init <- function(Makefile="Makefile", clone=TRUE) {
  ## Or add a template in, if we can handle comments yet?
  if (!file.exists(".wiki_scripts")) {
    writeLines("# List script files here", ".wiki_scripts")
  }
  init_makefile(Makefile)
  # Install these locally
  install_ghwiki_file("wiki_redirect.sh",  ".wiki.sh")
  install_ghwiki_file("scripts_redirect.sh", ".scripts.sh")
  if (clone) {
    system("./.wiki.sh clone")
  }
  invisible()
}

## Install scripts globally
install_scripts <- function(path) {
  install_ghwiki_file("wiki_redirect.sh",    file.path(path, "wiki.sh"))
  install_ghwiki_file("scripts_redirect.sh", file.path(path, "scripts.sh"))
  invisible()
}

path <- function() {
  writeLines(system.file(package="ghwiki"))
}

knitr_hooks <- function(prefix) {
  ## Start with the basic markdown options
  knitr::render_markdown()

  ## Hook to replace ```r -> ```S in generated output -- this renders
  ## better on github.
  knitr::knit_hooks$set(source=function(x, options)
                        paste0('\n\n```S\n', x, '\n```\n\n'))

  ## Include a little footer at the bottom of each page:
  local({
    knit_and_read <- function(filename) {
      if (file.exists(filename)) {
        readLines(knitr::knit(filename, tempfile(), quiet=TRUE))
      } else {
        character(0)
      }
    }
    document_with_footer <- function(x) {
      knitr::knit_hooks$set(document=identity)
      c(x, knit_and_read(".knitr_footer.Rmd"))
    }
    knitr::knit_hooks$set(document=document_with_footer)
  })

  ## Hook to make more friendly (smaller) figure margins and set the
  ## hook to run by by default.  Pass small_mar=FALSE to disable.
  knitr::knit_hooks$set(small_mar=function(before, options, envir) {
    if (before) par(mar=c(4, 4, .1, .1)) # smaller margin on top and right
  })
  knitr::opts_chunk$set(small_mar=TRUE,
                        error=FALSE, tidy=FALSE, fig.height=5,
                        fig.path=sprintf("figure/%s__", prefix),
                        cache.path=sprintf("cache/%s__", prefix))
}

rules.mk <- function() {
  writeLines(system.file("rules.mk", package="ghwiki"))
}

init_makefile <- function(filename) {
  str <- 'include $(shell Rscript -e "ghwiki:::rules.mk()")'
  if (file.exists(filename)) {
    d <- readLines(filename)
    if (!any(grepl("ghwiki:::rules", d))) {
      writeLines(c(str, "\n", d), filename)
    }
  } else {
    writeLines(str, filename)
  }
}

install_ghwiki_file <- function(file, dest) {
  file.copy(system.file(file, package="ghwiki"),
            dest, overwrite=TRUE)
}
