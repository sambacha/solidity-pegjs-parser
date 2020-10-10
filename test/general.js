var SolidityParser = require("../index.js")
var assert = require("assert")

describe("Parser", function () {
  it("parses documentation examples without throwing an error", function () {
    SolidityParser.parseFile("./test/doc_examples.sol", true)
  })

  it("parses documentation examples using imports parser without throwing an error", function () {
    SolidityParser.parseFile("./test/doc_examples.sol", "imports", true)
  })

  it("names constructors", function () {
    const parsed = SolidityParser.parseFile("./test/constructor.sol", true)
    assert.equal(parsed.body[0].body[0].name, "constructor")
  })

  it("names fallback functions", function () {
    const parsed = SolidityParser.parseFile("./test/fallback.sol", true)
    assert.equal(parsed.body[0].body[0].name, "fallback")
  })
})

describe("Built Parser", function () {
  it("parses documentation examples without throwing an error", function () {
    SolidityParser.parseFile("./test/doc_examples.sol", false)
  })

  it("parses documentation examples using imports parser without throwing an error", function () {
    SolidityParser.parseFile("./test/doc_examples.sol", "imports", false)
  })
})
