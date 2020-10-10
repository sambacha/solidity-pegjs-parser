contract Contract {
    uint public fallback;
  function set(uint x) public {
    fallback = x;
  }
}
