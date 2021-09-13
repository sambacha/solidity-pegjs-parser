#!/usr/bin/env node

"use strict";

(function() {
  var SolidityParser, echo, file, fs, i, len, ref, src;

  fs = require('fs');

  SolidityParser = require("./index.js");

  echo = function(msg) {
    return process.stdout.write(JSON.stringify(msg, null, 2) + '\n');
  };

  if (process.argv.length > 2) {
    ref = process.argv.slice(2);
    for (i = 0, len = ref.length; i < len; i++) {
      file = ref[i];
      src = fs.readFileSync(file, 'utf8');
      try {
        echo(SolidityParser.parse(src));
      } catch (err) {
        process.stderr.write(
          err.name === 'SyntaxError' 
            ? "Location: " + JSON.stringify(err.location, null, 4) + "\n" + err
            : err.name + ': ' + err.message
        );
      }
    }
  } else {
    echo("Solidity Parser: file...");
  }

}).call(this);
