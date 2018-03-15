#!/bin/bash
set -eo pipefail

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

cd $(git rev-parse --show-toplevel)

cp CHANGELOG.md CHANGELOG.md.bak
semantic-release \
    -slug Rossiar/test-goreleaser \
    -dry \
    -noci \
    -token ${GITHUB_TOKEN} \
    -ghr \
    -vf \
    -changelog CHANGELOG.md
cat CHANGELOG.md.bak >> CHANGELOG.md
rm CHANGELOG.md.bak
git fetch origin --tags

echo "Release created, creating commit release..."
git add CHANGELOG.md .ghr .version
RELEASE=$(cat .version)
git push origin --tags
git commit -m "release($RELEASE): release changelog"
# git tag -fa v$RELEASE -m "release $RELEASE by make_release.bash"
# git push -f origin v$RELEASE
git push origin

