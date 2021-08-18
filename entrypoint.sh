#!/bin/bash
set -o errexit

DIR="node_modules/.bin"
if [ -d "$DIR" ]; then
  ### Take action if $DIR exists ###
  echo "Building Solidity Parser..."
  ./node_modules/.bin/peggy -o ./build/parser.js ./lib/solidity.pegjs
  ./node_modules/.bin/peggy -o  ./build/imports_parser.js ./lib/imports.pegjs
  echo "Geneated parser successfully"
else
  echo "Error: ${DIR} not found. Try installing with npm and not yarn"
  exit 1
fi
