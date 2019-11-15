#!/bin/sh -l

install -Dv /dev/null ~/.config/osc/oscrc
cat > ~/.config/osc/oscrc << ENDOFFILE
[general]
apiurl = https://api.opensuse.org

[https://api.opensuse.org]
user = $INPUT_OBS_USER
pass = $INPUT_OBS_PASS
email = $INPUT_OBS_EMAIL
ENDOFFILE

mkdir ~/obs
cd ~/obs
osc co $INPUT_OBS_PROJECT $INPUT_OBS_PACKAGE
cd $INPUT_OBS_PROJECT/$INPUT_OBS_PACKAGE

bash /checkin.sh # Generates a new tarball and spec file
osc status # Should now show a new tarball and modified .spec
bash /changelog.sh # Replaces "osc vc"
osc ci --noservice -F /github/home/commit_message # to commit to source OBS project
osc results
