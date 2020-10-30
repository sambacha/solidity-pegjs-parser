# PEGJS Solidity Parser

> [@pegjs-solidity](https://www.npmjs.com/package/solidity-pegjs-parser)

## NPM Package Information

[https://registry.npmjs.org/solidity-pegjs-parser](https://registry.npmjs.org/solidity-pegjs-parser)

## Solidity Grammar Updates

> Changes in updated Grammar 

``` diff
--- archive/solidity.pegjs	2020-10-10 03:17:33.684241381 -0700
+++ lib/solidity.pegjs	2020-10-10 03:32:25.243833686 -0700
@@ -37,7 +37,7 @@
 {
   var TYPES_TO_PROPERTY_NAMES = {
     CallExpression:   "callee",
-    MemberExpression: "object",
+    MemberExpression: "object"
   };
 
   function filledArray(count, value) {
@@ -85,8 +85,8 @@
         operator: element[1],
         left:     result,
         right:    element[3],
-        start: location().start.offset,
-        end: location().end.offset
+        start: result.start,
+        end: element[3].end
       };
     });
   }
@@ -171,9 +171,6 @@
       };
     }
 
-Interpolation
-  = "{{" __ name:IdentifierName __ "}}" { return name; }
-
 IdentifierStart
   = UnicodeLetter
   / "$"
@@ -183,6 +180,16 @@
   = IdentifierStart
   / UnicodeDigit
 
+AddressPayable
+  = "address" __  PayableToken {
+      return {
+        type: "Identifier",
+        name: "address_payable",
+        start: location().start.offset,
+        end: location().end.offset
+      };
+    }
+
 UnicodeLetter
   = Lu
   / Ll
@@ -208,7 +215,6 @@
 
 Keyword
   = BreakToken
-  / ConstructorToken
   / ContinueToken
   / ContractToken
   / InterfaceToken
@@ -229,11 +235,6 @@
   / VarToken
   / WhileToken
 
-FutureReservedWord
-  = ClassToken
-  / ExportToken
-  / ExtendsToken
-
 Literal
   = BooleanLiteral
   / DenominationLiteral
@@ -332,7 +333,14 @@
     }
 
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
 
 DoubleStringCharacter
   = !('"' / "\\" / LineTerminator) SourceCharacter { return text(); }
@@ -388,11 +396,25 @@
     }
 
 VersionLiteral
-  = operator:(RelationalOperator / EqualityOperator / BitwiseXOROperator)? __ ("v")? major:DecimalIntegerLiteral "." minor:DecimalIntegerLiteral "." patch:DecimalIntegerLiteral {
+  = operator:(RelationalOperator / EqualityOperator / BitwiseXOROperator / Tilde)? __ ("v")? major:DecimalIntegerLiteral minor:("." DecimalIntegerLiteral)? patch:("." DecimalIntegerLiteral)? {
+    if (patch === null) {
+      patch = 0;
+    } else {
+      patch = patch[1];
+    }
+
+    if (minor === null) {
+      minor = 0;
+    } else {
+      minor = minor[1];
+    }
+
     return {
       type: "VersionLiteral",
       operator: operator,
-      version: (normalizeVersionLiteral(major) + "." + normalizeVersionLiteral(minor) + "." + normalizeVersionLiteral(patch))
+      version: (normalizeVersionLiteral(major) + "." + normalizeVersionLiteral(minor) + "." + normalizeVersionLiteral(patch)),
+      start: location().start.offset,
+      end: location().end.offset
     };
   }
 
@@ -456,26 +478,27 @@
 
 /* Tokens */
 
+EmitToken       = "emit"       !IdentifierPart
+ExperimentalToken      = "experimental"      !IdentifierPart
+ExternalToken   = "external"   !IdentifierPart
+PureToken       = "pure"       !IdentifierPart
+ViewToken       = "view"       !IdentifierPart
+PayableToken    = "payable"    !IdentifierPart
 AnonymousToken  = "anonymous"  !IdentifierPart
-ABIEncoderV2Token = "ABIEncoderV2" !IdentifierPart
 AsToken         = "as"         !IdentifierPart
 BreakToken      = "break"      !IdentifierPart
-ClassToken      = "class"      !IdentifierPart
+CalldataToken   = "calldata"   !IdentifierPart
 ConstantToken   = "constant"   !IdentifierPart
-ConstructorToken = "constructor" !IdentifierPart
 ContinueToken   = "continue"   !IdentifierPart
 ContractToken   = "contract"   !IdentifierPart
+ConstructorToken   = "constructor"   !IdentifierPart
 DaysToken       = "days"       !IdentifierPart
 DeleteToken     = "delete"     !IdentifierPart
 DoToken         = "do"         !IdentifierPart
 ElseToken       = "else"       !IdentifierPart
-EmitToken       = "emit"       !IdentifierPart
 EnumToken       = "enum"       !IdentifierPart
 EtherToken      = "ether"      !IdentifierPart
 EventToken      = "event"      !IdentifierPart
-ExperimentalToken  = "experimental" !IdentifierPart
-ExportToken     = "export"     !IdentifierPart
-ExtendsToken    = "extends"    !IdentifierPart
 FalseToken      = "false"      !IdentifierPart
 FinneyToken     = "finney"     !IdentifierPart
 ForToken        = "for"        !IdentifierPart
@@ -546,7 +569,16 @@
   / Identifier
   / Literal
   / ArrayLiteral
-  / "(" __ expression:Expression __ ")" { return expression; }
+  / "(" __ expression:Expression __ ")" {
+      /*
+        Need to modify the location here so the position takes into account the "(" & ")".
+        Else "(a, b)" (for eg) results in incorrect position.
+      */
+      expression.start = location().start.offset;
+      expression.end = location().end.offset;
+
+      return expression;
+    }
 
 ArrayLiteral
   = "[" __ elision:(Elision __)? "]" {
@@ -594,12 +626,23 @@
   = head:(
         PrimaryExpression
       / NewToken __ callee:Type __ args:Arguments {
-          return { type: "NewExpression", callee: callee, arguments: args, start: location().start.offset, end: location().end.offset };
+          return {
+            type: "NewExpression",
+            callee: callee,
+            arguments: args,
+            start: location().start.offset,
+            end: location().end.offset
+          };
         }
     )
     tail:(
         __ "[" __ property:Expression __ "]" {
-          return { property: property, computed: true, start: location().start.offset, end: location().end.offset };
+          return {
+            property: property,
+            computed: true,
+            start: location().start.offset,
+            end: location().end.offset
+          };
         }
       / __ "." __ property:IdentifierName {
           return { property: property, computed: false, start: location().start.offset, end: location().end.offset };
@@ -657,6 +700,12 @@
       return buildTree(head, tail, function(result, element) {
         element[TYPES_TO_PROPERTY_NAMES[element.type]] = result;
 
+        // Fix the start position of all nodes (ORIGIN: https://github.com/duaraghav8/Solium/issues/104)
+        // The MemberExpression node's start property doesnt cover the entire previous code
+        // eg - "ab.cd()[10]" the node.start points to '[' instead of 'a'
+        // Same issue with CallExpression
+
+        element.start = location().start.offset;
         return element;
       });
     }
@@ -668,9 +717,6 @@
   / "(" __ "{" __ args:(NameValueList (__ ",")? )? __ "}" __ ")" {
       return optionalList(extractOptional(args, 0));
     }
-  / "(" __ args:Interpolation __ ")" {
-      return [args];
-    }
 
 ArgumentList
   = head:AssignmentExpression tail:(__ "," __ AssignmentExpression)* {
@@ -697,10 +743,9 @@
   = DeclarativeExpression
   / CallExpression
   / NewExpression
-  / Interpolation
 
 Type
-  = literal:(Mapping / Identifier / FunctionToken __ FunctionName __ ModifierArgumentList? __ ReturnsDeclaration? __ IdentifierName?) members:("." Identifier)* parts:(__"[" __ (Expression)? __ "]")*
+  = literal:(Mapping / AddressPayable / Identifier) members:("." Identifier)* parts:(__"[" __ (Expression)? __ "]")*
   {
     return {
       type: "Type",
@@ -711,6 +756,43 @@
       end: location().end.offset
     }
   }
+  / FunctionToken __ funcName:FunctionName __ modifiers:FunctionTypeModifierList? __ returns:ReturnsDeclarations __ parts:(__"[" __ (Expression)? __ "]")*
+    {
+      return {
+        type: "Type",
+        literal: "function",
+        params: funcName.params,
+        return_params: returns,
+        array_parts: optionalList(parts).map(function(p) {return p[3] != null ? p[3].value : null}),
+        modifiers: modifiers,
+        start: location().start.offset,
+        end: location().end.offset
+      };
+    }
+
+FunctionTypeModifier
+  = modifier:(InternalToken / ExternalToken / StateMutabilitySpecifier) {
+      if (Array.isArray(modifier)) {
+        return {
+          type: "VisibilitySpecifier",
+          value: modifier[0],
+          start: location().start.offset,
+          end: location().end.offset
+        };
+      }
+
+      return modifier;
+    }
+
+StateMutabilitySpecifier
+  = token:(ConstantToken / PureToken / ViewToken / PayableToken) {
+      return {
+        type: "StateMutabilitySpecifier",
+        value: token[0],
+        start: location().start.offset,
+        end: location().end.offset
+      };
+    }
 
 VisibilitySpecifier
   = PublicToken
@@ -720,12 +802,13 @@
 StorageLocationSpecifier
   = StorageToken
   / MemoryToken
+  / CalldataToken
 
 StateVariableSpecifiers
   = specifiers:(VisibilitySpecifier __ ConstantToken?){
     return {
       visibility: specifiers[0][0],
-      isconstant: specifiers[2] ? true: false
+      isconstant: specifiers[2] ? true: false 
     }
   }
   / specifiers:(ConstantToken __ VisibilitySpecifier?){
@@ -735,13 +818,13 @@
     }
   }
 
-StateVariableValue
+StateVariableValue 
   = "=" __ expression:Expression {
     return expression;
   }
 
 StateVariableDeclaration
-  = type:Type __ specifiers:StateVariableSpecifiers? __ id:Identifier __ value:StateVariableValue? __ EOS
+  = type:Type __ specifiers:StateVariableSpecifiers? __ id:Identifier __ value:StateVariableValue? __ EOS  
   {
     return {
       type: "StateVariableDeclaration",
@@ -756,12 +839,12 @@
   }
 
 DeclarativeExpression
-  = type:Type __ storage:StorageLocationSpecifier? __ id:Identifier
+  = type:Type __ storage:StorageLocationSpecifier? __ id:Identifier 
   {
     return {
       type: "DeclarativeExpression",
       name: id.name,
-      literal: type,
+      literal: type, 
       storage_location: storage ? storage[0]: null,
       start: location().start.offset,
       end: location().end.offset
@@ -872,6 +955,9 @@
   = "=="
   / "!="
 
+Tilde
+  = "~"
+
 BitwiseANDExpression
   = head:EqualityExpression
     tail:(__ BitwiseANDOperator __ EqualityExpression)*
@@ -970,10 +1056,26 @@
   / "|="
 
 Expression
-  = Comma * __ head:AssignmentExpression tail:(Comma+ AssignmentExpression)* __ Comma* {
-      return tail.length > 0
-        ? { type: "SequenceExpression", expressions: buildList(head, tail, 3) }
-        : head;
+  = head:AssignmentExpression? tail:(__ "," __ AssignmentExpression?)* {
+      if (tail.length < 1) {
+        return head;
+      }
+
+      // Below is a hack to successfully parse "(, a, , b, c,,,)" so expressions array only contains a, b & c
+      // Hack is all we require since we're moving to a new parse very soon anyway :)
+
+      var expressions = buildList(head, tail, 3), finalExpr = [];
+
+      for (var i = 0; i < expressions.length; i++) {
+        if (expressions[i] !== null) { finalExpr.push(expressions[i]); }
+      }
+
+      return {
+        type: "SequenceExpression",
+        expressions: finalExpr,
+        start: location().start.offset,
+        end: location().end.offset
+      };
     }
 
 /* ----- A.4 Statements ----- */
@@ -986,10 +1088,9 @@
 Statement
   = Block
   / VariableStatement
-  / EmitStatement
   / EmptyStatement
-  / PlaceholderStatement
   / ExpressionStatement
+  / PlaceholderStatement
   / IfStatement
   / IterationStatement
   / InlineAssemblyStatement
@@ -998,6 +1099,7 @@
   / ReturnStatement
   / ThrowStatement
   / UsingStatement
+  / EmitStatement
 
 Block
   = "{" __ body:(StatementList __)? "}" {
@@ -1050,6 +1152,7 @@
       };
     }
 
+
 VariableDeclarationList
   = head:VariableDeclaration tail:(__ "," __ VariableDeclaration)* {
       return buildList(head, tail, 3);
@@ -1069,21 +1172,11 @@
 Initialiser
   = "=" !"=" __ expression:AssignmentExpression { return expression; }
 
-EmitStatement
-  = EmitToken __ expression:CallExpression __ EOS {
-    return {
-      type: "EmitStatement",
-      expression: expression,
-      start: location().start.offset,
-      end: location().end.offset
-    }
-  }
-
 EmptyStatement
   = ";" { return { type: "EmptyStatement", start: location().start.offset, end: location().end.offset }; }
 
 ExpressionStatement
-  = !("{" / FunctionToken / ContractToken / InterfaceToken / LibraryToken / StructToken / EnumToken) expression:Expression EOS {
+  = !("{" / ContractToken / InterfaceToken / LibraryToken / StructToken / EnumToken) expression:Expression EOS {
       return {
         type:       "ExpressionStatement",
         expression: expression,
@@ -1129,20 +1222,10 @@
       end: location().end.offset
     }
   }
-  / PragmaToken __ ExperimentalToken __ end_version:StringLiteral __ EOS {
+  / PragmaToken __ ExperimentalToken __ featureName:(Identifier / StringLiteral) EOS {
     return {
-      type: "PragmaStatement",
-      start_version: "experimental",
-      end_version: end_version,
-      start: location().start.offset,
-      end: location().end.offset
-    }
-  }
-  / PragmaToken __ ExperimentalToken __ ABIEncoderV2Token __ EOS {
-    return {
-      type: "PragmaStatement",
-      start_version: "experimental",
-      end_version: "ABIEncoderV2",
+      type: "ExperimentalPragmaStatement",
+      feature: featureName,
       start: location().start.offset,
       end: location().end.offset
     }
@@ -1160,16 +1243,12 @@
       end: location().end.offset
     }
   }
-  / ImportToken __ "*" __ AsToken __ alias:Identifier __ FromToken __ from:StringLiteral __ EOS
+  / ImportToken __ symbol:GlobalSymbol __ FromToken __ from:StringLiteral __ EOS
   {
     return {
       type: "ImportStatement",
       from: from.value,
-      symbols: [{
-        type: "Symbol",
-        name: "*",
-        alias: alias.name
-      }],
+      symbols: [symbol],
       start: location().start.offset,
       end: location().end.offset
     }
@@ -1207,6 +1286,17 @@
     }
   }
 
+EmitStatement
+  = EmitToken __ callexpr:CallExpression EOS
+  {
+    return {
+      type: "EmitStatement",
+      expression: callexpr,
+      start: location().start.offset,
+      end: location().end.offset
+    };
+  }
+
 SymbolList
   = head:Symbol tail:( __ "," __ Symbol)* {
       return buildList(head, tail, 3);
@@ -1224,6 +1314,18 @@
     };
   }
 
+GlobalSymbol
+  = name:"*" __ alias:(AsToken __ Identifier)
+  {
+    return {
+      type: "Symbol",
+      name: "*",
+      alias: alias[2].name,
+      start: location().start.offset,
+      end: location().end.offset
+    }
+  }
+
 IterationStatement
   = DoToken __
     body:Statement __
@@ -1262,7 +1364,9 @@
         type:   "ForStatement",
         init:   {
           type:         "VariableDeclaration",
-          declarations: declarations
+          declarations: declarations,
+          start: location().start.offset,
+          end: location().end.offset
         },
         test:   extractOptional(test, 0),
         update: extractOptional(update, 0),
@@ -1283,7 +1387,7 @@
   }
 
 PlaceholderStatement
-  = "_" __ EOS {
+  = "_" (__ EOS)? {
     return {
       type: "PlaceholderStatement",
       start: location().start.offset,
@@ -1328,7 +1432,7 @@
       type: "ContractStatement",
       name: id.name,
       is: is != null ? is.names : [],
-      body: optionalList(body),
+      body: optionalList (body),
       start: location().start.offset,
       end: location().end.offset
     }
@@ -1342,7 +1446,7 @@
       type: "InterfaceStatement",
       name: id.name,
       is: [],
-      body: optionalList(body),
+      body: optionalList (body),
       start: location().start.offset,
       end: location().end.offset
     }
@@ -1357,7 +1461,7 @@
       type: "LibraryStatement",
       name: id.name,
       is: is != null ? is.names : [],
-      body: optionalList(body),
+      body: optionalList (body),
       start: location().start.offset,
       end: location().end.offset
     }
@@ -1404,25 +1508,11 @@
     }
 
 FunctionDeclaration
-  = FunctionToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclaration? __ body:FunctionBody
-    {
-      return {
-        type: "FunctionDeclaration",
-        name: fnname.name || "fallback",
-        params: fnname.params,
-        modifiers: args,
-        returnParams: returns,
-        body: body,
-        is_abstract: false,
-        start: location().start.offset,
-        end: location().end.offset
-      };
-    }
-  / ConstructorToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclaration? __ body:FunctionBody
+  = FunctionToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclarations __ body:FunctionBody
     {
       return {
         type: "FunctionDeclaration",
-        name: "constructor",
+        name: fnname.name,
         params: fnname.params,
         modifiers: args,
         returnParams: returns,
@@ -1432,11 +1522,11 @@
         end: location().end.offset
       };
     }
-  / FunctionToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclaration? __ EOS
+  / FunctionToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclarations __ EOS
     {
       return {
         type: "FunctionDeclaration",
-        name: fnname.name || "fallback",
+        name: fnname.name,
         params: fnname.params,
         modifiers: args,
         returnParams: returns,
@@ -1446,28 +1536,41 @@
         end: location().end.offset
       };
     }
-  / FunctionToken __ fnname:FunctionName __ args:ModifierArgumentList? __ returns:ReturnsDeclaration? __ IdentifierName? __ EOS
+
+ConstructorDeclaration
+  = ConstructorToken __ fnname:FunctionName __ args:ModifierArgumentList? __ body:FunctionBody
     {
       return {
-        type: "FunctionDeclaration",
-        name: fnname.name || "fallback",
+        type: "ConstructorDeclaration",
         params: fnname.params,
         modifiers: args,
-        returnParams: returns,
-        body: null,
-        is_abstract: true,
+        body: body,
         start: location().start.offset,
         end: location().end.offset
       };
     }
 
-
 ReturnsDeclaration
   = ReturnsToken __ params:("(" __ InformalParameterList __ ")")
   {
     return params != null ? params [2] : null;
   }
 
+ReturnsDeclarations
+  = returnParams:ReturnsDeclaration?
+  {
+    if (returnParams == null) {
+      return null;
+    }
+
+    return {
+      type: "ReturnParams",
+      params: returnParams,
+      start: location().start.offset,
+      end: location().end.offset
+    };
+  }
+    
 
 FunctionName
   = id:Identifier? __ params:("(" __ InformalParameterList? __ ")")
@@ -1494,12 +1597,18 @@
   }
 
 ModifierArgument
-  = id:Identifier __ params:("(" __ ArgumentList? __ ")")?
+  = id:Identifier params:(__ "(" __ ArgumentList? __ ")")?
   {
+    var p = [];
+
+    if (params != null && params[3] != null) {
+      p = params[3];
+    }
+
     return {
       type: "ModifierArgument",
       name: id != null ? id.name : null,
-      params: params != null ? params[2] : [],
+      params: p,
       start: location().start.offset,
       end: location().end.offset
     };
@@ -1520,22 +1629,40 @@
       return buildList(head, tail, 1);
     }
 
+FunctionTypeModifierList
+  = head:FunctionTypeModifier tail:( __ FunctionTypeModifier)* {
+      return buildList(head, tail, 1);
+    }
+
+ModifierNameWithAlias
+  = alias:(Identifier ".")* modifier:ModifierName {
+      if (alias.length > 0) {
+        var mergedAlias = alias.reduce(function(result, item) {
+          return result + item[0].name + item[1];
+        }, "");
+
+        modifier.name = mergedAlias + modifier.name;
+        modifier.start = alias[0][0].start;
+      }
+
+      return modifier;
+    }
+
 CommaSeparatedModifierNameList
-  = head:ModifierName tail:( __ "," __ ModifierName)* {
+  = head:ModifierNameWithAlias tail:( __ "," __ ModifierNameWithAlias)* {
       return buildList(head, tail, 3);
     }
 
 InformalParameter
-  = type:Type __ isindexed:IndexedToken? __ isconstant:ConstantToken? __ isstorage:StorageToken? __ ismemory:MemoryToken? __ id:Identifier?
+  = type:Type __ isindexed:IndexedToken? __ isconstant:ConstantToken? __ storage:StorageLocationSpecifier? __ id:Identifier?
   {
     return {
       type: "InformalParameter",
       literal: type,
-      id: (id || {}).name,
+      id: id ? id.name : null,
       is_indexed: isindexed != null,
-      is_storage: isconstant != null,
-      is_storage: isstorage != null,
-      is_memory: ismemory != null,
+      is_constant: isconstant != null,
+      storage_location: storage ? storage[0]: null,
       start: location().start.offset,
       end: location().end.offset
     };
@@ -1582,7 +1709,7 @@
   }
 
 DeclarativeExpressionList
-  = head:(DeclarativeExpression __ EOS / FunctionDeclaration __) tail:( __ DeclarativeExpression __ EOS / __ FunctionDeclaration )*
+  = head:DeclarativeExpression __ EOS tail:( __ DeclarativeExpression __ EOS )*
   {
     return {
       type: "DeclarativeExpressionList",
@@ -1626,6 +1753,7 @@
   / StructDeclaration
   / ModifierDeclaration
   / FunctionDeclaration
+  / ConstructorDeclaration
   / UsingStatement
 
 InlineAssemblyBlock
@@ -1641,19 +1769,16 @@
 AssemblyItem
   = FunctionalAssemblyInstruction
   / InlineAssemblyBlock
+  / AssemblyFunctionDefinition
   / AssemblyLocalBinding
   / AssemblyAssignment
   / AssemblyLabel
-  / AssemblySwitch
-  / AssemblyFunctionDefinition
+  / AssemblyIf
   / AssemblyFor
-  / AssemblyLiteral
-  / Identifier
-
-AssemblyLiteral
-  = NumericLiteral
+  / NumericLiteral
   / StringLiteral
   / HexStringLiteral
+  / Identifier
 
 AssemblyExpression
   = FunctionalAssemblyInstruction
@@ -1664,53 +1789,50 @@
   / StringLiteral
   / Identifier
 
-AssemblyLocalBinding
-  = 'let' __ name:Identifier __ ':=' __ expression:AssemblyExpression {
+AssemblyIdentifierList
+  = head:Identifier tail:(__ ',' __ Identifier)* {
+    return buildList(head, tail, 3);
+  }
+
+AssemblyFunctionDefinition
+  = FunctionToken __ id:Identifier __ '(' __ params:AssemblyIdentifierList? __ ')' __ returns:('->' __ AssemblyIdentifierList __)? body:InlineAssemblyBlock {
     return {
-      type: "AssemblyLocalBinding",
-      name: name,
-      expression: expression,
+      type: "AssemblyFunctionDefinition",
+      name: id.name,
+      params: params != null ? params : [],
+      returnParams: returns != null ? returns[2] : [],
+      body: body,
       start: location().start.offset,
       end: location().end.offset
     }
   }
 
-AssemblyAssignment
-  = name:Identifier __ ':=' __ expression:AssemblyExpression {
+AssemblyLocalBinding
+  = 'let' __ names:AssemblyIdentifierList expression:(__ ':=' __ AssemblyExpression)? {
+    if (expression != null) {
+      expression = expression[3];
+    }
+
     return {
-      type: "AssemblyAssignment",
-      name: name,
+      type: "AssemblyLocalBinding",
+      names: names,
       expression: expression,
       start: location().start.offset,
       end: location().end.offset
     }
   }
-  / '=:' __ name:Identifier {
+
+AssemblyAssignment
+  = names:AssemblyIdentifierList __ ':=' __ expression:AssemblyExpression {
     return {
       type: "AssemblyAssignment",
-      name: name,
+      names: names,
+      expression: expression,
       start: location().start.offset,
       end: location().end.offset
     }
   }
 
-AssemblyIdentifierList
-  = Identifier ( ',' Identifier )*
-
-AssemblyCase
-  = __ 'case' __ AssemblyLiteral __ ':' InlineAssemblyBlock
-
-AssemblySwitch
-  = __ 'switch' __ AssemblyExpression __ AssemblyCase* __ ( 'default' ':' InlineAssemblyBlock )?
-
-
-AssemblyFunctionDefinition
-  = 'function' __ Identifier __ '(' AssemblyIdentifierList? ')' __ ( '->'  AssemblyIdentifierList )? __ InlineAssemblyBlock
-
-AssemblyFor
-  = 'for' __ ( InlineAssemblyBlock / AssemblyExpression )
-     __ AssemblyExpression __ ( InlineAssemblyBlock / AssemblyExpression ) __ InlineAssemblyBlock
-
 ReturnOpCode
   = 'return' {
     return {
@@ -1741,3 +1863,32 @@
       end: location().end.offset
     }
   }
+
+AssemblyIf
+  = IfToken __ test:AssemblyExpression __ body:InlineAssemblyBlock {
+    return {
+        type: "AssemblyIf",
+        test: test,
+        body: body,
+        start: location().start.offset,
+        end: location().end.offset
+    }
+  }
+
+AssemblyFor
+  = ForToken __
+  init:(InlineAssemblyBlock / FunctionalAssemblyInstruction) __
+  test:FunctionalAssemblyInstruction __
+  update:(InlineAssemblyBlock / FunctionalAssemblyInstruction) __
+  body:InlineAssemblyBlock
+  {
+    return {
+      type: "AssemblyFor",
+      init: init,
+      test: test,
+      update: update,
+      body: body,
+      start: location().start.offset,
+      end: location().end.offset
+    };
+  }
```

### Support or Contact

@sambacha / sam@freighttrust.com
