# This script is useful for Yarn only.

function nukeYarn() {
  rm -rf node_modules &&
  rm -rf yarn.lock &&
  # We don't always want to nuke these files:
  # rm -rf .yarn &&
  # rm -rf .yarnrc.yml &&
  rm -rf .pnp.cjs &&
  rm -rf .pnp.loader.mjs &&
  find ./packages -name "node_modules" -type d -maxdepth 2 -exec rm -rf {} + &&
  find ./packages -name "yarn.lock" -type f -maxdepth 2 -exec rm {} + &&
  yarn cache clean --all
}

nukeYarn
