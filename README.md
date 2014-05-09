# Wiki Workflow

[![Build Status](https://travis-ci.org/richfitz/ghwiki.png?branch=master)](https://travis-ci.org/richfitz/ghwiki)

These are just personal scripts.  Information about the approach coming later, along with an example.

Install with (from R)

```
devtools::install_github("richfitz/ghwiki")
```

Initialise with

```
Rscript -e "ghwiki::init()"
```

Pull down the project wiki with

```
make wiki_clone
```

The git repository must be from github, and the *first* remote that has a github url will be used.

Add names of `R` or `Rmd` scripts to the file `.wiki_scripts`.  The file cannot contain blank lines or comments yet.

Run

```
make
```

to run all the scripts listed in `.wiki_scripts`, generating `md` files, figures etc.  A bunch of knit tweaks are applied to normalise figure paths, etc.

Run

```
make wiki_update
```

to update the local copy of the wiki repo, and


```
make wiki_publish
```

to push it up.  You're on your own with resolving conflicts.  Other make targets:

* `make clean` -- clean up generated .md and .Rmd files.  This is probably not useful unless you're using [sowsear](https://github.com/richfitz/sowsear) because most people like their Rnw files...
* `make wiki_rollback` -- undo a commit in the wiki repo
* `make wiki_reset` -- destructively clean up an unclean state in the wiki repo

Other commands can be run via `./.wiki.sh`:

* `./.wiki.sh reset_to <SHA>` -- move the wiki to a particular SHA (can undo a rollback this way)
* `./.wiki.sh git [commands]` -- run git commands in the wiki repo (e.g., `./.wiki.sh git log`)
