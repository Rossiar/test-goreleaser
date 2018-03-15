#!/bin/bash
set -eo pipefail
cd $(git rev-parse --show-toplevel)

CMD=$0

if ! git diff --cached --exit-code; then
    echo "You have staged changes."
    echo "Please unstage them with 'git reset' first."
    exit 1
fi


usage() {
    echo "$CMD [github token]"
    echo "You can specify the GitHub token through env var as well:"
    echo "export GITHUB_TOKEN=token"
    echo "To make a new token: https://github.com/settings/tokens"
    exit 1
}

if [ -n "$1" ]; then
    GITHUB_TOKEN=$1
fi

if [ -z "$GITHUB_TOKEN" ]; then
    usage
fi

if [ ! -f "CHANGELOG.md" ]; then
	echo "CHANGELOG.md is missing"
fi

if [ ! -f ".version" ]; then
  echo ".version file is missing"
fi

semantic-version \
    -token ${GITHUB_TOKEN} \
    -slug Rossiar/test-goreleaser \
    -vf \
    -changelog CHANGELOG.md

#echo "Release created, creating commit release..."
#git add CHANGELOG.md .ghr .version
#RELEASE=$(cat .version)
#git commit -m "release($RELEASE): release changelog"
#git push origin

