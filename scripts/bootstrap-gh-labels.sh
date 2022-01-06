# TODO: This script currently does not work in ZSH (must use bash).
# Likely has something to do with this:
# https://github.com/stedolan/jq/issues/501

# This script is taken from:
# https://douglascayers.com/2019/08/01/how-to-export-and-import-github-issue-labels-between-projects
# https://gist.github.com/douglascayers/9fbc6f2ad899f12030c31f428f912b5c#file-github-copy-labels-sh

# This script uses the GitHub Labels REST API:
# https://developer.github.com/v3/issues/labels/
# as well as the `jq` program:
# https://stedolan.github.io/jq

# TODO: Would be great if we deleted the default GitHub labels first.
# TODO: Consider making the `src-repo` an argument.
# TODO: Will be ideal to accept a prompt for arguments.

# Argument 1: string (repo name)
# Argument 2: string (personal access token)
function bootstrapGhLabels() {
  # TODO: This condition does not appear to be working correctly.
  if [ $# -lt 2 ]; then
    echo "You must provide a target repo name, as well as your GitHub personal access token."
     return 1 2>/dev/null
     exit 1
  fi

  if ! command -v jq &> /dev/null; then
    echo "The jq program could not be found!"
    echo "Please see: https://stedolan.github.io/jq/download/"
     return 1 2>/dev/null
     exit 1
  fi

  # If you use GitHub Enterprise, change this to "https://<your_domain>/api/v3"
  local GH_DOMAIN="https://api.github.com"

  # The source repository whose labels to copy.
  local SRC_GH_USER="beefchimi"
  local SRC_GH_REPO="template-common"

  # The target repository to add or update labels.
  local TGT_GH_USER="beefchimi"
  local TGT_GH_REPO=$1

  # A valid personal access token.
  local GH_TOKEN=$2

  # ---------------------------------------------------------

  # Headers used in curl commands
  local GH_ACCEPT_HEADER="Accept: application/vnd.github.symmetra-preview+json"
  local GH_AUTH_HEADER="Authorization: Bearer $GH_TOKEN"

  # Separated to its own variable, as a `?` induces some glob matching.
  local GH_LABELS_ENDPOINT="${GH_DOMAIN}/repos/${SRC_GH_USER}/${SRC_GH_REPO}/labels?per_page=100"

  # Bash for-loop over JSON array with jq
  # https://starkandwayne.com/blog/bash-for-loop-over-json-array-using-jq/
  sourceLabelsJson64=$(curl --silent -H "$GH_ACCEPT_HEADER" -H "$GH_AUTH_HEADER" $GH_LABELS_ENDPOINT | jq '[ .[] | { "name": .name, "color": .color, "description": .description } ]' | jq -r '.[] | @base64' )

  # For each label from source repo,
  # invoke the GitHub API to create or update the label in the target repo
  for sourceLabelJson64 in $sourceLabelsJson64; do
    # base64 decode the json
    sourceLabelJson=$(echo ${sourceLabelJson64} | base64 --decode | jq -r '.')

    # Try to create the label
    # POST /repos/:owner/:repo/labels { name, color, description }
    # https://developer.github.com/v3/issues/labels/#create-a-label
    createLabelResponse=$(echo $sourceLabelJson | curl --silent -X POST -d @- -H "$GH_ACCEPT_HEADER" -H "$GH_AUTH_HEADER" ${GH_DOMAIN}/repos/${TGT_GH_USER}/${TGT_GH_REPO}/labels)

    # If creation failed, the response doesn't include an id and jq returns 'null'
    createdLabelId=$(echo $createLabelResponse | jq -r '.id')

    # If label wasn't created, maybe it's because it already exists... so try to update it
    if [ "$createdLabelId" == "null" ]; then
      updateLabelResponse=$(echo $sourceLabelJson | curl --silent -X PATCH -d @- -H "$GH_ACCEPT_HEADER" -H "$GH_AUTH_HEADER" ${GH_DOMAIN}/repos/${TGT_GH_USER}/${TGT_GH_REPO}/labels/$(echo $sourceLabelJson | jq -r '.name | @uri'))
      echo "Update label response:\n"$updateLabelResponse"\n"
    else
      echo "Create label response:\n"$createLabelResponse"\n"
    fi
  done
}
