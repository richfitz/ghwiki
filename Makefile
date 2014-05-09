all:

attributes:
	Rscript -e "Rcpp::compileAttributes()"

document:
	@mkdir -p man
	Rscript -e "library(methods); devtools::document()"

install:
	R CMD INSTALL .

clean:
	make -C src clean

build:
	R CMD build .

check: build
	R CMD check --no-manual `ls -1tr ghwiki*gz | tail -n1`
	@rm -f `ls -1tr ghwiki*gz | tail -n1`
	@rm -rf ghwiki.Rcheck

test:
	make -C tests/testthat

.PHONY: attributes document install clean build check
