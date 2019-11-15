#!/bin/bash

input="/github/workspace/CHANGELOG.md"
spec="/github/home/obs/$INPUT_OBS_PROJECT/$INPUT_OBS_PACKAGE/$INPUT_OBS_PACKAGE.spec"
changes="/github/home/obs/$INPUT_OBS_PROJECT/$INPUT_OBS_PACKAGE/$INPUT_OBS_PACKAGE.changes"

# Read the version
full_version=$(grep '^Version' $spec | sed -r "s/^Version:\s+//")
version=$(echo $full_version | sed -r "s/\+\S+$//")

# Prepare the Changelog
read -r -d '' header << EOM
-------------------------------------------------------------------
$(date -u) - $INPUT_FULL_NAME <$INPUT_OBS_EMAIL>
EOM

read -r -d '' change << EOM
- Update to $full_version:
EOM

# Append each change
while IFS= read -r line
do
  case "$line" in
    "## [$version"*) start=1 ;;
    "- "*)
      read -r -d '' change << EOM
$change
${line/- /  + }
EOM
      continue
      ;;
    "## "*) [ -z "$start" ] || break ;;
    * );;
  esac
done < "$input"

# Update the file
echo -e "$header\n\n$change\n\n$(cat $changes)" > $changes

# Prepare commit message
echo -e "$change" > /github/home/commit_message
