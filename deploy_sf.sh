#!/usr/bin/env bash

# Deploy website to sourceforge
#
# Usage: ./deploy_sf [SOURCEFORGE_USERNAME]
#
# If the username is not provided as an argument,
# the SF_USER variable will be used if it is set.
# If SF_USER is not set, the login username is used.
#
# Set up ssh keys without passphrases
# to bypass the password prompts and make sure
# that the servers fingerprints are added before
# running this.

function deploy
{
    local origin_dir="$(pwd)"

    # Make sure the site generation script is present
    local gen_script="build.py"
    local script_dir=$(dirname $(readlink -f "$1"))
    if [ ! -e "$script_dir/$gen_script" ]; then
	echo "$gen_script is missing in $script_dir!"
	exit 1
    fi

    # If neither argument nor SF_USER is set, the variable being empty
    # will result in the active users name being used implicitly
    local username="$2"
    if [ -z "$username" ]; then
	username="$SF_USER"
    fi
    if [ -n "$username" ]; then
	username="$username""@"
    fi

    set -e

    # Build and package website
    cd "$script_dir"
    local BUILD_DIR
    BUILD_DIR="$(mktemp -d)"
    "./$gen_script" --output $BUILD_DIR

    cd "$BUILD_DIR"
    zip -q -r site.zip ./*


    # Server location variables
    local sf_site_dir="/home/project-web/yoshimi"
    local ssh_server="shell.sf.net"
    local sftp_server="web.sourceforge.net"


    # Put packaged site on server
    local sftp_cmd="put site.zip $sf_site_dir/site.zip"
    echo "Uploading archive..."
    echo  "$sftp_cmd" | sftp -q -b - "$username""$sftp_server"


    # Log in Remove old site files and extract the new ones
    ssh -q "$username""$ssh_server" create
    local ssh_cmd="cd $sf_site_dir/htdocs && rm -rf * && unzip -q ../site.zip"
    # End the session when finished, unless some previous step failed
    # (in which case the shell staying up is nice for manual investigation)
    ssh_cmd="$ssh_cmd && shutdown"
    echo "Removing old site and extracting new files..."
    ssh "$username""$ssh_server" "$ssh_cmd"


    # Clean up
    echo "Cleaning up..."
    cd "$origin_dir"
    rm -rf "$BUILD_DIR"
}

deploy "$0" "$1"
