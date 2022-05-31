/*
 * Solidity Grammar, based on Javascript grammar.
 * The following comment is from that grammar:
 * ==================
 *
 * Based on grammar from ECMA-262, 5.1 Edition [1]. Generated parser builds a
 * syntax tree compatible with Mozilla SpiderMonkey Parser API [2]. Properties
 * and node types reflecting features not present in ECMA-262 are not included.
 *
 * Limitations:
 *
 *   * Non-BMP characters are completely ignored to avoid surrogate pair
 *     handling.
 *
 *   * One can create identifiers containing illegal characters using Unicode
 *     escape sequences. For example, "abcd\u0020efgh" is not a valid
 *     identifier, but it is accepted by the parser.
 *
 *   * Strict mode is not recognized. This means that within strict mode code,
 *     "implements", "interface", "let", "package", "private", "protected",
 *     "public", "static" and "yield" can be used as names. Many other
 *     restrictions and exceptions from Annex C are also not applied.
 *
 * All the limitations could be resolved, but the costs would likely outweigh
 * the benefits.
 *
 * Many thanks to inimino [3] for his grammar [4] which helped me to solve some
 * problems (such as automatic semicolon insertion) and also served to double
 * check that I converted the original grammar correctly.
 *
 * [1] http://www.ecma-international.org/publications/standards/Ecma-262.htm
 * [2] https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API
 * [3] http://inimino.org/~inimino/blog/
 * [4] http://boshi.inimino.org/3box/asof/1270029991384/PEG/ECMAScript_unified.peg
 */

{
  var TYPES_TO_PROPERTY_NAMES = {
    CallExpression:   "callee",
    MemberExpression: "object"
  };

  String.prototype.replaceAll = function(search, replacement) {
    var target = this;
    return target.split(search).join(replacement);
  };

  function filledArray(count, value) {
    var result = new Array(count), i;

    for (i = 0; i < count; i++) {
      result[i] = value;
    }

    return result;
  }

  function extractOptional(optional, index) {
    return optional ? optional[index] : null;
  }

  function extractList(list, index) {
    var result = new Array(list.length), i;

    for (i = 0; i < list.length; i++) {
      result[i] = list[i][index];
    }

    return result;
  }

  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }

  function buildTree(head, tail, builder) {
    var result = head, i;

    for (i = 0; i < tail.length; i++) {
      result = builder(result, tail[i]);
    }

    return result;
  }

  function buildBinaryExpression(head, tail) {
    return buildTree(head, tail, function(result, element) {
      return {
        type:     "BinaryExpression",
        operator: element[1],
        left:     result,
        right:    element[3],
        start: result.start,
        end: element[3].end
      };
    });
  }

  function buildLogicalExpression(head, tail) {
    return buildTree(head, tail, function(result, element) {
      return {
        type:     "LogicalExpression",
        operator: element[1],
        left:     result,
        right:    element[3],
        start: location().start.offset,
        end: location().end.offset
      };
    });
  }

  function optionalList(value) {
    return value !== null ? value : [];
  }

  function normalizeVersionLiteral(item) {
    if (item.constructor.name === 'Array') {
      item [1] = item [1].join ('');
      item = item.join ('');
    }

    return item;
  }
}

Start
  = __ program:Program __ { return program; }

/* ----- A.1 Lexical Grammar ----- */

SourceCharacter
  = .

WhiteSpace "whitespace"
  = "\t"
  / "\v"
  / "\f"
  / " "
  / "\u00A0"
  / "\uFEFF"
  / Zs

LineTerminator
  = [\n\r\u2028\u2029]

LineTerminatorSequence "end of line"
  = "\n"
  / "\r\n"
  / "\r"
  / "\u2028"
  / "\u2029"

Comment "comment"
  = MultiLineComment
  / SingleLineComment

MultiLineComment
  = "/*" (!"*/" SourceCharacter)* "*/"

MultiLineCommentNoLineTerminator
  = "/*" (!("*/" / LineTerminator) SourceCharacter)* "*/"

SingleLineComment
  = "//" (!LineTerminator SourceCharacter)*

Identifier
  = !ReservedWord name:IdentifierName { return name; }

IdentifierName "identifier"
  = head:IdentifierStart tail:IdentifierPart* {
      return {
        type: "Identifier",
        name: head + tail.join(""),
        start: location().start.offset,
        end: location().end.offset
      };
    }

IdentifierStart
  = UnicodeLetter
  / "$"
  / "_"

IdentifierPart
  = IdentifierStart
  / UnicodeDigit

AddressPayable
  = "address" __  PayableToken {
      return {
        type: "Identifier",
        name: "address_payable",
        start: location().start.offset,
        end: location().end.offset
      };
    }

UnicodeLetter
  = Lu
  / Ll
  / Lt
  / Lm
  / Lo
  / Nl

UnicodeCombiningMark
  = Mn
  / Mc

UnicodeDigit
  = Nd

UnicodeConnectorPunctuation
  = Pc

ReservedWord
  = Keyword
  / NullToken
  / BooleanLiteral

Keyword
  = BreakToken
  / ContinueToken
  / ContractToken
  / InterfaceToken
  / DeleteToken
  / DoToken
  / ElseToken
  / ForToken
  / FunctionToken
  / HexToken
  / IfToken
  / ImportToken
  / NewToken
  / PragmaToken
  / ReturnToken
  / ReturnsToken
  / ThisToken
  / ThrowToken
  / VarToken
  / WhileToken
  / TryToken
  / CatchToken
  / EmitToken
  
Literal
  = BooleanLiteral
  / DenominationLiteral
  / NumericLiteral
  / HexStringLiteral
  / StringLiteral
  / VersionLiteral

BooleanLiteral
  = TrueToken  { return { type: "Literal", value: true, start: location().start.offset, end: location().end.offset }; }
  / FalseToken { return { type: "Literal", value: false, start: location().start.offset, end: location().end.offset }; }

/*
 * The "!(IdentifierStart / DecimalDigit)" predicate is not part of the official
 * grammar, it comes from text in section 7.8.3.
 */
NumericLiteral "number"
  = literal:HexIntegerLiteral !(IdentifierStart / DecimalDigit) {
      return literal;
    }
  / literal:DecimalLiteral !(IdentifierStart / DecimalDigit) {
      return literal;
    }

Denomination
  = token:(WeiToken
  / GweiToken
  / SzaboToken
  / FinneyToken
  / EtherToken
  / SecondsToken
  / MinutesToken
  / HoursToken
  / DaysToken
  / WeeksToken
  / YearsToken)
  {
    return token[0];
  }

DenominationLiteral
  = literal:NumericLiteral __ denomination:Denomination
  {
    return {
      type: "DenominationLiteral",
      literal: literal.value,
      denomination: denomination,
      start: location().start.offset,
      end: location().end.offset
    }
  }

DecimalLiteral
  = DecimalIntegerLiteral "." DecimalDigit* ExponentPart? {
      return { type: "Literal", value: parseFloat(text().replaceAll('_', '')), start: location().start.offset, end: location().end.offset };
    }
  / "." DecimalDigit+ ExponentPart? {
      return { type: "Literal", value: parseFloat(text().replaceAll('_', '')), start: location().start.offset, end: location().end.offset };
    }
  / DecimalIntegerLiteral ExponentPart? {
      return { type: "Literal", value: parseFloat(text().replaceAll('_', '')), start: location().start.offset, end: location().end.offset };
    }

DecimalIntegerLiteral
  = "0"
  / NonZeroDigit DecimalDigit*

DecimalDigit
  = [0-9_]

NonZeroDigit
  = [1-9]

ExponentPart
  = ExponentIndicator SignedInteger

ExponentIndicator
  = "e"i

SignedInteger
  = [+-]? DecimalDigit+

HexIntegerLiteral
  = "0x"i digits:$HexDigit+ {
      return { type: "Literal", value: "0x" + digits, start: location().start.offset, end: location().end.offset };
     }

HexDigit
  = [0-9a-f]i

StringLiteral "string"
  = '"' chars:DoubleStringCharacter* '"' {
      return { type: "Literal", value: chars.join(""), start: location().start.offset, end: location().end.offset };
    }
  / "'" chars:SingleStringCharacter* "'" {
      return { type: "Literal", value: chars.join(""), start: location().start.offset, end: location().end.offset };
    }

HexStringLiteral
  = HexToken val:StringLiteral {
    return {
      type: "HexLiteral",
      value: val,
      start: location().start.offset,
      end: location().end.offset
    };
  }

DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation

SingleStringCharacter
  = !("'" / "\\" / LineTerminator) SourceCharacter { return text(); }
  / "\\" sequence:EscapeSequence { return sequence; }
  / LineContinuation

LineContinuation
  = "\\" LineTerminatorSequence { return ""; }

EscapeSequence
  = CharacterEscapeSequence
  / "0" !DecimalDigit { return "\0"; }
  / HexEscapeSequence
  / UnicodeEscapeSequence

CharacterEscapeSequence
  = SingleEscapeCharacter
  / NonEscapeCharacter

SingleEscapeCharacter
  = "'"
  / '"'
  / "\\"
  / "b"  { return "\b";   }
  / "f"  { return "\f";   }
  / "n"  { return "\n";   }
  / "r"  { return "\r";   }
  / "t"  { return "\t";   }
  / "v"  { return "\x0B"; }   // IE does not recognize "\v".

NonEscapeCharacter
  = !(EscapeCharacter / LineTerminator) SourceCharacter { return text(); }

EscapeCharacter
  = SingleEscapeCharacter
  / DecimalDigit
  / "x"
  / "u"

