# Solidity PEGJS Grammar Parser 

> npm solidity-pegjs-parser

## Abstract

This takes `solidity-parser-sc` (npm package) and updates it and also provides a GitHub repository, as there is no repository listed under NPM.


## Overview


> original [consensys/solidity-parser](https://github.com/ConsenSys/solidity-parser) with additional project specific grammar rules

For code analysis of processing systems that pre-processing to deploy or run their tests.

## Updates to Grammar 

> A full list can be found under the `DIFF.md` document [here](/DIFF.md)
```diff
 HexStringLiteral
-  = HexToken StringLiteral
+  = HexToken val:StringLiteral {
+    return {
+      type: "HexLiteral",
+      value: val,
+      start: location().start.offset,
+      end: location().end.offset
+    };
+  }
```

### License

ISC
