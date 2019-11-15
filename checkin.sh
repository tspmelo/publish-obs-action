#!/bin/bash
#
# checkin.sh
#
# This script automates generation of a new tarball and spec file from a
# git clone for a package in OBS.
#

set -e

PACKAGE="$INPUT_OBS_PACKAGE"
CLONE="/github/workspace"
BASEDIR=$(pwd)

function _error_exit {
    echo >&2 $1
    exit $2
}

function _check_clone {
    local OPT="$1"
    if [ -z "$OPT" ] ; then
        _error_exit "Empty string sent to internal function _check_clone"
    fi
    if [ -e "$OPT/$PACKAGE.spec" ] ; then
        echo "$OPT looks like a $PACKAGE clone; using it"
    else
        _error_exit "$OPT does not appear to be a $PACKAGE clone" 1
    fi
}

_check_clone "$CLONE"

echo "Running \"osc rm *gz\" to nuke previous tarball"
if type osc > /dev/null 2>&1 ; then
    osc rm *gz
else
    _error_exit "osc not installed - cannot continue" 1
fi
if stat --printf='' *.gz 2>/dev/null ; then
    _error_exit "There are still files ending in gz in the current directory - clean up yourself!" 1
fi

THIS_DIR=$(pwd)
pushd $CLONE
if [ ! -d .git ]; then
    echo "no .git present.  run this from the base dir of the git checkout."
    exit 1
fi
GIT_SHA1=$(git describe --long --tags | cut -d"-" -f3)
echo "Extracting spec file"
VERSION=$(grep ^Version *spec | sed -r "s/^Version:\s+//")
VERSION="${VERSION}+$(date +%s).${GIT_SHA1}"
sed -i -e 's/^Version:.*/Version:        '$VERSION'/' $PACKAGE.spec
sed -i -e 's#^Source0:.*#Source0:        %{name}-%{version}.tar.gz#' $PACKAGE.spec
sed -i -e '/Source0/a %if 0%{?suse_version}\nSource98:       checkin.sh\nSource99:       README-checkin.txt\n%endif\n\n' $PACKAGE.spec
sed -i -e 'N;/^\n$/D;P;D;' $PACKAGE.spec  # collapse multiple adjacent newlines down to a single newline
cp $PACKAGE.spec $THIS_DIR
echo "Version number is ->$VERSION<-"
cd ..
cp -a workspace "$PACKAGE-$VERSION"
echo "Creating tarball"
tar cvfz $THIS_DIR/$PACKAGE-$VERSION.tar.gz --exclude .git "$PACKAGE-$VERSION"
popd

echo "Running \"osc add *gz\" to register the new tarball"
osc add *gz

echo "Done! Run \"osc ci --noservice\" to commit."