HexEscapeSequence
  = "x" digits:$(HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

UnicodeEscapeSequence
  = "u" digits:$(HexDigit HexDigit HexDigit HexDigit) {
      return String.fromCharCode(parseInt(digits, 16));
    }

VersionLiteral
  = operator:(RelationalOperator / EqualityPragmaOperator / BitwiseXOROperator / Tilde)? __ ("v")? major:DecimalIntegerLiteral minor:("." DecimalIntegerLiteral)? patch:("." DecimalIntegerLiteral)? {
    if (patch === null) {
      patch = 0;
    } else {
      patch = patch[1];
    }

    if (minor === null) {
      minor = 0;
    } else {
      minor = minor[1];
    }

    return {
      type: "VersionLiteral",
      operator: operator,
      version: (normalizeVersionLiteral(major) + "." + normalizeVersionLiteral(minor) + "." + normalizeVersionLiteral(patch)),
      start: location().start.offset,
      end: location().end.offset
    };
  }

/*
 * Unicode Character Categories
 *
 * Extracted from the following Unicode Character Database file:
 *
 *   http://www.unicode.org/Public/8.0.0/ucd/extracted/DerivedGeneralCategory.txt
 *
 * Unix magic used:
 *
 *   grep "; $CATEGORY" DerivedGeneralCategory.txt |   # Filter characters
 *     cut -f1 -d " " |                                # Extract code points
 *     grep -v '[0-9a-fA-F]\{5\}' |                    # Exclude non-BMP characters
 *     sed -e 's/\.\./-/' |                            # Adjust formatting
 *     sed -e 's/\([0-9a-fA-F]\{4\}\)/\\u\1/g' |       # Adjust formatting
 *     tr -d '\n'                                      # Join lines
 *
 * ECMA-262 allows using Unicode 3.0 or later, version 8.0.0 was the latest one
 * at the time of writing.
 *
 * Non-BMP characters are completely ignored to avoid surrogate pair handling
 * (detecting surrogate pairs isn't possible with a simple character class and
 * other methods would degrade performance). I don't consider it a big deal as
 * even parsers in JavaScript engines of common browsers seem to ignore them.
 */

// Letter, Lowercase
Ll = [\u0061-\u007A\u00B5\u00DF-\u00F6\u00F8-\u00FF\u0101\u0103\u0105\u0107\u0109\u010B\u010D\u010F\u0111\u0113\u0115\u0117\u0119\u011B\u011D\u011F\u0121\u0123\u0125\u0127\u0129\u012B\u012D\u012F\u0131\u0133\u0135\u0137-\u0138\u013A\u013C\u013E\u0140\u0142\u0144\u0146\u0148-\u0149\u014B\u014D\u014F\u0151\u0153\u0155\u0157\u0159\u015B\u015D\u015F\u0161\u0163\u0165\u0167\u0169\u016B\u016D\u016F\u0171\u0173\u0175\u0177\u017A\u017C\u017E-\u0180\u0183\u0185\u0188\u018C-\u018D\u0192\u0195\u0199-\u019B\u019E\u01A1\u01A3\u01A5\u01A8\u01AA-\u01AB\u01AD\u01B0\u01B4\u01B6\u01B9-\u01BA\u01BD-\u01BF\u01C6\u01C9\u01CC\u01CE\u01D0\u01D2\u01D4\u01D6\u01D8\u01DA\u01DC-\u01DD\u01DF\u01E1\u01E3\u01E5\u01E7\u01E9\u01EB\u01ED\u01EF-\u01F0\u01F3\u01F5\u01F9\u01FB\u01FD\u01FF\u0201\u0203\u0205\u0207\u0209\u020B\u020D\u020F\u0211\u0213\u0215\u0217\u0219\u021B\u021D\u021F\u0221\u0223\u0225\u0227\u0229\u022B\u022D\u022F\u0231\u0233-\u0239\u023C\u023F-\u0240\u0242\u0247\u0249\u024B\u024D\u024F-\u0293\u0295-\u02AF\u0371\u0373\u0377\u037B-\u037D\u0390\u03AC-\u03CE\u03D0-\u03D1\u03D5-\u03D7\u03D9\u03DB\u03DD\u03DF\u03E1\u03E3\u03E5\u03E7\u03E9\u03EB\u03ED\u03EF-\u03F3\u03F5\u03F8\u03FB-\u03FC\u0430-\u045F\u0461\u0463\u0465\u0467\u0469\u046B\u046D\u046F\u0471\u0473\u0475\u0477\u0479\u047B\u047D\u047F\u0481\u048B\u048D\u048F\u0491\u0493\u0495\u0497\u0499\u049B\u049D\u049F\u04A1\u04A3\u04A5\u04A7\u04A9\u04AB\u04AD\u04AF\u04B1\u04B3\u04B5\u04B7\u04B9\u04BB\u04BD\u04BF\u04C2\u04C4\u04C6\u04C8\u04CA\u04CC\u04CE-\u04CF\u04D1\u04D3\u04D5\u04D7\u04D9\u04DB\u04DD\u04DF\u04E1\u04E3\u04E5\u04E7\u04E9\u04EB\u04ED\u04EF\u04F1\u04F3\u04F5\u04F7\u04F9\u04FB\u04FD\u04FF\u0501\u0503\u0505\u0507\u0509\u050B\u050D\u050F\u0511\u0513\u0515\u0517\u0519\u051B\u051D\u051F\u0521\u0523\u0525\u0527\u0529\u052B\u052D\u052F\u0561-\u0587\u13F8-\u13FD\u1D00-\u1D2B\u1D6B-\u1D77\u1D79-\u1D9A\u1E01\u1E03\u1E05\u1E07\u1E09\u1E0B\u1E0D\u1E0F\u1E11\u1E13\u1E15\u1E17\u1E19\u1E1B\u1E1D\u1E1F\u1E21\u1E23\u1E25\u1E27\u1E29\u1E2B\u1E2D\u1E2F\u1E31\u1E33\u1E35\u1E37\u1E39\u1E3B\u1E3D\u1E3F\u1E41\u1E43\u1E45\u1E47\u1E49\u1E4B\u1E4D\u1E4F\u1E51\u1E53\u1E55\u1E57\u1E59\u1E5B\u1E5D\u1E5F\u1E61\u1E63\u1E65\u1E67\u1E69\u1E6B\u1E6D\u1E6F\u1E71\u1E73\u1E75\u1E77\u1E79\u1E7B\u1E7D\u1E7F\u1E81\u1E83\u1E85\u1E87\u1E89\u1E8B\u1E8D\u1E8F\u1E91\u1E93\u1E95-\u1E9D\u1E9F\u1EA1\u1EA3\u1EA5\u1EA7\u1EA9\u1EAB\u1EAD\u1EAF\u1EB1\u1EB3\u1EB5\u1EB7\u1EB9\u1EBB\u1EBD\u1EBF\u1EC1\u1EC3\u1EC5\u1EC7\u1EC9\u1ECB\u1ECD\u1ECF\u1ED1\u1ED3\u1ED5\u1ED7\u1ED9\u1EDB\u1EDD\u1EDF\u1EE1\u1EE3\u1EE5\u1EE7\u1EE9\u1EEB\u1EED\u1EEF\u1EF1\u1EF3\u1EF5\u1EF7\u1EF9\u1EFB\u1EFD\u1EFF-\u1F07\u1F10-\u1F15\u1F20-\u1F27\u1F30-\u1F37\u1F40-\u1F45\u1F50-\u1F57\u1F60-\u1F67\u1F70-\u1F7D\u1F80-\u1F87\u1F90-\u1F97\u1FA0-\u1FA7\u1FB0-\u1FB4\u1FB6-\u1FB7\u1FBE\u1FC2-\u1FC4\u1FC6-\u1FC7\u1FD0-\u1FD3\u1FD6-\u1FD7\u1FE0-\u1FE7\u1FF2-\u1FF4\u1FF6-\u1FF7\u210A\u210E-\u210F\u2113\u212F\u2134\u2139\u213C-\u213D\u2146-\u2149\u214E\u2184\u2C30-\u2C5E\u2C61\u2C65-\u2C66\u2C68\u2C6A\u2C6C\u2C71\u2C73-\u2C74\u2C76-\u2C7B\u2C81\u2C83\u2C85\u2C87\u2C89\u2C8B\u2C8D\u2C8F\u2C91\u2C93\u2C95\u2C97\u2C99\u2C9B\u2C9D\u2C9F\u2CA1\u2CA3\u2CA5\u2CA7\u2CA9\u2CAB\u2CAD\u2CAF\u2CB1\u2CB3\u2CB5\u2CB7\u2CB9\u2CBB\u2CBD\u2CBF\u2CC1\u2CC3\u2CC5\u2CC7\u2CC9\u2CCB\u2CCD\u2CCF\u2CD1\u2CD3\u2CD5\u2CD7\u2CD9\u2CDB\u2CDD\u2CDF\u2CE1\u2CE3-\u2CE4\u2CEC\u2CEE\u2CF3\u2D00-\u2D25\u2D27\u2D2D\uA641\uA643\uA645\uA647\uA649\uA64B\uA64D\uA64F\uA651\uA653\uA655\uA657\uA659\uA65B\uA65D\uA65F\uA661\uA663\uA665\uA667\uA669\uA66B\uA66D\uA681\uA683\uA685\uA687\uA689\uA68B\uA68D\uA68F\uA691\uA693\uA695\uA697\uA699\uA69B\uA723\uA725\uA727\uA729\uA72B\uA72D\uA72F-\uA731\uA733\uA735\uA737\uA739\uA73B\uA73D\uA73F\uA741\uA743\uA745\uA747\uA749\uA74B\uA74D\uA74F\uA751\uA753\uA755\uA757\uA759\uA75B\uA75D\uA75F\uA761\uA763\uA765\uA767\uA769\uA76B\uA76D\uA76F\uA771-\uA778\uA77A\uA77C\uA77F\uA781\uA783\uA785\uA787\uA78C\uA78E\uA791\uA793-\uA795\uA797\uA799\uA79B\uA79D\uA79F\uA7A1\uA7A3\uA7A5\uA7A7\uA7A9\uA7B5\uA7B7\uA7FA\uAB30-\uAB5A\uAB60-\uAB65\uAB70-\uABBF\uFB00-\uFB06\uFB13-\uFB17\uFF41-\uFF5A]

// Letter, Modifier
Lm = [\u02B0-\u02C1\u02C6-\u02D1\u02E0-\u02E4\u02EC\u02EE\u0374\u037A\u0559\u0640\u06E5-\u06E6\u07F4-\u07F5\u07FA\u081A\u0824\u0828\u0971\u0E46\u0EC6\u10FC\u17D7\u1843\u1AA7\u1C78-\u1C7D\u1D2C-\u1D6A\u1D78\u1D9B-\u1DBF\u2071\u207F\u2090-\u209C\u2C7C-\u2C7D\u2D6F\u2E2F\u3005\u3031-\u3035\u303B\u309D-\u309E\u30FC-\u30FE\uA015\uA4F8-\uA4FD\uA60C\uA67F\uA69C-\uA69D\uA717-\uA71F\uA770\uA788\uA7F8-\uA7F9\uA9CF\uA9E6\uAA70\uAADD\uAAF3-\uAAF4\uAB5C-\uAB5F\uFF70\uFF9E-\uFF9F]

// Letter, Other
Lo = [\u00AA\u00BA\u01BB\u01C0-\u01C3\u0294\u05D0-\u05EA\u05F0-\u05F2\u0620-\u063F\u0641-\u064A\u066E-\u066F\u0671-\u06D3\u06D5\u06EE-\u06EF\u06FA-\u06FC\u06FF\u0710\u0712-\u072F\u074D-\u07A5\u07B1\u07CA-\u07EA\u0800-\u0815\u0840-\u0858\u08A0-\u08B4\u0904-\u0939\u093D\u0950\u0958-\u0961\u0972-\u0980\u0985-\u098C\u098F-\u0990\u0993-\u09A8\u09AA-\u09B0\u09B2\u09B6-\u09B9\u09BD\u09CE\u09DC-\u09DD\u09DF-\u09E1\u09F0-\u09F1\u0A05-\u0A0A\u0A0F-\u0A10\u0A13-\u0A28\u0A2A-\u0A30\u0A32-\u0A33\u0A35-\u0A36\u0A38-\u0A39\u0A59-\u0A5C\u0A5E\u0A72-\u0A74\u0A85-\u0A8D\u0A8F-\u0A91\u0A93-\u0AA8\u0AAA-\u0AB0\u0AB2-\u0AB3\u0AB5-\u0AB9\u0ABD\u0AD0\u0AE0-\u0AE1\u0AF9\u0B05-\u0B0C\u0B0F-\u0B10\u0B13-\u0B28\u0B2A-\u0B30\u0B32-\u0B33\u0B35-\u0B39\u0B3D\u0B5C-\u0B5D\u0B5F-\u0B61\u0B71\u0B83\u0B85-\u0B8A\u0B8E-\u0B90\u0B92-\u0B95\u0B99-\u0B9A\u0B9C\u0B9E-\u0B9F\u0BA3-\u0BA4\u0BA8-\u0BAA\u0BAE-\u0BB9\u0BD0\u0C05-\u0C0C\u0C0E-\u0C10\u0C12-\u0C28\u0C2A-\u0C39\u0C3D\u0C58-\u0C5A\u0C60-\u0C61\u0C85-\u0C8C\u0C8E-\u0C90\u0C92-\u0CA8\u0CAA-\u0CB3\u0CB5-\u0CB9\u0CBD\u0CDE\u0CE0-\u0CE1\u0CF1-\u0CF2\u0D05-\u0D0C\u0D0E-\u0D10\u0D12-\u0D3A\u0D3D\u0D4E\u0D5F-\u0D61\u0D7A-\u0D7F\u0D85-\u0D96\u0D9A-\u0DB1\u0DB3-\u0DBB\u0DBD\u0DC0-\u0DC6\u0E01-\u0E30\u0E32-\u0E33\u0E40-\u0E45\u0E81-\u0E82\u0E84\u0E87-\u0E88\u0E8A\u0E8D\u0E94-\u0E97\u0E99-\u0E9F\u0EA1-\u0EA3\u0EA5\u0EA7\u0EAA-\u0EAB\u0EAD-\u0EB0\u0EB2-\u0EB3\u0EBD\u0EC0-\u0EC4\u0EDC-\u0EDF\u0F00\u0F40-\u0F47\u0F49-\u0F6C\u0F88-\u0F8C\u1000-\u102A\u103F\u1050-\u1055\u105A-\u105D\u1061\u1065-\u1066\u106E-\u1070\u1075-\u1081\u108E\u10D0-\u10FA\u10FD-\u1248\u124A-\u124D\u1250-\u1256\u1258\u125A-\u125D\u1260-\u1288\u128A-\u128D\u1290-\u12B0\u12B2-\u12B5\u12B8-\u12BE\u12C0\u12C2-\u12C5\u12C8-\u12D6\u12D8-\u1310\u1312-\u1315\u1318-\u135A\u1380-\u138F\u1401-\u166C\u166F-\u167F\u1681-\u169A\u16A0-\u16EA\u16F1-\u16F8\u1700-\u170C\u170E-\u1711\u1720-\u1731\u1740-\u1751\u1760-\u176C\u176E-\u1770\u1780-\u17B3\u17DC\u1820-\u1842\u1844-\u1877\u1880-\u18A8\u18AA\u18B0-\u18F5\u1900-\u191E\u1950-\u196D\u1970-\u1974\u1980-\u19AB\u19B0-\u19C9\u1A00-\u1A16\u1A20-\u1A54\u1B05-\u1B33\u1B45-\u1B4B\u1B83-\u1BA0\u1BAE-\u1BAF\u1BBA-\u1BE5\u1C00-\u1C23\u1C4D-\u1C4F\u1C5A-\u1C77\u1CE9-\u1CEC\u1CEE-\u1CF1\u1CF5-\u1CF6\u2135-\u2138\u2D30-\u2D67\u2D80-\u2D96\u2DA0-\u2DA6\u2DA8-\u2DAE\u2DB0-\u2DB6\u2DB8-\u2DBE\u2DC0-\u2DC6\u2DC8-\u2DCE\u2DD0-\u2DD6\u2DD8-\u2DDE\u3006\u303C\u3041-\u3096\u309F\u30A1-\u30FA\u30FF\u3105-\u312D\u3131-\u318E\u31A0-\u31BA\u31F0-\u31FF\u3400-\u4DB5\u4E00-\u9FD5\uA000-\uA014\uA016-\uA48C\uA4D0-\uA4F7\uA500-\uA60B\uA610-\uA61F\uA62A-\uA62B\uA66E\uA6A0-\uA6E5\uA78F\uA7F7\uA7FB-\uA801\uA803-\uA805\uA807-\uA80A\uA80C-\uA822\uA840-\uA873\uA882-\uA8B3\uA8F2-\uA8F7\uA8FB\uA8FD\uA90A-\uA925\uA930-\uA946\uA960-\uA97C\uA984-\uA9B2\uA9E0-\uA9E4\uA9E7-\uA9EF\uA9FA-\uA9FE\uAA00-\uAA28\uAA40-\uAA42\uAA44-\uAA4B\uAA60-\uAA6F\uAA71-\uAA76\uAA7A\uAA7E-\uAAAF\uAAB1\uAAB5-\uAAB6\uAAB9-\uAABD\uAAC0\uAAC2\uAADB-\uAADC\uAAE0-\uAAEA\uAAF2\uAB01-\uAB06\uAB09-\uAB0E\uAB11-\uAB16\uAB20-\uAB26\uAB28-\uAB2E\uABC0-\uABE2\uAC00-\uD7A3\uD7B0-\uD7C6\uD7CB-\uD7FB\uF900-\uFA6D\uFA70-\uFAD9\uFB1D\uFB1F-\uFB28\uFB2A-\uFB36\uFB38-\uFB3C\uFB3E\uFB40-\uFB41\uFB43-\uFB44\uFB46-\uFBB1\uFBD3-\uFD3D\uFD50-\uFD8F\uFD92-\uFDC7\uFDF0-\uFDFB\uFE70-\uFE74\uFE76-\uFEFC\uFF66-\uFF6F\uFF71-\uFF9D\uFFA0-\uFFBE\uFFC2-\uFFC7\uFFCA-\uFFCF\uFFD2-\uFFD7\uFFDA-\uFFDC]

// Letter, Titlecase
Lt = [\u01C5\u01C8\u01CB\u01F2\u1F88-\u1F8F\u1F98-\u1F9F\u1FA8-\u1FAF\u1FBC\u1FCC\u1FFC]

// Letter, Uppercase
Lu = [\u0041-\u005A\u00C0-\u00D6\u00D8-\u00DE\u0100\u0102\u0104\u0106\u0108\u010A\u010C\u010E\u0110\u0112\u0114\u0116\u0118\u011A\u011C\u011E\u0120\u0122\u0124\u0126\u0128\u012A\u012C\u012E\u0130\u0132\u0134\u0136\u0139\u013B\u013D\u013F\u0141\u0143\u0145\u0147\u014A\u014C\u014E\u0150\u0152\u0154\u0156\u0158\u015A\u015C\u015E\u0160\u0162\u0164\u0166\u0168\u016A\u016C\u016E\u0170\u0172\u0174\u0176\u0178-\u0179\u017B\u017D\u0181-\u0182\u0184\u0186-\u0187\u0189-\u018B\u018E-\u0191\u0193-\u0194\u0196-\u0198\u019C-\u019D\u019F-\u01A0\u01A2\u01A4\u01A6-\u01A7\u01A9\u01AC\u01AE-\u01AF\u01B1-\u01B3\u01B5\u01B7-\u01B8\u01BC\u01C4\u01C7\u01CA\u01CD\u01CF\u01D1\u01D3\u01D5\u01D7\u01D9\u01DB\u01DE\u01E0\u01E2\u01E4\u01E6\u01E8\u01EA\u01EC\u01EE\u01F1\u01F4\u01F6-\u01F8\u01FA\u01FC\u01FE\u0200\u0202\u0204\u0206\u0208\u020A\u020C\u020E\u0210\u0212\u0214\u0216\u0218\u021A\u021C\u021E\u0220\u0222\u0224\u0226\u0228\u022A\u022C\u022E\u0230\u0232\u023A-\u023B\u023D-\u023E\u0241\u0243-\u0246\u0248\u024A\u024C\u024E\u0370\u0372\u0376\u037F\u0386\u0388-\u038A\u038C\u038E-\u038F\u0391-\u03A1\u03A3-\u03AB\u03CF\u03D2-\u03D4\u03D8\u03DA\u03DC\u03DE\u03E0\u03E2\u03E4\u03E6\u03E8\u03EA\u03EC\u03EE\u03F4\u03F7\u03F9-\u03FA\u03FD-\u042F\u0460\u0462\u0464\u0466\u0468\u046A\u046C\u046E\u0470\u0472\u0474\u0476\u0478\u047A\u047C\u047E\u0480\u048A\u048C\u048E\u0490\u0492\u0494\u0496\u0498\u049A\u049C\u049E\u04A0\u04A2\u04A4\u04A6\u04A8\u04AA\u04AC\u04AE\u04B0\u04B2\u04B4\u04B6\u04B8\u04BA\u04BC\u04BE\u04C0-\u04C1\u04C3\u04C5\u04C7\u04C9\u04CB\u04CD\u04D0\u04D2\u04D4\u04D6\u04D8\u04DA\u04DC\u04DE\u04E0\u04E2\u04E4\u04E6\u04E8\u04EA\u04EC\u04EE\u04F0\u04F2\u04F4\u04F6\u04F8\u04FA\u04FC\u04FE\u0500\u0502\u0504\u0506\u0508\u050A\u050C\u050E\u0510\u0512\u0514\u0516\u0518\u051A\u051C\u051E\u0520\u0522\u0524\u0526\u0528\u052A\u052C\u052E\u0531-\u0556\u10A0-\u10C5\u10C7\u10CD\u13A0-\u13F5\u1E00\u1E02\u1E04\u1E06\u1E08\u1E0A\u1E0C\u1E0E\u1E10\u1E12\u1E14\u1E16\u1E18\u1E1A\u1E1C\u1E1E\u1E20\u1E22\u1E24\u1E26\u1E28\u1E2A\u1E2C\u1E2E\u1E30\u1E32\u1E34\u1E36\u1E38\u1E3A\u1E3C\u1E3E\u1E40\u1E42\u1E44\u1E46\u1E48\u1E4A\u1E4C\u1E4E\u1E50\u1E52\u1E54\u1E56\u1E58\u1E5A\u1E5C\u1E5E\u1E60\u1E62\u1E64\u1E66\u1E68\u1E6A\u1E6C\u1E6E\u1E70\u1E72\u1E74\u1E76\u1E78\u1E7A\u1E7C\u1E7E\u1E80\u1E82\u1E84\u1E86\u1E88\u1E8A\u1E8C\u1E8E\u1E90\u1E92\u1E94\u1E9E\u1EA0\u1EA2\u1EA4\u1EA6\u1EA8\u1EAA\u1EAC\u1EAE\u1EB0\u1EB2\u1EB4\u1EB6\u1EB8\u1EBA\u1EBC\u1EBE\u1EC0\u1EC2\u1EC4\u1EC6\u1EC8\u1ECA\u1ECC\u1ECE\u1ED0\u1ED2\u1ED4\u1ED6\u1ED8\u1EDA\u1EDC\u1EDE\u1EE0\u1EE2\u1EE4\u1EE6\u1EE8\u1EEA\u1EEC\u1EEE\u1EF0\u1EF2\u1EF4\u1EF6\u1EF8\u1EFA\u1EFC\u1EFE\u1F08-\u1F0F\u1F18-\u1F1D\u1F28-\u1F2F\u1F38-\u1F3F\u1F48-\u1F4D\u1F59\u1F5B\u1F5D\u1F5F\u1F68-\u1F6F\u1FB8-\u1FBB\u1FC8-\u1FCB\u1FD8-\u1FDB\u1FE8-\u1FEC\u1FF8-\u1FFB\u2102\u2107\u210B-\u210D\u2110-\u2112\u2115\u2119-\u211D\u2124\u2126\u2128\u212A-\u212D\u2130-\u2133\u213E-\u213F\u2145\u2183\u2C00-\u2C2E\u2C60\u2C62-\u2C64\u2C67\u2C69\u2C6B\u2C6D-\u2C70\u2C72\u2C75\u2C7E-\u2C80\u2C82\u2C84\u2C86\u2C88\u2C8A\u2C8C\u2C8E\u2C90\u2C92\u2C94\u2C96\u2C98\u2C9A\u2C9C\u2C9E\u2CA0\u2CA2\u2CA4\u2CA6\u2CA8\u2CAA\u2CAC\u2CAE\u2CB0\u2CB2\u2CB4\u2CB6\u2CB8\u2CBA\u2CBC\u2CBE\u2CC0\u2CC2\u2CC4\u2CC6\u2CC8\u2CCA\u2CCC\u2CCE\u2CD0\u2CD2\u2CD4\u2CD6\u2CD8\u2CDA\u2CDC\u2CDE\u2CE0\u2CE2\u2CEB\u2CED\u2CF2\uA640\uA642\uA644\uA646\uA648\uA64A\uA64C\uA64E\uA650\uA652\uA654\uA656\uA658\uA65A\uA65C\uA65E\uA660\uA662\uA664\uA666\uA668\uA66A\uA66C\uA680\uA682\uA684\uA686\uA688\uA68A\uA68C\uA68E\uA690\uA692\uA694\uA696\uA698\uA69A\uA722\uA724\uA726\uA728\uA72A\uA72C\uA72E\uA732\uA734\uA736\uA738\uA73A\uA73C\uA73E\uA740\uA742\uA744\uA746\uA748\uA74A\uA74C\uA74E\uA750\uA752\uA754\uA756\uA758\uA75A\uA75C\uA75E\uA760\uA762\uA764\uA766\uA768\uA76A\uA76C\uA76E\uA779\uA77B\uA77D-\uA77E\uA780\uA782\uA784\uA786\uA78B\uA78D\uA790\uA792\uA796\uA798\uA79A\uA79C\uA79E\uA7A0\uA7A2\uA7A4\uA7A6\uA7A8\uA7AA-\uA7AD\uA7B0-\uA7B4\uA7B6\uFF21-\uFF3A]

// Mark, Spacing Combining
Mc = [\u0903\u093B\u093E-\u0940\u0949-\u094C\u094E-\u094F\u0982-\u0983\u09BE-\u09C0\u09C7-\u09C8\u09CB-\u09CC\u09D7\u0A03\u0A3E-\u0A40\u0A83\u0ABE-\u0AC0\u0AC9\u0ACB-\u0ACC\u0B02-\u0B03\u0B3E\u0B40\u0B47-\u0B48\u0B4B-\u0B4C\u0B57\u0BBE-\u0BBF\u0BC1-\u0BC2\u0BC6-\u0BC8\u0BCA-\u0BCC\u0BD7\u0C01-\u0C03\u0C41-\u0C44\u0C82-\u0C83\u0CBE\u0CC0-\u0CC4\u0CC7-\u0CC8\u0CCA-\u0CCB\u0CD5-\u0CD6\u0D02-\u0D03\u0D3E-\u0D40\u0D46-\u0D48\u0D4A-\u0D4C\u0D57\u0D82-\u0D83\u0DCF-\u0DD1\u0DD8-\u0DDF\u0DF2-\u0DF3\u0F3E-\u0F3F\u0F7F\u102B-\u102C\u1031\u1038\u103B-\u103C\u1056-\u1057\u1062-\u1064\u1067-\u106D\u1083-\u1084\u1087-\u108C\u108F\u109A-\u109C\u17B6\u17BE-\u17C5\u17C7-\u17C8\u1923-\u1926\u1929-\u192B\u1930-\u1931\u1933-\u1938\u1A19-\u1A1A\u1A55\u1A57\u1A61\u1A63-\u1A64\u1A6D-\u1A72\u1B04\u1B35\u1B3B\u1B3D-\u1B41\u1B43-\u1B44\u1B82\u1BA1\u1BA6-\u1BA7\u1BAA\u1BE7\u1BEA-\u1BEC\u1BEE\u1BF2-\u1BF3\u1C24-\u1C2B\u1C34-\u1C35\u1CE1\u1CF2-\u1CF3\u302E-\u302F\uA823-\uA824\uA827\uA880-\uA881\uA8B4-\uA8C3\uA952-\uA953\uA983\uA9B4-\uA9B5\uA9BA-\uA9BB\uA9BD-\uA9C0\uAA2F-\uAA30\uAA33-\uAA34\uAA4D\uAA7B\uAA7D\uAAEB\uAAEE-\uAAEF\uAAF5\uABE3-\uABE4\uABE6-\uABE7\uABE9-\uABEA\uABEC]

// Mark, Nonspacing
Mn = [\u0300-\u036F\u0483-\u0487\u0591-\u05BD\u05BF\u05C1-\u05C2\u05C4-\u05C5\u05C7\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06DC\u06DF-\u06E4\u06E7-\u06E8\u06EA-\u06ED\u0711\u0730-\u074A\u07A6-\u07B0\u07EB-\u07F3\u0816-\u0819\u081B-\u0823\u0825-\u0827\u0829-\u082D\u0859-\u085B\u08E3-\u0902\u093A\u093C\u0941-\u0948\u094D\u0951-\u0957\u0962-\u0963\u0981\u09BC\u09C1-\u09C4\u09CD\u09E2-\u09E3\u0A01-\u0A02\u0A3C\u0A41-\u0A42\u0A47-\u0A48\u0A4B-\u0A4D\u0A51\u0A70-\u0A71\u0A75\u0A81-\u0A82\u0ABC\u0AC1-\u0AC5\u0AC7-\u0AC8\u0ACD\u0AE2-\u0AE3\u0B01\u0B3C\u0B3F\u0B41-\u0B44\u0B4D\u0B56\u0B62-\u0B63\u0B82\u0BC0\u0BCD\u0C00\u0C3E-\u0C40\u0C46-\u0C48\u0C4A-\u0C4D\u0C55-\u0C56\u0C62-\u0C63\u0C81\u0CBC\u0CBF\u0CC6\u0CCC-\u0CCD\u0CE2-\u0CE3\u0D01\u0D41-\u0D44\u0D4D\u0D62-\u0D63\u0DCA\u0DD2-\u0DD4\u0DD6\u0E31\u0E34-\u0E3A\u0E47-\u0E4E\u0EB1\u0EB4-\u0EB9\u0EBB-\u0EBC\u0EC8-\u0ECD\u0F18-\u0F19\u0F35\u0F37\u0F39\u0F71-\u0F7E\u0F80-\u0F84\u0F86-\u0F87\u0F8D-\u0F97\u0F99-\u0FBC\u0FC6\u102D-\u1030\u1032-\u1037\u1039-\u103A\u103D-\u103E\u1058-\u1059\u105E-\u1060\u1071-\u1074\u1082\u1085-\u1086\u108D\u109D\u135D-\u135F\u1712-\u1714\u1732-\u1734\u1752-\u1753\u1772-\u1773\u17B4-\u17B5\u17B7-\u17BD\u17C6\u17C9-\u17D3\u17DD\u180B-\u180D\u18A9\u1920-\u1922\u1927-\u1928\u1932\u1939-\u193B\u1A17-\u1A18\u1A1B\u1A56\u1A58-\u1A5E\u1A60\u1A62\u1A65-\u1A6C\u1A73-\u1A7C\u1A7F\u1AB0-\u1ABD\u1B00-\u1B03\u1B34\u1B36-\u1B3A\u1B3C\u1B42\u1B6B-\u1B73\u1B80-\u1B81\u1BA2-\u1BA5\u1BA8-\u1BA9\u1BAB-\u1BAD\u1BE6\u1BE8-\u1BE9\u1BED\u1BEF-\u1BF1\u1C2C-\u1C33\u1C36-\u1C37\u1CD0-\u1CD2\u1CD4-\u1CE0\u1CE2-\u1CE8\u1CED\u1CF4\u1CF8-\u1CF9\u1DC0-\u1DF5\u1DFC-\u1DFF\u20D0-\u20DC\u20E1\u20E5-\u20F0\u2CEF-\u2CF1\u2D7F\u2DE0-\u2DFF\u302A-\u302D\u3099-\u309A\uA66F\uA674-\uA67D\uA69E-\uA69F\uA6F0-\uA6F1\uA802\uA806\uA80B\uA825-\uA826\uA8C4\uA8E0-\uA8F1\uA926-\uA92D\uA947-\uA951\uA980-\uA982\uA9B3\uA9B6-\uA9B9\uA9BC\uA9E5\uAA29-\uAA2E\uAA31-\uAA32\uAA35-\uAA36\uAA43\uAA4C\uAA7C\uAAB0\uAAB2-\uAAB4\uAAB7-\uAAB8\uAABE-\uAABF\uAAC1\uAAEC-\uAAED\uAAF6\uABE5\uABE8\uABED\uFB1E\uFE00-\uFE0F\uFE20-\uFE2F]

// Number, Decimal Digit
Nd = [\u0030-\u0039\u0660-\u0669\u06F0-\u06F9\u07C0-\u07C9\u0966-\u096F\u09E6-\u09EF\u0A66-\u0A6F\u0AE6-\u0AEF\u0B66-\u0B6F\u0BE6-\u0BEF\u0C66-\u0C6F\u0CE6-\u0CEF\u0D66-\u0D6F\u0DE6-\u0DEF\u0E50-\u0E59\u0ED0-\u0ED9\u0F20-\u0F29\u1040-\u1049\u1090-\u1099\u17E0-\u17E9\u1810-\u1819\u1946-\u194F\u19D0-\u19D9\u1A80-\u1A89\u1A90-\u1A99\u1B50-\u1B59\u1BB0-\u1BB9\u1C40-\u1C49\u1C50-\u1C59\uA620-\uA629\uA8D0-\uA8D9\uA900-\uA909\uA9D0-\uA9D9\uA9F0-\uA9F9\uAA50-\uAA59\uABF0-\uABF9\uFF10-\uFF19]

// Number, Letter
Nl = [\u16EE-\u16F0\u2160-\u2182\u2185-\u2188\u3007\u3021-\u3029\u3038-\u303A\uA6E6-\uA6EF]

// Punctuation, Connector
Pc = [\u005F\u203F-\u2040\u2054\uFE33-\uFE34\uFE4D-\uFE4F\uFF3F]

// Separator, Space
Zs = [\u0020\u00A0\u1680\u2000-\u200A\u202F\u205F\u3000]

/* Tokens */

EmitToken         = "emit"       !IdentifierPart
RevertToken       = "revert"     !IdentifierPart
AbstractToken     = "abstract"   !IdentifierPart 
ExperimentalToken = "experimental"!IdentifierPart
OverrideToken     = "override"   !IdentifierPart
AbiCoderToken     = "abicoder"   !IdentifierPart
ExternalToken     = "external"   !IdentifierPart
PureToken         = "pure"       !IdentifierPart
ViewToken         = "view"       !IdentifierPart
PayableToken      = "payable"    !IdentifierPart
AnonymousToken    = "anonymous"  !IdentifierPart
AsToken           = "as"         !IdentifierPart
BreakToken        = "break"      !IdentifierPart
CalldataToken     = "calldata"   !IdentifierPart
ConstantToken     = "constant"   !IdentifierPart
ImmutableToken    = "immutable"  !IdentifierPart
ContinueToken     = "continue"   !IdentifierPart
ContractToken     = "contract"   !IdentifierPart
ConstructorToken  = "constructor"!IdentifierPart
ReceiveToken      = "receive"    !IdentifierPart
FallbackToken     = "fallback"   !IdentifierPart
DaysToken         = "days"       !IdentifierPart
DeleteToken       = "delete"     !IdentifierPart
DoToken           = "do"         !IdentifierPart
ElseToken         = "else"       !IdentifierPart
EnumToken         = "enum"       !IdentifierPart
EtherToken        = "ether"      !IdentifierPart
GweiToken         = "gwei"       !IdentifierPart
EventToken        = "event"      !IdentifierPart
ErrorToken        = "error"      !IdentifierPart
FalseToken        = "false"      !IdentifierPart
FinneyToken       = "finney"     !IdentifierPart
ForToken          = "for"        !IdentifierPart
FromToken         = "from"       !IdentifierPart
FunctionToken     = "function"   !IdentifierPart
GetToken          = "get"        !IdentifierPart
HexToken          = "hex"        !IdentifierPart
HoursToken        = "hours"      !IdentifierPart
IfToken           = "if"         !IdentifierPart
TryToken          = "try"        !IdentifierPart
CatchToken        = "catch"      !IdentifierPart
IsToken           = "is"         !IdentifierPart
IndexedToken      = "indexed"    !IdentifierPart
ImportToken       = "import"     !IdentifierPart
InterfaceToken    = "interface"  !IdentifierPart
InternalToken     = "internal"   !IdentifierPart
LibraryToken      = "library"    !IdentifierPart
MappingToken      = "mapping"    !IdentifierPart
MemoryToken       = "memory"     !IdentifierPart
MinutesToken      = "minutes"    !IdentifierPart
ModifierToken     = "modifier"   !IdentifierPart
NewToken          = "new"        !IdentifierPart
NullToken         = "null"       !IdentifierPart
PrivateToken      = "private"    !IdentifierPart
PragmaToken       = "pragma"     !IdentifierPart
PublicToken       = "public"     !IdentifierPart
ReturnToken       = "return"     !IdentifierPart
ReturnsToken      = "returns"    !IdentifierPart
SecondsToken      = "seconds"    !IdentifierPart
SetToken          = "set"        !IdentifierPart
SolidityToken     = "solidity"   !IdentifierPart
StorageToken      = "storage"    !IdentifierPart
StructToken       = "struct"     !IdentifierPart
SuperToken        = "super"      !IdentifierPart
SzaboToken        = "szabo"      !IdentifierPart
ThisToken         = "this"       !IdentifierPart
ThrowToken        = "throw"      !IdentifierPart
TrueToken         = "true"       !IdentifierPart
UsingToken        = "using"      !IdentifierPart
VarToken          = "var"        !IdentifierPart
WeeksToken        = "weeks"      !IdentifierPart
WeiToken          = "wei"        !IdentifierPart
WhileToken        = "while"      !IdentifierPart
YearsToken        = "years"      !IdentifierPart

/* Skipped */

__
  = (WhiteSpace / LineTerminatorSequence / Comment)*

_
  = (WhiteSpace / MultiLineCommentNoLineTerminator)*

EOS = __ ";"

EOF
  = !.

Comma
  = __ "," __

/* ----- A.2 Number Conversions ----- */

/* Irrelevant. */

/* ----- A.3 Expressions ----- */

PrimaryExpression
  = ThisToken { return { type: "ThisExpression", start: location().start.offset, end: location().end.offset }; }
  / Identifier
  / Literal
  / ArrayLiteral
  / "(" __ expression:Expression __ ")" {
      /*
        Need to modify the location here so the position takes into account the "(" & ")".
        Else "(a, b)" (for eg) results in incorrect position.
      */
      expression.start = location().start.offset;
      expression.end = location().end.offset;

      return expression;
    }

ArrayLiteral
  = "[" __ elision:(Elision __)? "]" {
      return {
        type:     "ArrayExpression",
        elements: optionalList(extractOptional(elision, 0)),
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / "[" __ elements:ElementList __ "]" {
      return {
        type:     "ArrayExpression",
        elements: elements,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / "[" __ elements:ElementList __ "," __ elision:(Elision __)? "]" {
      return {
        type:     "ArrayExpression",
        elements: elements.concat(optionalList(extractOptional(elision, 0))),
        start: location().start.offset,
        end: location().end.offset
      };
    }

ElementList
  = head:(
      elision:(Elision __)? element:AssignmentExpression {
        return optionalList(extractOptional(elision, 0)).concat(element);
      }
    )
    tail:(
      __ "," __ elision:(Elision __)? element:AssignmentExpression {
        return optionalList(extractOptional(elision, 0)).concat(element);
      }
    )*
    { return Array.prototype.concat.apply(head, tail); }

Elision
  = "," commas:(__ ",")* { return filledArray(commas.length + 1, null); }

MemberExpression
  = head:(
        PrimaryExpression
      / NewToken __ callee:Type __ args:Arguments {
          return {
            type: "NewExpression",
            callee: callee,
            arguments: args,
            start: location().start.offset,
            end: location().end.offset
          };
        }
    )
    tail:(
        __ "[" __ property:Expression __ "]" {
          return {
            property: property,
            computed: true,
            start: location().start.offset,
            end: location().end.offset
          };
        }
      / __ "." __ property:IdentifierName {
          return { property: property, computed: false, start: location().start.offset, end: location().end.offset };
        }
    )*
    {
      return buildTree(head, tail, function(result, element) {
        return {
          type:     "MemberExpression",
          object:   result,
          property: element.property,
          computed: element.computed,
          start: location().start.offset,
          end: location().end.offset
        };
      });
    }

NewExpression
  = MemberExpression
  / NewToken __ callee:NewExpression {
      return { type: "NewExpression", callee: callee, arguments: [], start: location().start.offset, end: location().end.offset };
    }

CallExpression
  = head:(
      callee:MemberExpression __ args:Arguments {
        return { type: "CallExpression", callee: callee, arguments: args, start: location().start.offset, end: location().end.offset };
      }
    )
    tail:(
        __ args:Arguments {
          return { type: "CallExpression", arguments: args, start: location().start.offset, end: location().end.offset };
        }
      / __ "[" __ property:Expression __ "]" {
          return {
            type:     "MemberExpression",
            property: property,
            computed: true,
            start: location().start.offset,
            end: location().end.offset
          };
        }
      / __ "." __ property:IdentifierName {
          return {
            type:     "MemberExpression",
            property: property,
            computed: false,
            start: location().start.offset,
            end: location().end.offset
          };
        }
    )*
    {
      return buildTree(head, tail, function(result, element) {
        element[TYPES_TO_PROPERTY_NAMES[element.type]] = result;

        // Fix the start position of all nodes (ORIGIN: https://github.com/duaraghav8/Solium/issues/104)
        // The MemberExpression node's start property doesnt cover the entire previous code
        // eg - "ab.cd()[10]" the node.start points to '[' instead of 'a'
        // Same issue with CallExpression

        element.start = location().start.offset;
        return element;
      });
    }

Arguments
  = "(" __ args:(ArgumentList __)? ")" {
      return optionalList(extractOptional(args, 0));
    }
  / "(" __ "{" __ args:(NameValueList (__ ",")? )? __ "}" __ ")" {
      return optionalList(extractOptional(args, 0));
    }
  /  "{" __ args:(NameValueList (__ ",")? )? __ "}" {
    return optionalList(extractOptional(args, 0));
  }

ArgumentList
  = head:AssignmentExpression tail:(__ "," __ AssignmentExpression)* {
      return buildList(head, tail, 3);
    }

NameValueList
  = head:NameValueAssignment tail:(__ "," __ NameValueAssignment)* {
      return buildList(head, tail, 3);
    }

NameValueAssignment
  = name:Identifier __ ":" __ value:AssignmentExpression __ {
      return {
        type: "NameValueAssignment",
        name: name,
        value: value,
        start: location().start.offset,
        end: location().end.offset
      };
    }

LeftHandSideExpression
  = DeclarativeExpression
  / CallExpression
  / NewExpression

Type
  = literal:(Mapping / AddressPayable / Identifier) members:("." Identifier)* parts:(__"[" __ (Expression)? __ "]")*
  {
    return {
      type: "Type",
      literal: literal.type == "Identifier" ? literal.name : literal,
      members: optionalList(members).map(function(m) {return m[1].name;}),
      array_parts: optionalList(parts).map(function(p) {return p[3] != null ? p[3].value : null}),
      start: location().start.offset,
      end: location().end.offset
    }
  }
  / FunctionToken __ funcName:FunctionName __ modifiers:FunctionTypeModifierList? __ returns:ReturnsDeclarations __ parts:(__"[" __ (Expression)? __ "]")*
    {
      return {
        type: "Type",
        literal: "function",
        params: funcName.params,
        return_params: returns,
        array_parts: optionalList(parts).map(function(p) {return p[3] != null ? p[3].value : null}),
        modifiers: modifiers,
        start: location().start.offset,
        end: location().end.offset
      };
    }

FunctionTypeModifier
  = modifier:(InternalToken / ExternalToken / StateMutabilitySpecifier) {
      if (Array.isArray(modifier)) {
        return {
          type: "VisibilitySpecifier",
          value: modifier[0],
          start: location().start.offset,
          end: location().end.offset
        };
      }

      return modifier;
    }

StateMutabilitySpecifier
  = token:(ConstantToken / PureToken / ViewToken / PayableToken) {
      return {
        type: "StateMutabilitySpecifier",
        value: token[0],
        start: location().start.offset,
        end: location().end.offset
      };
    }

VisibilitySpecifier
  = PublicToken
  / PrivateToken
  / InternalToken

StorageLocationSpecifier
  = StorageToken
  / MemoryToken
  / CalldataToken

StateVariableSpecifiers
 = constant:(ConstantToken/ImmutableToken) __ visibility:(VisibilitySpecifier) __? override:(OverrideToken)? __ {
    return {
      visibility: visibility? visibility[0]: null,
      isconstant: constant ? (constant[0] === "constant" ? true: false) : false,
      isimmutable: constant? (constant[0] === "immutable" ? true: false) : false,
      isoverride: override?  true: false
    }
   } 
   /
  constant:(ConstantToken/ImmutableToken) __? override:(OverrideToken)? __? visibility:(VisibilitySpecifier)? __ {
    return {
      visibility: visibility? visibility[0]: null,
      isconstant: constant ? (constant[0] === "constant" ? true: false) : false,
      isimmutable: constant? (constant[0] === "immutable" ? true: false) : false,
      isoverride: override?  true: false
    }
   } 
   /
   override:(OverrideToken) __ constant:(ConstantToken/ImmutableToken) __? visibility:(VisibilitySpecifier)? __ {
    return {
      visibility: visibility? visibility[0]: null,
      isconstant: constant ? (constant[0] === "constant" ? true: false) : false,
      isimmutable: constant? (constant[0] === "immutable" ? true: false) : false,
      isoverride: override?  true: false
    }
   } /
   override:(OverrideToken) __? visibility:(VisibilitySpecifier)? __? constant:(ConstantToken/ImmutableToken)? __ {
    return {
      visibility: visibility? visibility[0]: null,
      isconstant: constant ? (constant[0] === "constant" ? true: false) : false,
      isimmutable: constant? (constant[0] === "immutable" ? true: false) : false,
      isoverride: override?  true: false
    }
   } /
   visibility:(VisibilitySpecifier) __ override:(OverrideToken) __? constant:(ConstantToken/ImmutableToken)? __ {
    return {
       visibility: visibility? visibility[0]: null,
      isconstant: constant ? (constant[0] === "constant" ? true: false) : false,
      isimmutable: constant? (constant[0] === "immutable" ? true: false) : false,
      isoverride: override?  true: false
    }
   }/
   visibility:(VisibilitySpecifier) __? constant:(ConstantToken/ImmutableToken)? __? override:(OverrideToken)? __ {
    return {
      visibility: visibility? visibility[0]: null,
      isconstant: constant ? (constant[0] === "constant" ? true: false) : false,
      isimmutable: constant? (constant[0] === "immutable" ? true: false) : false,
      isoverride: override?  true: false
    }
  } 


StateVariableValue 
  = "=" __ expression:Expression {
    return expression;
  }

StateVariableDeclaration
  = type:Type __ specifiers:StateVariableSpecifiers? __ id:Identifier __ value:StateVariableValue? __ EOS  
  {
    return {
      type: "StateVariableDeclaration",
      name: id.name,
      literal: type,
      visibility: specifiers? specifiers.visibility : null,
      is_constant: specifiers? specifiers.isconstant : false,
      is_immutable: specifiers? specifiers.isimmutable : false,
      is_override: specifiers? specifiers.isoverride: false,
      value: value,
      start: location().start.offset,
      end: location().end.offset
    }
  }

DeclarativeExpression
  = type:Type __ storage:StorageLocationSpecifier? __ id:Identifier 
  {
    return {
      type: "DeclarativeExpression",
      name: id.name,
      literal: type, 
      storage_location: storage ? storage[0]: null,
      start: location().start.offset,
      end: location().end.offset
    }
  }

Mapping
  = MappingToken __ "(" __ from:Type __ "=>" __ to:Type __ ")"
  {
    return {
     type: "MappingExpression",
     from: from,
     to: to,
     start: location().start.offset,
     end: location().end.offset
   }
  }

PostfixExpression
  = argument:LeftHandSideExpression _ operator:PostfixOperator {
      return {
        type:     "UpdateExpression",
        operator: operator,
        argument: argument,
        prefix:   false,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / LeftHandSideExpression

PostfixOperator
  = "++"
  / "--"

UnaryExpression
  = PostfixExpression
  / operator:UnaryOperator __ argument:UnaryExpression {
      var type = (operator === "++" || operator === "--")
        ? "UpdateExpression"
        : "UnaryExpression";

      return {
        type:     type,
        operator: operator,
        argument: argument,
        prefix:   true,
        start: location().start.offset,
        end: location().end.offset
      };
    }

UnaryOperator
  = $DeleteToken
  / "++"
  / "--"
  / $("+" !"=")
  / $("-" !"=")
  / "~"
  / "!"

MultiplicativeExpression
  = head:UnaryExpression
    tail:(__ MultiplicativeOperator __ UnaryExpression)*
    { return buildBinaryExpression(head, tail); }

MultiplicativeOperator
  = $("*""*"? !"=")
  / $("/" !"=")
  / $("%" !"=")

AdditiveExpression
  = head:MultiplicativeExpression
    tail:(__ AdditiveOperator __ MultiplicativeExpression)*
    { return buildBinaryExpression(head, tail); }

AdditiveOperator
  = $("+" ![+=])
  / $("-" ![-=])

ShiftExpression
  = head:AdditiveExpression
    tail:(__ ShiftOperator __ AdditiveExpression)*
    { return buildBinaryExpression(head, tail); }

ShiftOperator
  = $("<<"  !"=")
  / $(">>>" !"=")
  / $(">>"  !"=")

RelationalExpression
  = head:ShiftExpression
    tail:(__ RelationalOperator __ ShiftExpression)*
    { return buildBinaryExpression(head, tail); }

RelationalOperator
  = "<="
  / ">="
  / $("<" !"<")
  / $(">" !">")

EqualityExpression
  = head:RelationalExpression
    tail:(__ EqualityOperator __ RelationalExpression)*
    { return buildBinaryExpression(head, tail); }

EqualityOperator
  = "=="
  / "!="

EqualityPragmaOperator
 = "="

Tilde
  = "~"

BitwiseANDExpression
  = head:EqualityExpression
    tail:(__ BitwiseANDOperator __ EqualityExpression)*
    { return buildBinaryExpression(head, tail); }

BitwiseANDOperator
  = $("&" ![&=])

BitwiseXORExpression
  = head:BitwiseANDExpression
    tail:(__ BitwiseXOROperator __ BitwiseANDExpression)*
    { return buildBinaryExpression(head, tail); }

BitwiseXOROperator
  = $("^" !"=")

BitwiseORExpression
  = head:BitwiseXORExpression
    tail:(__ BitwiseOROperator __ BitwiseXORExpression)*
    { return buildBinaryExpression(head, tail); }

BitwiseOROperator
  = $("|" ![|=])

LogicalANDExpression
  = head:BitwiseORExpression
    tail:(__ LogicalANDOperator __ BitwiseORExpression)*
    { return buildBinaryExpression(head, tail); }

LogicalANDOperator
  = "&&"

LogicalORExpression
  = head:LogicalANDExpression
    tail:(__ LogicalOROperator __ LogicalANDExpression)*
    { return buildBinaryExpression(head, tail); }

LogicalOROperator
  = "||"

ConditionalExpression
  = test:LogicalORExpression __
    "?" __ consequent:AssignmentExpression __
    ":" __ alternate:AssignmentExpression
    {
      return {
        type:       "ConditionalExpression",
        test:       test,
        consequent: consequent,
        alternate:  alternate,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / LogicalORExpression

AssignmentExpression
  = left:LeftHandSideExpression __
    "=" !"=" __
    right:AssignmentExpression
    {
      return {
        type:     "AssignmentExpression",
        operator: "=",
        left:     left,
        right:    right,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / left:LeftHandSideExpression __
    operator:AssignmentOperator __
    right:AssignmentExpression
    {
      return {
        type:     "AssignmentExpression",
        operator: operator,
        left:     left,
        right:    right,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / ConditionalExpression

AssignmentOperator
  = "*="
  / "/="
  / "%="
  / "+="
  / "-="
  / "<<="
  / ">>="
  / "&="
  / "^="
  / "|="

Expression
  = head:AssignmentExpression? tail:(__ "," __ AssignmentExpression?)* {
      if (tail.length < 1) {
        return head;
      }

      // Below is a hack to successfully parse "(, a, , b, c,,,)" so expressions array only contains a, b & c
      // Hack is all we require since we're moving to a new parse very soon anyway :)

      var expressions = buildList(head, tail, 3), finalExpr = [];

      for (var i = 0; i < expressions.length; i++) {
        if (expressions[i] !== null) { finalExpr.push(expressions[i]); }
      }

      return {
        type: "SequenceExpression",
        expressions: finalExpr,
        start: location().start.offset,
        end: location().end.offset
      };
    }

/* ----- A.4 Statements ----- */

Statements
  = head:Statement tail:(__ Statement)* {
      return buildList(head, tail, 1);
    }

Statement
  =  
  Block
  / VariableStatement
  / EmptyStatement
  / ExpressionStatement
  / PlaceholderStatement
  / IfStatement
  / TryStatement
  / IterationStatement
  / InlineAssemblyStatement
  / ContinueStatement
  / BreakStatement
  / ReturnStatement
  / ThrowStatement
  / UsingStatement
  / EmitStatement
  / RevertStatement
  / IncompleteBlock
 
  
IncompleteBlock
  = !( 
  TryStatement
  / Block 
  / VariableStatement
  / EmptyStatement
  / ExpressionStatement
  / PlaceholderStatement
  / IfStatement
  / CatchStatement
  / IterationStatement
  / InlineAssemblyStatement
  / ContinueStatement
  / BreakStatement
  / ReturnStatement
  / ThrowStatement
  / UsingStatement
  / EmitStatement
  / RevertStatement
 )  

  __ body:EmitToken __ PrimaryExpression tail:(((".") / (  __ "=" __ ) / ( __ "=" __ NewToken __)) Identifier?)* __ ?
    {
      return {
        type: "IncompleteStatement",
        body: text(),
        start: location().start.offset,
        end: location().end.offset
      };
    } /
    __ body:ReturnToken __ PrimaryExpression tail:(((".") / (  __ "=" __ ) / ( __ "=" __ NewToken __)) Identifier?)* __ ?
    {
      return {
        type: "IncompleteStatement",
        body:  text(),
        start: location().start.offset,
        end: location().end.offset
      };
    }  /
     __ body: PrimaryExpression tail:(((".") / (  __ "=" __ ) / ( __ "=" __ NewToken __)) Identifier?)* __ ?
    {
      return {
        type: "IncompleteStatement",
        body: text(),
        start: location().start.offset,
        end: location().end.offset
      };
    } 
  

Block
  = "{" __ body:(StatementList __)? "}" {
      return {
        type: "BlockStatement",
        body: optionalList(extractOptional(body, 0)),
        start: location().start.offset,
        end: location().end.offset
      };
    } 

StatementList
  = head:Statement tail:(__ Statement)* { return buildList(head, tail, 1); }

VariableStatement
  = VarToken __ declarations:VariableDeclarationList EOS {
      return {
        type:         "VariableDeclaration",
        declarations: declarations,
        start: location().start.offset,
        end: location().end.offset
      };
    }
    / VarToken __ tuple:VariableDeclarationTuple EOS {
      return {
        type:         "VariableDeclarationTuple",
        declarations: tuple.declarations,
        init: tuple.init,
        start: location().start.offset,
        end: location().end.offset
      };
    }

VariableDeclarationTuple
  = "("Comma* __ head:VariableDeclarationNoInit tail:(Comma+ VariableDeclarationNoInit)* __ Comma* ")" init:(__ Initialiser) {
      return {
        declarations: buildList(head, tail, 1),
        init: extractOptional(init, 1)
      }
    }

VariableDeclarationNoInit
  = id:Identifier {
      return {
        type: "VariableDeclarator",
        id: id.constructor === Array ? id [1] : id,
        init: null,
        start: location().start.offset,
        end: location().end.offset
      };
    }


VariableDeclarationList
  = head:VariableDeclaration tail:(__ "," __ VariableDeclaration)* {
      return buildList(head, tail, 3);
    }

VariableDeclaration
  = id:(Identifier / "(" Identifier ")") init:(__ Initialiser)? {
      return {
        type: "VariableDeclarator",
        id: id.constructor === Array ? id [1] : id,
        init: extractOptional(init, 1),
        start: location().start.offset,
        end: location().end.offset
      };
    }

Initialiser
  = "=" !"=" __ expression:AssignmentExpression { return expression; }

EmptyStatement
  = ";" { return { type: "EmptyStatement", start: location().start.offset, end: location().end.offset }; }



ExpressionStatement
  = !("{" / ContractToken / InterfaceToken / LibraryToken / StructToken / EnumToken) expression:Expression EOS {
      return {
        type:       "ExpressionStatement",
        expression: expression,
        start: location().start.offset,
        end: location().end.offset
      };
    } 

TryStatement 
  = TryToken __ tryExpression: Expression tail:(((".") / (  __ "=" __ ) / ( __ "=" __ NewToken __)) Identifier?)* __ 
    tryStatement:Statement __
    catchStatements: (CatchStatements)*
    {
      return {
         type:  "TryStatement",
         tryExpression: tryExpression,
         tryStatement: tryStatement,
         catchStatements: catchStatements
      };
    } 
    / TryToken __ tryExpression:Expression tail:(((".") / (  __ "=" __ ) / ( __ "=" __ NewToken __)) Identifier?)* __ tryExpressionReturns:ReturnsDeclarations __ tryStatement: Statement __
      catchStatements:(CatchStatements)*
    {
        return {
         type:  "TryStatement",
         tryExpressionReturns: tryExpressionReturns,
         tryExpression: tryExpression,
         tryStatement: tryStatement,
         catchStatements: catchStatements
      };
    } 
    / TryToken __ tryExpression:Expression tail:(((".") / (  __ "=" __ ) / ( __ "=" __ NewToken __)) Identifier?)* __ tryExpressionReturns:ReturnsDeclarations __ tryStatement: __
      catchStatements:(CatchStatements)*
    {
        return {
         type:  "TryStatement",
         tryExpressionReturns: tryExpressionReturns,
         tryExpression: tryExpression,
         tryStatement: tryStatement,
         catchStatements: catchStatements
      };
    } 
    

CatchStatements
  = head:CatchStatement tail:(__ CatchStatement)* {
      return buildList(head, tail, 1);
    }

CatchStatement
  = CatchToken __ "(" __ param:InformalParameterList __ ")" __ body:Block {
      return {
        type: "CatchClause",
        param: param,
        body: body
      };
    } /
    CatchToken __ body:Block {
      return {
        type: "CatchClause",
        body: body
      };
    } /
 CatchToken __ "Error" __ "(" __ param:InformalParameterList __ ")" __ body:Block {
      return {
        type: "CatchClause",
        param: param,
        body: body
      };
    }
    

IfStatement
  = IfToken __ "(" __ test:Expression __ ")" __
    consequent:Statement __
    ElseToken __
    alternate:Statement
    {
      return {
        type:       "IfStatement",
        test:       test,
        consequent: consequent,
        alternate:  alternate,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / IfToken __ "(" __ test:Expression __ ")" __
    consequent:Statement {
      return {
        type:       "IfStatement",
        test:       test,
        consequent: consequent,
        alternate:  null,
        start: location().start.offset,
        end: location().end.offset
      };
    }

PragmaStatement
  = PragmaToken __ SolidityToken __ start_version:VersionLiteral __ end_version:(VersionLiteral?) EOS {
    return {
      type: "PragmaStatement",
      start_version: start_version,
      end_version: end_version,
      start: location().start.offset,
      end: location().end.offset
    }
  }
  / PragmaToken __ ExperimentalToken __ featureName:(Identifier / StringLiteral) EOS {
    return {
      type: "ExperimentalPragmaStatement",
      feature: featureName,
      start: location().start.offset,
      end: location().end.offset
    }
  }
   / PragmaToken __ AbiCoderToken __ version:(Identifier / StringLiteral) EOS {
    return {
      type: "AbiCoderPragmaStatement",
      version: version,
      start: location().start.offset,
      end: location().end.offset
    }
  }

ImportStatement
  = ImportToken __ from:StringLiteral __ alias:(AsToken __ Identifier)? __ EOS
  {
    return {
      type: "ImportStatement",
      from: from.value,
      symbols: [],
      alias: alias != null ? alias[2].name : null,
      start: location().start.offset,
      end: location().end.offset
    }
  }
  / ImportToken __ symbol:GlobalSymbol __ FromToken __ from:StringLiteral __ EOS
  {
    return {
      type: "ImportStatement",
      from: from.value,
      symbols: [symbol],
      start: location().start.offset,
      end: location().end.offset
    }
  }
  / ImportToken __ "{" __ symbols:SymbolList __ "}" __ FromToken __ from:StringLiteral __ EOS
  {
    return {
      type: "ImportStatement",
      from: from.value,
      symbols: symbols,
      start: location().start.offset,
      end: location().end.offset
    }
  }

UsingStatement
  = UsingToken __ library:Identifier __ ForToken __ type:Type __ EOS
  {
    return {
      type: "UsingStatement",
      library: library.name,
      for: type,
      start: location().start.offset,
      end: location().end.offset
    }
  }
  / UsingToken __ library:Identifier __ ForToken __ "*" __ EOS
  {
    return {
      type: "UsingStatement",
      library: library.name,
      for: "*",
      start: location().start.offset,
      end: location().end.offset
    }
  }

EmitStatement
  = EmitToken __ callexpr:CallExpression EOS
  {
    return {
      type: "EmitStatement",
      expression: callexpr,
      start: location().start.offset,
      end: location().end.offset
    };
  }

RevertStatement
  = RevertToken __ callexpr:CallExpression EOS
  {
    return {
      type: "RevertStatement",
      expression: callexpr,
      start: location().start.offset,
      end: location().end.offset
    };
  }

SymbolList
  = head:Symbol tail:( __ "," __ Symbol)* {
      return buildList(head, tail, 3);
    }

Symbol
  = name:Identifier __ alias:(AsToken __ Identifier)?
  {
    return {
      type: "Symbol",
      name: name.name,
      alias: alias != null ? alias[2].name : name.name,
      start: location().start.offset,
      end: location().end.offset
    };
  }

GlobalSymbol
  = name:"*" __ alias:(AsToken __ Identifier)
  {
    return {
      type: "Symbol",
      name: "*",
      alias: alias[2].name,
      start: location().start.offset,
      end: location().end.offset
    }
  }

IterationStatement
  = DoToken __
    body:Statement __
    WhileToken __ "(" __ test:Expression __ ")" EOS
    { return { type: "DoWhileStatement", body: body, test: test, start: location().start.offset, end: location().end.offset }; }
  / WhileToken __ "(" __ test:Expression __ ")" __
    body:Statement
    { return { type: "WhileStatement", test: test, body: body, start: location().start.offset, end: location().end.offset }; }
  / ForToken __
    "(" __
    init:(Expression __)? ";" __
    test:(Expression __)? ";" __
    update:(Expression __)?
    ")" __
    body:Statement
    {
      return {
        type:   "ForStatement",
        init:   extractOptional(init, 0),
        test:   extractOptional(test, 0),
        update: extractOptional(update, 0),
        body:   body,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / ForToken __
    "(" __
    VarToken __ declarations:VariableDeclarationList __ ";" __
    test:(Expression __)? ";" __
    update:(Expression __)?
    ")" __
    body:Statement
    {
      return {
        type:   "ForStatement",
        init:   {
          type:         "VariableDeclaration",
          declarations: declarations,
          start: location().start.offset,
          end: location().end.offset
        },
        test:   extractOptional(test, 0),
        update: extractOptional(update, 0),
        body:   body,
        start: location().start.offset,
        end: location().end.offset
      };
    }

InlineAssemblyStatement
  = 'assembly' __ body:InlineAssemblyBlock {
      return {
        type: "InlineAssemblyStatement",
        body:  body,
        start: location().start.offset,
        end: location().end.offset
      };
  }

PlaceholderStatement
  = "_" (__ EOS)? {
    return {
      type: "PlaceholderStatement",
      start: location().start.offset,
      end: location().end.offset
    }
  }

ContinueStatement
  = ContinueToken EOS {
      return { type: "ContinueStatement", label: null, start: location().start.offset, end: location().end.offset };
    }
  / ContinueToken _ label:Identifier EOS {
      return { type: "ContinueStatement", label: label, start: location().start.offset, end: location().end.offset };
    }

BreakStatement
  = BreakToken EOS {
      return { type: "BreakStatement", label: null, start: location().start.offset, end: location().end.offset };
    }
  / BreakToken _ label:Identifier EOS {
      return { type: "BreakStatement", label: label, start: location().start.offset, end: location().end.offset };
    }

ReturnStatement
  = ReturnToken EOS {
      return { type: "ReturnStatement", argument: null, start: location().start.offset, end: location().end.offset };
    }
  / ReturnToken __ argument:Expression EOS {
      return { type: "ReturnStatement", argument: argument, start: location().start.offset, end: location().end.offset };
    }

ThrowStatement
  = ThrowToken EOS {
      return { type: "ThrowStatement", start: location().start.offset, end: location().end.offset };
    }

ContractStatement
  = abstract:AbstractToken? __ ContractToken __ id:Identifier __ is:IsStatement? __
    "{" __ body:SourceElements? __ "}"
  {
    return {
      type: "ContractStatement",
      name: id.name,
      is: is != null ? is.names : [],
      body: optionalList (body),
      is_abstract: abstract != null,
      start: location().start.offset,
      end: location().end.offset
    }
  }

InterfaceStatement
  = InterfaceToken __ id:Identifier __ is:IsStatement? __
    "{" __ body:SourceElements? __ "}"
  {
    return {
      type: "InterfaceStatement",
      name: id.name,
      is: is != null ? is.names : [],
      body: optionalList (body),
      start: location().start.offset,
      end: location().end.offset
    }
  }


LibraryStatement
  = LibraryToken __ id:Identifier __ is:IsStatement? __
    "{" __ body:SourceElements? __ "}"
  {
    return {
      type: "LibraryStatement",
      name: id.name,
      is: is != null ? is.names : [],
      body: optionalList (body),
      start: location().start.offset,
      end: location().end.offset
    }
  }

IsStatement
  = IsToken __ modifiers:CommaSeparatedModifierNameList
  {
    return {
      type: "IsStatement",
      names: modifiers,
      start: location().start.offset,
      end: location().end.offset
    }
  }

/* ----- A.5 Functions and Programs ----- */

ErrorDeclaration
  = ErrorToken __ fnname:FunctionName __ isanonymous:AnonymousToken? __ EOS
  {
    return {
      type: "ErrorDeclaration",
      name: fnname.name,
      params: fnname.params,
      is_anonymous: isanonymous != null,
      start: location().start.offset,
      end: location().end.offset
    }
  }


EventDeclaration
  = EventToken __ fnname:FunctionName __ isanonymous:AnonymousToken? __ EOS
  {
    return {
      type: "EventDeclaration",
      name: fnname.name,
      params: fnname.params,
      is_anonymous: isanonymous != null,
      start: location().start.offset,
      end: location().end.offset
    }
  }

ModifierDeclaration
  = ModifierToken __ fnname:ModifierName __ names:ModifierNameList? __ body:FunctionBody
    {
      return {
        type: "ModifierDeclaration",
        name: fnname.name,
        params: fnname.params,
        modifiers: names,
        body: body,
        start: location().start.offset,
        end: location().end.offset
      };
    }

FunctionDeclaration
  = FunctionToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclarations __ body:FunctionBody
    {
      return {
        type: "FunctionDeclaration",
        name: fnname.name,
        params: fnname.params,
        modifiers: args,
        returnParams: returns,
        body: body,
        is_abstract: false,
        start: location().start.offset,
        end: location().end.offset
      };
    }
  / FunctionToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclarations __ EOS
    {
      return {
        type: "FunctionDeclaration",
        name: fnname.name,
        params: fnname.params,
        modifiers: args,
        returnParams: returns,
        body: null,
        is_abstract: true,
        start: location().start.offset,
        end: location().end.offset
      };
    }

ConstructorDeclaration
  = ConstructorToken __ fnname:FunctionName __ args:ModifierArgumentList? __ body:FunctionBody
    {
      return {
        type: "ConstructorDeclaration",
        params: fnname.params,
        modifiers: args,
        body: body,
        start: location().start.offset,
        end: location().end.offset
      };
    }

FallbackDeclaration
  = FallbackToken __ fnname:FunctionName __ args:ModifierArgumentList? __ body:FunctionBody
    {
      return {
        type: "FallbackDeclaration",
        modifiers: args,
        body: body,
        start: location().start.offset,
        end: location().end.offset
      };
    }

ReceiveDeclaration
  = ReceiveToken __ fnname:FunctionName __ args:ModifierArgumentList? __ body:FunctionBody
    {
      return {
        type: "ReceiveDeclaration",
        modifiers: args,
        body: body,
        start: location().start.offset,
        end: location().end.offset
      };
    }


ReturnsDeclaration
  = ReturnsToken __ params:("(" __ InformalParameterList __ ")")
  {
    return params != null ? params [2] : null;
  }

ReturnsDeclarations
  = returnParams:ReturnsDeclaration?
  {
    if (returnParams == null) {
      return null;
    }

    return {
      type: "ReturnParams",
      params: returnParams,
      start: location().start.offset,
      end: location().end.offset
    };
  }
    

FunctionName
  = id:Identifier? __ params:("(" __ InformalParameterList? __ ")")
  {
    return {
      type: "FunctionName",
      name: id != null ? id.name : null,
      params: params != null ? params[2] : [],
      start: location().start.offset,
      end: location().end.offset
    };
  }

ModifierName
  = id:Identifier __ params:("(" __ InformalParameterList? __ ")")?
  {
    return {
      type: "ModifierName",
      name: id != null ? id.name : null,
      params: params != null ? params[2] : [],
      start: location().start.offset,
      end: location().end.offset
    };
  }

ModifierArgument
  = id:Identifier params:(__ "(" __ ArgumentList? __ ")")?
  {
    var p = [];

    if (params != null && params[3] != null) {
      p = params[3];
    }

    return {
      type: "ModifierArgument",
      name: id != null ? id.name : null,
      params: p,
      start: location().start.offset,
      end: location().end.offset
    };
  }

FunctionNameList
  = head:FunctionName tail:( __ FunctionName)* {
      return buildList(head, tail, 1);
    }

ModifierNameList
  = head:ModifierName tail:( __ ModifierName)* {
      return buildList(head, tail, 1);
    }

ModifierArgumentList
  = head:ModifierArgument tail:( __ ModifierArgument)* {
      return buildList(head, tail, 1);
    }

FunctionTypeModifierList
  = head:FunctionTypeModifier tail:( __ FunctionTypeModifier)* {
      return buildList(head, tail, 1);
    }

ModifierNameWithAlias
  = alias:(Identifier ".")* modifier:ModifierName {
      if (alias.length > 0) {
        var mergedAlias = alias.reduce(function(result, item) {
          return result + item[0].name + item[1];
        }, "");

        modifier.name = mergedAlias + modifier.name;
        modifier.start = alias[0][0].start;
      }

      return modifier;
    }

CommaSeparatedModifierNameList
  = head:ModifierNameWithAlias tail:( __ "," __ ModifierNameWithAlias)* {
      return buildList(head, tail, 3);
    }

InformalParameter
  = type:Type __ isindexed:IndexedToken? __ isconstant:ConstantToken? __ storage:StorageLocationSpecifier? __ id:Identifier?
  {
    return {
      type: "InformalParameter",
      literal: type,
      id: id ? id.name : null,
      is_indexed: isindexed != null,
      is_constant: isconstant != null,
      storage_location: storage ? storage[0]: null,
      start: location().start.offset,
      end: location().end.offset
    };
  }

InformalParameterList
  = head:(InformalParameter / Literal) tail:( __ "," __ (InformalParameter / Literal))* {
      return buildList(head, tail, 3);
    }


FunctionBody
  = "{" __ body:Statements? __ "}" {
      return {
        type: "BlockStatement",
        body: optionalList(body),
        start: location().start.offset,
        end: location().end.offset
      };
    }

EnumDeclaration
  = EnumToken __ id:Identifier __ "{" __ head:Identifier tail:( __ "," __ Identifier)* __ "}"
  {
    return {
      type: "EnumDeclaration",
      name: id.name,
      members: buildList(head, tail, 3).map(function(i) {return i.name;}),
      start: location().start.offset,
      end: location().end.offset
    }
  }

StructDeclaration
  = StructToken __ id:Identifier __ "{" __ body:DeclarativeExpressionList? __ "}"
  {
    return {
      type: "StructDeclaration",
      name: id.name,
      body: body != null ? body.declarations : null,
      start: location().start.offset,
      end: location().end.offset
    }
  }

DeclarativeExpressionList
  = head:DeclarativeExpression __ EOS tail:( __ DeclarativeExpression __ EOS )*
  {
    return {
      type: "DeclarativeExpressionList",
      declarations: buildList(head, tail, 1),
      start: location().start.offset,
      end: location().end.offset
    }
  }

Program
  = body:SourceUnits? {
      return {
        type: "Program",
        body: optionalList(body),
        start: location().start.offset,
        end: location().end.offset
      };
    }

SourceUnits
  = head:SourceUnit tail:(__ SourceUnit)* {
      return buildList(head, tail, 1);
    }

SourceUnit
  = PragmaStatement
  / ImportStatement
  / ContractStatement
  / InterfaceStatement
  / LibraryStatement
  / StructDeclaration
  / EnumDeclaration
  / ErrorDeclaration

SourceElements
  = head:SourceElement tail:(__ SourceElement)* {
      return buildList(head, tail, 1);
    }

SourceElement
  = StateVariableDeclaration
  / EnumDeclaration
  / EventDeclaration
  / StructDeclaration
  / ErrorDeclaration
  / ModifierDeclaration
  / FunctionDeclaration
  / ConstructorDeclaration
  / FallbackDeclaration
  / ReceiveDeclaration
  / UsingStatement

InlineAssemblyBlock
  = '{' __ items:(AssemblyItem __)* __ '}' {
    return {
      type: "InlineAssemblyBlock",
      items: optionalList(extractList(items, 0)),
      start: location().start.offset,
      end: location().end.offset
    }
  }

AssemblyItem
  = FunctionalAssemblyInstruction
  / InlineAssemblyBlock
  / AssemblyFunctionDefinition
  / AssemblyLocalBinding
  / AssemblyAssignment
  / AssemblyLabel
  / AssemblyIf
  / AssemblyFor
  / NumericLiteral
  / StringLiteral
  / HexStringLiteral
  / Identifier

AssemblyExpression
  = FunctionalAssemblyInstruction
  / ElementaryAssemblyOperation

ElementaryAssemblyOperation
  = NumericLiteral
  / StringLiteral
  / Identifier

AssemblyIdentifierList
  = head:Identifier tail:(__ ',' __ Identifier)* {
    return buildList(head, tail, 3);
  }

AssemblyFunctionDefinition
  = FunctionToken __ id:Identifier __ '(' __ params:AssemblyIdentifierList? __ ')' __ returns:('->' __ AssemblyIdentifierList __)? body:InlineAssemblyBlock {
    return {
      type: "AssemblyFunctionDefinition",
      name: id.name,
      params: params != null ? params : [],
      returnParams: returns != null ? returns[2] : [],
      body: body,
      start: location().start.offset,
      end: location().end.offset
    }
  }

AssemblyLocalBinding
  = 'let' __ names:AssemblyIdentifierList expression:(__ ':=' __ AssemblyExpression)? {
    if (expression != null) {
      expression = expression[3];
    }

    return {
      type: "AssemblyLocalBinding",
      names: names,
      expression: expression,
      start: location().start.offset,
      end: location().end.offset
    }
  }

AssemblyAssignment
  = names:AssemblyIdentifierList __ ':=' __ expression:AssemblyExpression {
    return {
      type: "AssemblyAssignment",
      names: names,
      expression: expression,
      start: location().start.offset,
      end: location().end.offset
    }
  }

ReturnOpCode
  = 'return' {
    return {
      type: "Identifier",
      name: "return",
      start: location().start.offset,
      end: location().end.offset
    }
  }

FunctionalAssemblyInstruction
  = name:(Identifier / ReturnOpCode) __ '(' __ head:AssemblyItem? __ tail:( ',' __ AssemblyItem )* __ ')' {
    return {
      type: "FunctionalAssemblyInstruction",
      name: name,
      arguments: buildList(head, tail, 2),
      start: location().start.offset,
      end: location().end.offset
    }
  }

AssemblyLabel
  = name:(Identifier) __ ':' {
    return {
      type: "AssemblyLabel",
      name: name,
      start: location().start.offset,
      end: location().end.offset
    }
  }

AssemblyIf
  = IfToken __ test:AssemblyExpression __ body:InlineAssemblyBlock {
    return {
        type: "AssemblyIf",
        test: test,
        body: body,
        start: location().start.offset,
        end: location().end.offset
    }
  }

AssemblyFor
  = ForToken __
  init:(InlineAssemblyBlock / FunctionalAssemblyInstruction) __
  test:FunctionalAssemblyInstruction __
  update:(InlineAssemblyBlock / FunctionalAssemblyInstruction) __
  body:InlineAssemblyBlock
  {
    return {
      type: "AssemblyFor",
      init: init,
      test: test,
      update: update,
      body: body,
      start: location().start.offset,
      end: location().end.offset
    };
  }
