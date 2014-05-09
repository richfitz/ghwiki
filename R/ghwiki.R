##' Initialise a directory to work with my wiki workflow approach
##'
##' @title Initialise Wiki Workflow Directory
##' @param Makefile Filename to add rules to
##' @author Rich FitzJohn
##' @export
init <- function(Makefile="Makefile") {
  ## Or add a template in, if we can handle comments yet?
  if (!file.exists(".wiki_scripts")) {
    writeLines("# List script files here", ".wiki_scripts")
  }
  init_makefile(Makefile)
  # Install these locally
  install_ghwiki_file("wiki.sh",    ".wiki.sh")
  install_ghwiki_file("scripts.sh", ".scripts.sh")
  invisible()
}

## Install scripts globally
install_scripts <- function(path) {
  install_ghwiki_file("wiki.sh",    path)
  install_ghwiki_file("scripts.sh", path)
  invisible()
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

install_ghwiki_file <- function(file, dest) {
  file.copy(system.file(file, package="ghwiki"),
            dest, overwrite=TRUE)
}
