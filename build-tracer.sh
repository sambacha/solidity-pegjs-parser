#!/bin/sh
echo "Building Traeer"
npx peggy --cache -o ./dist/parser.cjs ./src/solidity.pegjs --trace
npx peggy -o ./dist/imports_parser.cjs ./src/imports.pegjs --tracee
