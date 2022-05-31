#!/usr/bin/env bash

set -o errexit


check_mark="\033[1;32m✔\033[0m"
header() { echo -e "\n\033[1m$1\033[0m"; }

# TODO - Boilerplate message
header "Loading Nodejs/Browser Parser Buildtool\n"

npx peggy --cache -o ./dist/parser.cjs ./src/solidity.pegjs
npx peggy -o ./dist/imports_parser.cjs ./src/imports.pegjs
echo -e "\033[1A ${check_mark} Builing CommonJS Module... done"
echo -e " \033[1mInitialize parser imports...\033[0m"
sleep 1
npx peggy -o ./dist/imports_parser.cjs ./src/imports.pegjs
echo -e "\033[1A ${check_mark} Building PegJs Imports... done"

npx peggy --cache -o ./dist/parser.mjs ./src/solidity.pegjs --format es
npx peggy -o ./dist/imports_parser.mjs ./src/imports.pegjs --format es
echo -e "\033[1A ${check_mark} Builing ESM Module... done"
echo -e " \033[1mInitialize parser imports...\033[0m"
sleep 1

echo -e "\033[1A ${check_mark} Building ESM Imports... done"

npx peggy --cache -o ./dist/parser.umd.js ./src/solidity.pegjs --format umd
npx peggy -o ./dist/imports_parser.umd.js ./src/imports.pegjs --format umd
echo -e "\033[1A ${check_mark} Builing Browser UMD Module... done"
echo -e " \033[1mInitialize parser imports...\033[0m"
sleep 1
npx peggy -o ./dist/imports_parser.cjs ./src/imports.pegjs
echo -e "\033[1A ${check_mark} Building UMD Imports... done"

sleep 1
header "\n\nSuccessfuly compiled Solidity Pegjs Parsers for NodeJS/Browsers\n"
sleep 1
echo -e ".. exiting successfully"

exit 0