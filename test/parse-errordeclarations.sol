pragma solidity >=0.5.0 <0.9.0;

error SomeError();

contract Greeter {
    function throwError() external pure {
        revert SomeError();
    }
}