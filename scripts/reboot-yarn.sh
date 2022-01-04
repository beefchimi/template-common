# This script is useful for Yarn v2+ projects.

function yarnSetup() {
  # We may want to include plugin installs
  yarn set version stable &&
  yarn install
}

function rebootYarn() {
  sh ./scripts/nuke-yarn.sh && yarnSetup
}

rebootYarn
