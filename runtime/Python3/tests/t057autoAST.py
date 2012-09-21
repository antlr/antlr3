import unittest
import textwrap
import antlr3
import antlr3.tree
import testbase
import sys

class TestAutoAST(testbase.ANTLRTest):
    def parserClass(self, base):
        class TParser(base):
            def __init__(self, *args, **kwargs):
                super().__init__(*args, **kwargs)

                self._errors = []
                self._output = ""


            def capture(self, t):
                self._output += t


            def traceIn(self, ruleName, ruleIndex):
                self.traces.append('>'+ruleName)


            def traceOut(self, ruleName, ruleIndex):
                self.traces.append('<'+ruleName)


            def emitErrorMessage(self, msg):
                self._errors.append(msg)


        return TParser


    def lexerClass(self, base):
        class TLexer(base):
            def __init__(self, *args, **kwargs):
                super().__init__(*args, **kwargs)

                self._output = ""


            def capture(self, t):
                self._output += t


            def traceIn(self, ruleName, ruleIndex):
                self.traces.append('>'+ruleName)


            def traceOut(self, ruleName, ruleIndex):
                self.traces.append('<'+ruleName)


            def recover(self, input, re):
                # no error recovery yet, just crash!
                raise

        return TLexer


    def execParser(self, grammar, grammarEntry, input, expectErrors=False):
        lexerCls, parserCls = self.compileInlineGrammar(grammar)

        cStream = antlr3.StringStream(input)
        lexer = lexerCls(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = parserCls(tStream)
        r = getattr(parser, grammarEntry)()

        if not expectErrors:
            self.assertEqual(len(parser._errors), 0, parser._errors)

        result = ""

        if r:
            if hasattr(r, 'result'):
                result += r.result

            if r.tree:
                result += r.tree.toStringTree()

        if not expectErrors:
            return result

        else:
            return result, parser._errors


    def execTreeParser(self, grammar, grammarEntry, treeGrammar, treeEntry, input):
        lexerCls, parserCls = self.compileInlineGrammar(grammar)
        walkerCls = self.compileInlineGrammar(treeGrammar)

        cStream = antlr3.StringStream(input)
        lexer = lexerCls(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = parserCls(tStream)
        r = getattr(parser, grammarEntry)()
        nodes = antlr3.tree.CommonTreeNodeStream(r.tree)
        nodes.setTokenStream(tStream)
        walker = walkerCls(nodes)
        r = getattr(walker, treeEntry)()

        if r:
            return r.tree.toStringTree()

        return ""


    def testTokenList(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : ID INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN};
            ''')

        found = self.execParser(grammar, "a", "abc 34")
        self.assertEqual("abc 34", found);


    def testTokenListInSingleAltBlock(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : (ID INT) ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar,"a", "abc 34")
        self.assertEqual("abc 34", found)


    def testSimpleRootAtOuterLevel(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : ID^ INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "abc 34")
        self.assertEqual("(abc 34)", found)


    def testSimpleRootAtOuterLevelReverse(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : INT ID^ ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "34 abc")
        self.assertEqual("(abc 34)", found)


    def testBang(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID INT! ID! INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "abc 34 dag 4532")
        self.assertEqual("abc 4532", found)


    def testOptionalThenRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ( ID INT )? ID^ ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a 1 b")
        self.assertEqual("(b a 1)", found)


    def testLabeledStringRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : v='void'^ ID ';' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "void foo;")
        self.assertEqual("(void foo ;)", found)


    def testWildcard(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : v='void'^ . ';' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "void foo;")
        self.assertEqual("(void foo ;)", found)


    def testWildcardRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : v='void' .^ ';' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "void foo;")
        self.assertEqual("(foo void ;)", found)


    def testWildcardRootWithLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : v='void' x=.^ ';' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "void foo;")
        self.assertEqual("(foo void ;)", found)


    def testWildcardRootWithListLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : v='void' x=.^ ';' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "void foo;")
        self.assertEqual("(foo void ;)", found)


    def testWildcardBangWithListLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : v='void' x=.! ';' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "void foo;")
        self.assertEqual("void ;", found)


    def testRootRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID^ INT^ ID ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a 34 c")
        self.assertEqual("(34 a c)", found)


    def testRootRoot2(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID INT^ ID^ ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a 34 c")
        self.assertEqual("(c (34 a))", found)


    def testRootThenRootInLoop(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID^ (INT '*'^ ID)+ ;
            ID  : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a 34 * b 9 * c")
        self.assertEqual("(* (* (a 34) b 9) c)", found)


    def testNestedSubrule(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : 'void' (({pass}ID|INT) ID | 'null' ) ';' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "void a b;")
        self.assertEqual("void a b ;", found)


    def testInvokeRule(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a  : type ID ;
            type : {pass}'int' | 'float' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "int a")
        self.assertEqual("int a", found)


    def testInvokeRuleAsRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a  : type^ ID ;
            type : {pass}'int' | 'float' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "int a")
        self.assertEqual("(int a)", found)


    def testInvokeRuleAsRootWithLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a  : x=type^ ID ;
            type : {pass}'int' | 'float' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "int a")
        self.assertEqual("(int a)", found)


    def testInvokeRuleAsRootWithListLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a  : x+=type^ ID ;
            type : {pass}'int' | 'float' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "int a")
        self.assertEqual("(int a)", found)


    def testRuleRootInLoop(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID ('+'^ ID)* ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a+b+c+d")
        self.assertEqual("(+ (+ (+ a b) c) d)", found)


    def testRuleInvocationRuleRootInLoop(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID (op^ ID)* ;
            op : {pass}'+' | '-' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a+b+c-d")
        self.assertEqual("(- (+ (+ a b) c) d)", found)


    def testTailRecursion(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            s : a ;
            a : atom ('exp'^ a)? ;
            atom : INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "s", "3 exp 4 exp 5")
        self.assertEqual("(exp 3 (exp 4 5))", found)


    def testSet(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID|INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "abc")
        self.assertEqual("abc", found)


    def testSetRoot(self):
        grammar = textwrap.dedent(
        r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ('+' | '-')^ ID ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "+abc")
        self.assertEqual("(+ abc)", found)


    @testbase.broken(
        "FAILS until antlr.g rebuilt in v3", testbase.GrammarCompileError)
    def testSetRootWithLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : x=('+' | '-')^ ID ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "+abc")
        self.assertEqual("(+ abc)", found)


    def testSetAsRuleRootInLoop(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ID (('+'|'-')^ ID)* ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a+b-c")
        self.assertEqual("(- (+ a b) c)", found)


    def testNotSet(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ~ID '+' INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "34+2")
        self.assertEqual("34 + 2", found)


    def testNotSetWithLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : x=~ID '+' INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "34+2")
        self.assertEqual("34 + 2", found)


    def testNotSetWithListLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : x=~ID '+' INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "34+2")
        self.assertEqual("34 + 2", found)


    def testNotSetRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ~'+'^ INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "34 55")
        self.assertEqual("(34 55)", found)


    def testNotSetRootWithLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ~'+'^ INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "34 55")
        self.assertEqual("(34 55)", found)


    def testNotSetRootWithListLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : ~'+'^ INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "34 55")
        self.assertEqual("(34 55)", found)


    def testNotSetRuleRootInLoop(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : INT (~INT^ INT)* ;
            blort : '+' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "3+4+5")
        self.assertEqual("(+ (+ 3 4) 5)", found)


    @testbase.broken("FIXME: What happened to the semicolon?", AssertionError)
    def testTokenLabelReuse(self):
        # check for compilation problem due to multiple defines
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a returns [result] : id=ID id=ID {$result = "2nd id="+$id.text+";"} ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b")
        self.assertEqual("2nd id=b;a b", found)


    def testTokenLabelReuse2(self):
        # check for compilation problem due to multiple defines
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a returns [result]: id=ID id=ID^ {$result = "2nd id="+$id.text+','} ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b")
        self.assertEqual("2nd id=b,(b a)", found)


    def testTokenListLabelReuse(self):
        # check for compilation problem due to multiple defines
        # make sure ids has both ID tokens
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a returns [result] : ids+=ID ids+=ID {$result = "id list=[{}],".format(",".join([t.text for t in $ids]))} ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b")
        expecting = "id list=[a,b],a b"
        self.assertEqual(expecting, found)


    def testTokenListLabelReuse2(self):
        # check for compilation problem due to multiple defines
        # make sure ids has both ID tokens
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a returns [result] : ids+=ID^ ids+=ID {$result = "id list=[{}],".format(",".join([t.text for t in $ids]))} ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b")
        expecting = "id list=[a,b],(a b)"
        self.assertEqual(expecting, found)


    def testTokenListLabelRuleRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : id+=ID^ ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a")
        self.assertEqual("a", found)


    def testTokenListLabelBang(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : id+=ID! ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a")
        self.assertEqual("", found)


    def testRuleListLabel(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a returns [result]: x+=b x+=b {
            t=$x[1]
            $result = "2nd x="+t.toStringTree()+',';
            };
            b : ID;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b")
        self.assertEqual("2nd x=b,a b", found)


    def testRuleListLabelRuleRoot(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a returns [result] : ( x+=b^ )+ {
            $result = "x="+$x[1].toStringTree()+',';
            } ;
            b : ID;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b")
        self.assertEqual("x=(b a),(b a)", found)


    def testRuleListLabelBang(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a returns [result] : x+=b! x+=b {
            $result = "1st x="+$x[0].toStringTree()+',';
            } ;
            b : ID;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b")
        self.assertEqual("1st x=a,b", found)


    def testComplicatedMelange(self):
        # check for compilation problem
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options {language=Python3;output=AST;}
            a : A b=B b=B c+=C c+=C D {s = $D.text} ;
            A : 'a' ;
            B : 'b' ;
            C : 'c' ;
            D : 'd' ;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "a b b c c d")
        self.assertEqual("a b b c c d", found)


    def testReturnValueWithAST(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a returns [result] : ID b { $result = str($b.i) + '\n';} ;
            b returns [i] : INT {$i=int($INT.text);} ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found = self.execParser(grammar, "a", "abc 34")
        self.assertEqual("34\nabc 34", found)


    def testSetLoop(self):
        grammar = textwrap.dedent(
            r'''
            grammar T;
            options { language=Python3;output=AST; }
            r : (INT|ID)+ ;
            ID : 'a'..'z' + ;
            INT : '0'..'9' +;
            WS: (' ' | '\n' | '\\t')+ {$channel = HIDDEN};
            ''')

        found = self.execParser(grammar, "r", "abc 34 d")
        self.assertEqual("abc 34 d", found)


    def testExtraTokenInSimpleDecl(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            decl : type^ ID '='! INT ';'! ;
            type : 'int' | 'float' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "decl", "int 34 x=1;",
                                        expectErrors=True)
        self.assertEqual(["line 1:4 extraneous input '34' expecting ID"],
                         errors)
        self.assertEqual("(int x 1)", found) # tree gets correct x and 1 tokens


    def testMissingIDInSimpleDecl(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            tokens {EXPR;}
            decl : type^ ID '='! INT ';'! ;
            type : 'int' | 'float' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "decl", "int =1;",
                                        expectErrors=True)
        self.assertEqual(["line 1:4 missing ID at '='"], errors)
        self.assertEqual("(int <missing ID> 1)", found) # tree gets invented ID token


    def testMissingSetInSimpleDecl(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            tokens {EXPR;}
            decl : type^ ID '='! INT ';'! ;
            type : 'int' | 'float' ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "decl", "x=1;",
                                        expectErrors=True)
        self.assertEqual(["line 1:0 mismatched input 'x' expecting set None"], errors)
        self.assertEqual("(<error: x> x 1)", found) # tree gets invented ID token


    def testMissingTokenGivesErrorNode(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : ID INT ; // follow is EOF
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "a", "abc", expectErrors=True)
        self.assertEqual(["line 1:3 missing INT at '<EOF>'"], errors)
        self.assertEqual("abc <missing INT>", found)


    def testMissingTokenGivesErrorNodeInInvokedRule(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : b ;
            b : ID INT ; // follow should see EOF
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "a", "abc", expectErrors=True)
        self.assertEqual(["line 1:3 mismatched input '<EOF>' expecting INT"], errors)
        self.assertEqual("<mismatched token: <EOF>, resync=abc>", found)


    def testExtraTokenGivesErrorNode(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : b c ;
            b : ID ;
            c : INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "a", "abc ick 34",
                                        expectErrors=True)
        self.assertEqual(["line 1:4 extraneous input 'ick' expecting INT"],
                          errors)
        self.assertEqual("abc 34", found)


    def testMissingFirstTokenGivesErrorNode(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : ID INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "a", "34", expectErrors=True)
        self.assertEqual(["line 1:0 missing ID at '34'"], errors)
        self.assertEqual("<missing ID> 34", found)


    def testMissingFirstTokenGivesErrorNode2(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : b c ;
            b : ID ;
            c : INT ;
            ID : 'a'..'z'+ ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "a", "34", expectErrors=True)

        # finds an error at the first token, 34, and re-syncs.
        # re-synchronizing does not consume a token because 34 follows
        # ref to rule b (start of c). It then matches 34 in c.
        self.assertEqual(["line 1:0 missing ID at '34'"], errors)
        self.assertEqual("<missing ID> 34", found)


    def testNoViableAltGivesErrorNode(self):
        grammar = textwrap.dedent(
            r'''
            grammar foo;
            options {language=Python3;output=AST;}
            a : b | c ;
            b : ID ;
            c : INT ;
            ID : 'a'..'z'+ ;
            S : '*' ;
            INT : '0'..'9'+;
            WS : (' '|'\n') {$channel=HIDDEN} ;
            ''')

        found, errors = self.execParser(grammar, "a", "*", expectErrors=True)
        self.assertEqual(["line 1:0 no viable alternative at input '*'"],
                         errors)
        self.assertEqual("<unexpected: [@0,0:0='*',<S>,1:0], resync=*>",
                         found)


if __name__ == '__main__':
    unittest.main()
