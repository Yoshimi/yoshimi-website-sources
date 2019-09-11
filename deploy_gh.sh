#!/usr/bin/env bash

# Build website and update github-pages repo.
#
# The location of a local clone of the github
# pages repo (yoshimi.github.io) must be provided
# as the first argument or defined in the
# GH_IO_REPO environment variable.
#
# A new commit will be created automatically,
# using a generic message and the hash of the
# commit in the source repo that the deployment
# is based on.
#
# This script does not push the changes automatically,
# for now, this should be done manually.

function error
{
    # Light red on black background
    echo -e "\e[40m\e[91m$1\e[0m"
}

function warning
{
    # Light yellow on black background
    echo -e "\e[40m\e[93m$1\e[0m"
}

function build_and_update
{
    local orig_dir="$(pwd)"
    local dir="$(dirname $(readlink -f $1))"

    local site_repo_dir="$2"
    if [ -z "$site_repo_dir" ]; then
	site_repo_dir="$GH_IO_REPO"
    fi
    if [ -z "$site_repo_dir" ]; then
	error "Deployment repo directory must be provided as an argument \
or defined in the GH_IO_REPO environment variable."
	exit 1
    elif [ ! -d "$site_repo_dir" ]; then
	error "$site_repo_dir does not exist, or is not a directory. \
It should be the location of the site repository root."
	exit 1
    elif [ "$(readlink -f $site_repo_dir)" == "$dir" ]; then
	error "Site repository location set to site sources directory, \
this is almost certainly incorrect."
	exit 1
    fi

    # Pre-gen sanity checks
    cd "$site_repo_dir"

    # Check that the site dir contains a git repo
    if ! ( git status >&- 2>&- && test -d ".git" ); then
	error "Provided site repository directory \"$site_repo_dir\" \
is not the root of a git repository."
	exit 1
    fi

    # Check that the repo is clean
    if [ -n  "$(git status --porcelain -uno)" ]; then
	error "There are uncommitted changes in \"$site_repo_dir\".
Deal with these before running this script again."
	exit 1
    fi

    # Check if source directory is a repo and create
    # default commit message accordingly
    cd "$dir"
    local commit_msg="
Based on source repo commit:
$(git rev-parse HEAD 2>&-)
"

    if [ "$?" != "0" ]; then
	warning "WARNING: Site source is not a git repo"
	commit_msg="Based on unknown source."
    fi
    if [ -n "$(git status --porcelain 2>&-)" ]; then
	warning "WARNING: Source repo contains uncommitted/untracked changes"
	commit_msg="$commit_msg
(dirty source repository!)"
    fi
    commit_msg="Deploy generated site

$commit_msg"

    # Build site
    local BUILD_DIR="$(mktemp -d)"
    BUILD_DIR="$BUILD_DIR" ./gen_site.py

    if [ "$?" != "0" ]; then
	error "Site generation failed, aborting!"
	exit 1
    fi

    # Prepare staging
    cd "$site_repo_dir"

    local stashed=""
    # Check if there are untracked changes requiring stashing
    if [ -n "$(git status --porcelain)" ]; then
	warning "Untracked files in site repo, stashing them."
	git stash -u --quiet
	stashed="true"
    fi

    # Move the readme so it won't be removed
    mv README.md "$BUILD_DIR"

    # Out with the old, in with the new
    git rm --quiet -r *
    cp -r "$BUILD_DIR"/* .

    # Stage and commit
    git add -A
    if [ -n "$(git status --porcelain -uno)" ]; then
	if git commit -m "$commit_msg"; then
	    echo "Commit successfully created!"
	    test -n "$stashed" && warning "Don't forget to pop the stash"
	else
	    error "Failed to create commit!"
	    exit 1
	fi
    else
	local unchanged_msg="No changes in site repo, nothing staged"
	if [ -n "$stashed" ]; then
	    unchanged_msg="$unchanged_msg (popping stash)"
	fi
	warning "$unchanged_msg"
    fi
}

build_and_update "$0" "$1"
