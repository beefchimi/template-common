# This script is useful for Yarn v1 projects.

function rebootYarnLegacy() {
  sh ./scripts/nuke-yarn.sh &&
  yarn install &&
  yarn run bootstrap &&
  npx yarn-deduplicate -s fewer yarn.lock &&
  yarn
}

rebootYarnLegacy
