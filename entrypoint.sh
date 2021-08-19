#!/bin/bash
set -o errexit
export NODE_ENV='production'
export SOURCE_COMMIT="${SOURCE_COMMIT:-$(git rev-parse HEAD)}"

DIR="node_modules/.bin"
if [ -d "$DIR" ]; then
  echo "Building Solidity Parser..."
  echo "Parser SOURCE_COMMIT"
  echo "SOURCE_COMMIT: $SOURCE_COMMIT"
  sleep 1
  rm -rf build/
  npx peggy --cache -o ./build/parser.js ./solidity.pegjs
  npx peggy -o ./build/imports_parser.js ./imports.pegjs
  echo "Geneated parser successfully"
  exit 0
else
  echo "Error: ${DIR} not found. Try installing with npm and not yarn"
  exit 1
fi
