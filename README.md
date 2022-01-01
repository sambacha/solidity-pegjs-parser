# Solidity PEGJS Grammar Parser

![nodejs](https://github.com/sambacha/solidity-pegjs-parser/workflows/nodejs/badge.svg)

> [GitHub Source](https://github.com/sambacha/solidity-pegjs-parser)

> [npm solidity-pegjs-parser](https://www.npmjs.com/package/solidity-pegjs-parser)

## Abstract

`$ npm install pegis-solidity`

Ideal for AST use-cases

## Overview

pegis-solidity

> original
> [consensys/solidity-parser](https://github.com/ConsenSys/solidity-parser) with
> additional project specific grammar rules

- Main change is adoption of `peggy` as the `peg.js` framework has been
  stagnant, this is a drop in replacement.

#### TODO

- Typescript support in next release via `ts-peggy`
- Documentation update

## Reference for Changes

> v2 changes start here: 18 August 2021

- feat(refactor): migrate to peggy and various improvements
  [`87b594a`](https://github.com/sambacha/solidity-pegjs-parser/commit/87b594ad21e1221b5e3574ac8f69b5751a9ce4be)
- build(refactor): improve build process
  [`0de7a77`](https://github.com/sambacha/solidity-pegjs-parser/commit/0de7a774bf2edd51b03a865e435b30a02feb5313)
- chore(repo): remove dead and legacy artifacts
  [`012fec1`](https://github.com/sambacha/solidity-pegjs-parser/commit/012fec1b5000017a6125c38580d76a3299f597cc)

### Usage

```js
import { solidityparser } from 'pegis-solidity';
```

### command line

`$ ./node_modules/.boin/pegis-solidity $PWD/file_name.js`

#### Example

Consider this solidity code as input:

```solidity
import "Foo.sol";

contract MyContract {
  mapping (uint => address) public addresses;
}
```

Generated output as AST output:

```json
{
  "type": "Program",
  "body": [
    {
      "type": "ImportStatement",
      "value": "Foo.sol"
    },
    {
      "type": "ContractStatement",
      "name": "MyContract",
      "is": [],
      "body": [
        {
          "type": "ExpressionStatement",
          "expression": {
            "type": "DeclarativeExpression",
            "name": "addresses",
            "literal": {
              "type": "Type",
              "literal": {
                "type": "MappingExpression",
                "from": {
                  "type": "Type",
                  "literal": "uint",
                  "members": [],
                  "array_parts": []
                },
                "to": {
                  "type": "Type",
                  "literal": "address",
                  "members": [],
                  "array_parts": []
                }
              },
              "members": [],
              "array_parts": []
            },
            "is_constant": false,
            "is_public": true
          }
        }
      ]
    }
  ]
}
```

```js
var SolidityParser = require('pegis-solidity');

// Parse Solidity code as a string:
var result = SolidityParser.parse('contract { ... }');

// Or, parse a file:
var result = SolidityParser.parseFile('./path/to/file.sol');
```

## Updates to Grammar

> A full list can be found under the `DIFF.md` document [here](/docs/DIFF.md)

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

ISC / MIT
