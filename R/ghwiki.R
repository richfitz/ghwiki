##' Initialise a directory to work with my wiki workflow approach
##'
##' @title Initialise Wiki Workflow Directory
##' @param Makefile Filename to add rules to
##' @author Rich FitzJohn
##' @export
init <- function(Makefile="Makefile") {
  ## Or add a template in, if we can handle comments yet?
  if (!file.exists(".wiki_scripts")) {
    touch(".wiki_scripts")
  }
  init_makefile(Makefile)
  init_wiki.sh(".wiki.sh")
  invisible()
}

touch <- function(filename) {
  writeLines(character(0), filename)
}

path <- function() {
  writeLines(system.file(package="ghwiki"))
}

knitr_hooks <- function() {
  source(system.file("knitr_hooks.R", package="ghwiki"))
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

init_wiki.sh <- function(filename) {
  file.copy(system.file("wiki_redirect.sh", package="ghwiki"),
            filename, overwrite=TRUE)
}
