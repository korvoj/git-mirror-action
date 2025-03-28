#!/bin/sh

set -e

SOURCE_REPO=$1
DESTINATION_REPO=$2
SOURCE_DIR=$(basename "$SOURCE_REPO")
DRY_RUN=$3
SINGLE_BRANCH=$4
SINGLE_BRANCH_NAME=$5

GIT_SSH_COMMAND="ssh -v"

echo "SOURCE=$SOURCE_REPO"
echo "DESTINATION=$DESTINATION_REPO"
echo "DRY RUN=$DRY_RUN"
echo "SINGLE_BRANCH=$SINGLE_BRANCH"
echo "SINGLE_BRANCH_NAME=$SINGLE_BRANCH_NAME"

if [ "$SINGLE_BRANCH" = "true" ]
then
    echo "INFO: Mirroring a single branch..."
    git clone --branch "$SINGLE_BRANCH_NAME" --single-branch "$SOURCE_REPO" "$SOURCE_DIR" && cd "$SOURCE_DIR"
    git fetch --prune origin
    if [ "$DRY_RUN" = "true" ]
    then
        echo "INFO: Dry Run, no data is pushed"
        git push --mirror --dry-run "$DESTINATION_REPO"
    else
        git push --mirror "$DESTINATION_REPO"
    fi
else
    echo "INFO: Mirroring all branches..."
    git clone --mirror "$SOURCE_REPO" "$SOURCE_DIR" && cd "$SOURCE_DIR"
    git remote set-url --push origin "$DESTINATION_REPO"
    git fetch -p origin
    # Exclude refs created by GitHub for pull request.
    git for-each-ref --format 'delete %(refname)' refs/pull | git update-ref --stdin

    if [ "$DRY_RUN" = "true" ]
    then
        echo "INFO: Dry Run, no data is pushed"
        git push --mirror --dry-run
    else
        git push --mirror
    fi
fi
