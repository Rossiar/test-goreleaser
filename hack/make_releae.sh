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

git fetch --tags
cp CHANGELOG.md CHANGELOG.md.bak
semantic-version \
    -token ${GITHUB_TOKEN} \
    -slug Rossiar/test-goreleaser \
    -vf \
    -changelog CHANGELOG.md
cat CHANGELOG.md.bak >> CHANGELOG.md
rm CHANGELOG.md.bak

git add CHANGELOG.md .version
RELEASE=$(cat .version)
git commit -m "chore(release): release v$RELEASE"
git push origin

semantic-release \
    -slug Rossiar/test-goreleaser \
    -noci \
    -token $GITHUB_TOKEN

