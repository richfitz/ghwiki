#!/bin/sh
# Parse the scripts file

WIKI_SCRIPTS=.wiki_scripts

# All files that don't end in R or Rmd are currently excluded here.
function valid_scripts  {
    cat $WIKI_SCRIPTS | trim | \
	grep -E -v '^(#|$)'  | \
	trim | grep -E '.[.]R(md)?$'
}

function base {
    valid_scripts | drop_ext
}

# Rmd files that can be safely deleted
function generated_Rmd {
    valid_scripts | grep '[.]R$' | replace_ext "Rmd"
}

function targets {
    valid_scripts | replace_ext "md"
}

function markdown {
    cat $WIKI_SCRIPTS | trim | \
	grep -E -v '^(#|$)'  | \
	trim | grep -E '.[.]md$'
}

function markdown_base {
    markdown | sed -E 's/[.]md$//'
}

# Little utilities:
function drop_ext {
    sed -E 's/[.]R(md)?$//'
}

function replace_ext {
    drop_ext | sed "s/$/.${1}/"
}

function trim {
    sed -e 's/^[[:space:]]*//g' | sed -e 's/[[:space:]]*$//g'
}

case $1 in
    list)
	echo "$(valid_scripts)"
	;;
    base)
	echo "$(base)"
	;;
    generated_Rmd)
	echo "$(generated_Rmd)"
	;;
    targets)
	echo "$(targets)"
	;;
    markdown)
	echo "$(markdown)"
	;;
    markdown_base)
	echo "$(markdown_base)"
	;;
    *)
	echo $"Usage `basename $0` {list|base|generated_Rmd|targets}"
esac
