// Examples taken from the Solidity documentation online.

// for pragma version numbers, see https://docs.npmjs.com/misc/semver#versions
pragma solidity 0.4.0;
pragma solidity v0.4.0; // like npm
pragma solidity ^0.4.0;
pragma solidity >= 0.4.0;
pragma solidity <= 0.4.0;
pragma solidity < 0.4.0;
pragma solidity > 0.4.0;
pragma solidity != 0.4.0;
pragma solidity >=0.4.0 <0.4.8; // from https://github.com/ethereum/solidity/releases/tag/v0.4.0

pragma experimental ABIEncoderV2;

import "SomeFile.sol";
import "SomeFile.sol" as SomeOtherFile;
import * as SomeSymbol from "AnotherFile.sol";
import {symbol1 as alias, symbol2} from "File.sol";

interface i {
  function f();
}
