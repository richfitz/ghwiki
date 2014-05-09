#!/bin/sh
WIKI_DIR=$(git rev-parse --show-toplevel)/wiki
FIGURE_DIR="figure"
GIT_WIKI="--git-dir=$WIKI_DIR/.git --work-tree=$WIKI_DIR"
GHWIKI_PATH=$(Rscript -e "ghwiki:::path()")
SCRIPTS_SH=${GHWIKI_PATH}/scripts.sh

function github_url {
    for remote in $(git remote)
    do
	URL=$(git ls-remote --get-url $remote | grep github.com)
	if test ! -z $URL
	then
	    echo $URL
	    return 0
	fi
    done
}

function wiki_sha {
    echo $(git $GIT_WIKI rev-parse --short HEAD)
}

function local_sha {
    echo $(git rev-parse --short HEAD)
}

function clone_github_wiki {
    if test ! -d "$WIKI_DIR"
    then
	GITHUB_URL=$(github_url)
	if test -z $GITHUB_URL
	then
	    echo "Error: could not determine github repo"
	    exit 1
	fi
	WIKI_URL=$(echo $GITHUB_URL | sed 's/\(.git\)*$/.wiki\1/')
	git clone $WIKI_URL $WIKI_DIR
    fi
}

function check_wiki_exists {
    if test ! -d "$WIKI_DIR"
    then
	echo "Error: wiki directory does not exist - clone first"
	exit 1
    fi
}

# Check that we don't have any residual "unnamed chunk" figures that I
# never want committed.
function check_figure_dir {
    if [[ -d $FIGURE_DIR &&
	-n "$(find $FIGURE_DIR -maxdepth 1 -name '*unnamed*' -print -quit)" ]]
    then
	echo "Warning: Unnamed figure chunks found"
    fi
}

# Check that the wiki directory is clean
#
# I'm not sure if this is ideal.  Could be over cautious, given we
# don't generally care all that much about the internal state of the
# wiki.
function check_wiki_dir {
    check_wiki_exists
    if test -n "$(git $GIT_WIKI status -s 2> /dev/null)"
    then
	echo "Error: wiki git is dirty"
	echo "(consider commiting or 'git reset --hard HEAD' in the wiki dir)"
	exit 1
    fi
}

function reset_wiki {
    check_wiki_exists
    git ${GIT_WIKI} reset --hard HEAD
}

function exists {
    [ -e "$1" ]
}

function update_script {
    check_wiki_exists
    S_BASE="${1}"
    echo "Updating ${S_BASE}"

    # Delete all old figures for this case.  This is needed because we
    # need to work out where images are no longer needed or they'll
    # persist in the wiki.  Perhaps better would be to use rsync with
    # some pattern matching, but we need to hit the 'git rm' at some
    # point.
    git $GIT_WIKI rm -f --quiet --ignore-unmatch -- "$FIGURE_DIR/${S_BASE}__*"

    # That *might* have deleted the wiki figure directory:
    mkdir -p $WIKI_DIR/$FIGURE_DIR

    # Copy the new stuff over and add to git:
    # a. actual file
    cp ${S_BASE}.md $WIKI_DIR
    git $GIT_WIKI add ${S_BASE}.md
    # b. figures if they exist
    if exists $FIGURE_DIR/${S_BASE}__*
    then
	cp $FIGURE_DIR/${S_BASE}__* $WIKI_DIR/$FIGURE_DIR/
	git $GIT_WIKI add --ignore-errors "$FIGURE_DIR/${S_BASE}__*"
    fi
}

function update_wiki {
    check_wiki_exists
    for S in $(${SCRIPTS_SH} base) $(${SCRIPTS_SH} markdown_base)
    do
	update_script $S
    done
}

# It could be that we want to check that the working directory is
# clean, too.
function commit_wiki {
    if git $GIT_WIKI status --porcelain --untracked-files=no | grep --quiet '^[A-Z]'
    then
	SHORT_SHA=$(local_sha)
	git $GIT_WIKI commit -q -m "Updated wiki [at ${SHORT_SHA}]"
	echo "Wiki upated [wiki: $(wiki_sha), local: ${SHORT_SHA}]"
    else
	echo "Wiki already up to date [wiki: $(wiki_sha), local: $(local_sha)]"
    fi
}

function publish_wiki {
    check_wiki_exists
    git $GIT_WIKI push
}

function rollback_wiki {
    check_wiki_exists
    PREV_SHA=$(git $GIT_WIKI rev-parse --short HEAD)
    echo "Rolling back from ${PREV_SHA}"
    git $GIT_WIKI reset --hard HEAD^
    echo "Change your mind?"
    echo "  ./.ghwiki reset_to $PREV_SHA"
}

function reset_wiki_to {
    check_wiki_exists
    if test -z $1
    then
	echo "reset_wiki_to requires a hash as an argument!"
	exit 1
    fi
    git $GIT_WIKI reset --hard $1
}

## Below here is the actual script:
case $1 in
    clone)
	clone_github_wiki
	;;
    update)
	check_figure_dir
	check_wiki_dir
	update_wiki
	commit_wiki
	;;
    update_script)
	update_script $2
	;;
    publish)
	shift
	publish_wiki "$@"
	;;
    reset)
	reset_wiki
	;;
    rollback)
	rollback_wiki
	;;
    reset_to)
	reset_wiki_to $2
	;;
    git)
	shift
	git ${GIT_WIKI} "$@"
	;;
    scripts)
        shift
        ${SCRIPTS_SH} "$@"
        ;;
    *)
	echo $"Usage ghwiki {update|update_script|publish|reset|rollback|reset_to|git|scripts}"
	exit 1
esac
