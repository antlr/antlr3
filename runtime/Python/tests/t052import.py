import unittest
import textwrap
import antlr3
import antlr3.tree
import testbase
import sys

class T(testbase.ANTLRTest):
    def setUp(self):
        self.oldPath = sys.path[:]
        sys.path.insert(0, self.baseDir)


    def tearDown(self):
        sys.path = self.oldPath


    def parserClass(self, base):
        class TParser(base):
            def __init__(self, *args, **kwargs):
                base.__init__(self, *args, **kwargs)

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

        return TParser


    def lexerClass(self, base):
        class TLexer(base):
            def __init__(self, *args, **kwargs):
                base.__init__(self, *args, **kwargs)

                self._output = ""


            def capture(self, t):
                self._output += t


            def traceIn(self, ruleName, ruleIndex):
                self.traces.append('>'+ruleName)


            def traceOut(self, ruleName, ruleIndex):
                self.traces.append('<'+ruleName)


            def recover(self, input):
                # no error recovery yet, just crash!
                raise

        return TLexer


    def execParser(self, grammar, grammarEntry, slaves, input):
        for slave in slaves:
            parserName = self.writeInlineGrammar(slave)[0]
            # slave parsers are imported as normal python modules
            # to force reloading current version, purge module from sys.modules
            try:
                del sys.modules[parserName+'Parser']
            except KeyError:
                pass

        lexerCls, parserCls = self.compileInlineGrammar(grammar)

        cStream = antlr3.StringStream(input)
        lexer = lexerCls(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = parserCls(tStream)
        getattr(parser, grammarEntry)()

        return parser._output


    def execLexer(self, grammar, slaves, input):
        for slave in slaves:
            parserName = self.writeInlineGrammar(slave)[0]
            # slave parsers are imported as normal python modules
            # to force reloading current version, purge module from sys.modules
            try:
                del sys.modules[parserName+'Parser']
            except KeyError:
                pass

        lexerCls = self.compileInlineGrammar(grammar)

        cStream = antlr3.StringStream(input)
        lexer = lexerCls(cStream)

        while True:
            token = lexer.nextToken()
            if token is None or token.type == antlr3.EOF:
                break

            lexer._output += token.text

        return lexer._output


    # @Test public void testWildcardStillWorks() throws Exception {
    #     ErrorQueue equeue = new ErrorQueue();
    #     ErrorManager.setErrorListener(equeue);
    #     String grammar =
    #     "parser grammar S;\n" +
    #     "a : B . C ;\n"; // not qualified ID
    #     Grammar g = new Grammar(grammar);
    #     assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
    #     }


    def testDelegatorInvokesDelegateRule(self):
        slave = textwrap.dedent(
        r'''
        parser grammar S1;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM1.capture(t)

        }

        a : B { self.capture("S.a") } ;
        ''')

        master = textwrap.dedent(
        r'''
        grammar M1;
        options {
            language=Python;
        }
        import S1;
        s : a ;
        B : 'b' ; // defines B from inherited token space
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execParser(
            master, 's',
            slaves=[slave],
            input="b"
            )

        self.failUnlessEqual("S.a", found)


        # @Test public void testDelegatorInvokesDelegateRuleWithReturnStruct() throws Exception {
        #     // must generate something like:
        #          // public int a(int x) throws RecognitionException { return gS.a(x); }
        #        // in M.
        #        String slave =
        #        "parser grammar S;\n" +
        #        "a : B {System.out.print(\"S.a\");} ;\n";
        #        mkdir(tmpdir);
        #        writeFile(tmpdir, "S.g", slave);
        #        String master =
        #        "grammar M;\n" +
        #        "import S;\n" +
        #        "s : a {System.out.println($a.text);} ;\n" +
        #        "B : 'b' ;" + // defines B from inherited token space
        #        "WS : (' '|'\\n') {skip();} ;\n" ;
        #        String found = execParser("M.g", master, "MParser", "MLexer",
        #                                    "s", "b", debug);
        #        assertEquals("S.ab\n", found);
        #        }


    def testDelegatorInvokesDelegateRuleWithArgs(self):
        slave = textwrap.dedent(
        r'''
        parser grammar S2;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM2.capture(t)
        }
        a[x] returns [y] : B {self.capture("S.a"); $y="1000";} ;
        ''')

        master = textwrap.dedent(
        r'''
        grammar M2;
        options {
            language=Python;
        }
        import S2;
        s : label=a[3] {self.capture($label.y);} ;
        B : 'b' ; // defines B from inherited token space
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execParser(
            master, 's',
            slaves=[slave],
            input="b"
            )

        self.failUnlessEqual("S.a1000", found)


    def testDelegatorAccessesDelegateMembers(self):
        slave = textwrap.dedent(
        r'''
        parser grammar S3;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM3.capture(t)

            def foo(self):
                self.capture("foo")
        }
        a : B ;
        ''')

        master = textwrap.dedent(
        r'''
        grammar M3;        // uses no rules from the import
        options {
            language=Python;
        }
        import S3;
        s : 'b' {self.gS3.foo();} ; // gS is import pointer
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execParser(
            master, 's',
            slaves=[slave],
            input="b"
            )

        self.failUnlessEqual("foo", found)


    def testDelegatorInvokesFirstVersionOfDelegateRule(self):
        slave = textwrap.dedent(
        r'''
        parser grammar S4;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM4.capture(t)
        }
        a : b {self.capture("S.a");} ;
        b : B ;
        ''')

        slave2 = textwrap.dedent(
        r'''
        parser grammar T4;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM4.capture(t)
        }
        a : B {self.capture("T.a");} ; // hidden by S.a
        ''')

        master = textwrap.dedent(
        r'''
        grammar M4;
        options {
            language=Python;
        }
        import S4,T4;
        s : a ;
        B : 'b' ;
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execParser(
            master, 's',
            slaves=[slave, slave2],
            input="b"
            )

        self.failUnlessEqual("S.a", found)


    def testDelegatesSeeSameTokenType(self):
        slave = textwrap.dedent(
        r'''
        parser grammar S5; // A, B, C token type order
        options {
            language=Python;
        }
        tokens { A; B; C; }
        @members {
            def capture(self, t):
                self.gM5.capture(t)
        }
        x : A {self.capture("S.x ");} ;
        ''')

        slave2 = textwrap.dedent(
        r'''
        parser grammar T5;
        options {
            language=Python;
        }
        tokens { C; B; A; } /// reverse order
        @members {
            def capture(self, t):
                self.gM5.capture(t)
        }
        y : A {self.capture("T.y");} ;
        ''')

        master = textwrap.dedent(
        r'''
        grammar M5;
        options {
            language=Python;
        }
        import S5,T5;
        s : x y ; // matches AA, which should be "aa"
        B : 'b' ; // another order: B, A, C
        A : 'a' ;
        C : 'c' ;
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execParser(
            master, 's',
            slaves=[slave, slave2],
            input="aa"
            )

        self.failUnlessEqual("S.x T.y", found)


        # @Test public void testDelegatesSeeSameTokenType2() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar S;\n" + // A, B, C token type order
        #                 "tokens { A; B; C; }\n" +
        #                 "x : A {System.out.println(\"S.x\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String slave2 =
        #                 "parser grammar T;\n" +
        #                 "tokens { C; B; A; }\n" + // reverse order
        #                 "y : A {System.out.println(\"T.y\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "T.g", slave2);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S,T;\n" +
        #                 "s : x y ;\n" + // matches AA, which should be "aa"
        #                 "B : 'b' ;\n" + // another order: B, A, C
        #                 "A : 'a' ;\n" +
        #                 "C : 'c' ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         String expectedTokenIDToTypeMap = "[A=4, B=5, C=6, WS=7]";
        #         String expectedStringLiteralToTypeMap = "{}";
        #         String expectedTypeToTokenList = "[A, B, C, WS]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, g.composite.stringLiteralToTypeMap.toString());
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
        # }

        # @Test public void testCombinedImportsCombined() throws Exception {
        #         // for now, we don't allow combined to import combined
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "grammar S;\n" + // A, B, C token type order
        #                 "tokens { A; B; C; }\n" +
        #                 "x : 'x' INT {System.out.println(\"S.x\");} ;\n" +
        #                 "INT : '0'..'9'+ ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "s : x INT ;\n";
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         assertEquals("unexpected errors: "+equeue, 1, equeue.errors.size());
        #         String expectedError = "error(161): "+tmpdir.toString().replaceFirst("\\-[0-9]+","")+"/M.g:2:8: combined grammar M cannot import combined grammar S";
        #         assertEquals("unexpected errors: "+equeue, expectedError, equeue.errors.get(0).toString().replaceFirst("\\-[0-9]+",""));
        # }

        # @Test public void testSameStringTwoNames() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 "tokens { A='a'; }\n" +
        #                 "x : A {System.out.println(\"S.x\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String slave2 =
        #                 "parser grammar T;\n" +
        #                 "tokens { X='a'; }\n" +
        #                 "y : X {System.out.println(\"T.y\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "T.g", slave2);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S,T;\n" +
        #                 "s : x y ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         String expectedTokenIDToTypeMap = "[A=4, WS=6, X=5]";
        #         String expectedStringLiteralToTypeMap = "{'a'=4}";
        #         String expectedTypeToTokenList = "[A, X, WS]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, g.composite.stringLiteralToTypeMap.toString());
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         Object expectedArg = "X='a'";
        #         Object expectedArg2 = "A";
        #         int expectedMsgID = ErrorManager.MSG_TOKEN_ALIAS_CONFLICT;
        #         GrammarSemanticsMessage expectedMessage =
        #                 new GrammarSemanticsMessage(expectedMsgID, g, null, expectedArg, expectedArg2);
        #         checkGrammarSemanticsError(equeue, expectedMessage);

        #         assertEquals("unexpected errors: "+equeue, 1, equeue.errors.size());

        #         String expectedError =
        #                 "error(158): T.g:2:10: cannot alias X='a'; string already assigned to A";
        #         assertEquals(expectedError, equeue.errors.get(0).toString());
        # }

        # @Test public void testSameNameTwoStrings() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 "tokens { A='a'; }\n" +
        #                 "x : A {System.out.println(\"S.x\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String slave2 =
        #                 "parser grammar T;\n" +
        #                 "tokens { A='x'; }\n" +
        #                 "y : A {System.out.println(\"T.y\");} ;\n";
                
        #         writeFile(tmpdir, "T.g", slave2);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S,T;\n" +
        #                 "s : x y ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         String expectedTokenIDToTypeMap = "[A=4, T__6=6, WS=5]";
        #         String expectedStringLiteralToTypeMap = "{'a'=4, 'x'=6}";
        #         String expectedTypeToTokenList = "[A, WS, T__6]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, sortMapToString(g.composite.stringLiteralToTypeMap));
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         Object expectedArg = "A='x'";
        #         Object expectedArg2 = "'a'";
        #         int expectedMsgID = ErrorManager.MSG_TOKEN_ALIAS_REASSIGNMENT;
        #         GrammarSemanticsMessage expectedMessage =
        #                 new GrammarSemanticsMessage(expectedMsgID, g, null, expectedArg, expectedArg2);
        #         checkGrammarSemanticsError(equeue, expectedMessage);

        #         assertEquals("unexpected errors: "+equeue, 1, equeue.errors.size());

        #         String expectedError =
        #                 "error(159): T.g:2:10: cannot alias A='x'; token name already assigned to 'a'";
        #         assertEquals(expectedError, equeue.errors.get(0).toString());
        # }

        # @Test public void testImportedTokenVocabIgnoredWithWarning() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 "options {tokenVocab=whatever;}\n" +
        #                 "tokens { A='a'; }\n" +
        #                 "x : A {System.out.println(\"S.x\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "s : x ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         Object expectedArg = "S";
        #         int expectedMsgID = ErrorManager.MSG_TOKEN_VOCAB_IN_DELEGATE;
        #         GrammarSemanticsMessage expectedMessage =
        #                 new GrammarSemanticsMessage(expectedMsgID, g, null, expectedArg);
        #         checkGrammarSemanticsWarning(equeue, expectedMessage);

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
        #         assertEquals("unexpected errors: "+equeue, 1, equeue.warnings.size());

        #         String expectedError =
        #                 "warning(160): S.g:2:10: tokenVocab option ignored in imported grammar S";
        #         assertEquals(expectedError, equeue.warnings.get(0).toString());
        # }

        # @Test public void testImportedTokenVocabWorksInRoot() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 "tokens { A='a'; }\n" +
        #                 "x : A {System.out.println(\"S.x\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);

        #         String tokens =
        #                 "A=99\n";
        #         writeFile(tmpdir, "Test.tokens", tokens);

        #         String master =
        #                 "grammar M;\n" +
        #                 "options {tokenVocab=Test;}\n" +
        #                 "import S;\n" +
        #                 "s : x ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         String expectedTokenIDToTypeMap = "[A=99, WS=101]";
        #         String expectedStringLiteralToTypeMap = "{'a'=100}";
        #         String expectedTypeToTokenList = "[A, 'a', WS]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, g.composite.stringLiteralToTypeMap.toString());
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
        # }

        # @Test public void testSyntaxErrorsInImportsNotThrownOut() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 "options {toke\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "s : x ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         // whole bunch of errors from bad S.g file
        #         assertEquals("unexpected errors: "+equeue, 5, equeue.errors.size());
        # }

        # @Test public void testSyntaxErrorsInImportsNotThrownOut2() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 ": A {System.out.println(\"S.x\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "s : x ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();

        #         // whole bunch of errors from bad S.g file
        #         assertEquals("unexpected errors: "+equeue, 3, equeue.errors.size());
        # }


    def testDelegatorRuleOverridesDelegate(self):
        slave = textwrap.dedent(
        r'''
        parser grammar S6;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM6.capture(t)
        }
        a : b {self.capture("S.a");} ;
        b : B ;
        ''')

        master = textwrap.dedent(
        r'''
        grammar M6;
        options {
            language=Python;
        }
        import S6;
        b : 'b'|'c' ;
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execParser(
            master, 'a',
            slaves=[slave],
            input="c"
            )

        self.failUnlessEqual("S.a", found)


    #     @Test public void testDelegatorRuleOverridesLookaheadInDelegate() throws Exception {
    #             String slave =
    #                     "parser grammar JavaDecl;\n" +
    #                     "type : 'int' ;\n" +
    #                     "decl : type ID ';'\n" +
    #                     "     | type ID init ';' {System.out.println(\"JavaDecl: \"+$decl.text);}\n" +
    #                     "     ;\n" +
    #                     "init : '=' INT ;\n" ;
    #             mkdir(tmpdir);
    #             writeFile(tmpdir, "JavaDecl.g", slave);
    #             String master =
    #                     "grammar Java;\n" +
    #                     "import JavaDecl;\n" +
    #                     "prog : decl ;\n" +
    #                     "type : 'int' | 'float' ;\n" +
    #                     "\n" +
    #                     "ID  : 'a'..'z'+ ;\n" +
    #                     "INT : '0'..'9'+ ;\n" +
    #                     "WS : (' '|'\\n') {skip();} ;\n" ;
    #             // for float to work in decl, type must be overridden
    #             String found = execParser("Java.g", master, "JavaParser", "JavaLexer",
    #                                                               "prog", "float x = 3;", debug);
    #             assertEquals("JavaDecl: floatx=3;\n", found);
    #     }

    # @Test public void testDelegatorRuleOverridesDelegates() throws Exception {
    #     String slave =
    #         "parser grammar S;\n" +
    #         "a : b {System.out.println(\"S.a\");} ;\n" +
    #         "b : B ;\n" ;
    #     mkdir(tmpdir);
    #     writeFile(tmpdir, "S.g", slave);

    #     String slave2 =
    #         "parser grammar T;\n" +
    #         "tokens { A='x'; }\n" +
    #         "b : B {System.out.println(\"T.b\");} ;\n";
    #     writeFile(tmpdir, "T.g", slave2);

    #     String master =
    #         "grammar M;\n" +
    #         "import S, T;\n" +
    #         "b : 'b'|'c' {System.out.println(\"M.b\");}|B|A ;\n" +
    #         "WS : (' '|'\\n') {skip();} ;\n" ;
    #     String found = execParser("M.g", master, "MParser", "MLexer",
    #                               "a", "c", debug);
    #     assertEquals("M.b\n" +
    #                  "S.a\n", found);
    # }

    # LEXER INHERITANCE

    def testLexerDelegatorInvokesDelegateRule(self):
        slave = textwrap.dedent(
        r'''
        lexer grammar S7;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM7.capture(t)
        }
        A : 'a' {self.capture("S.A ");} ;
        C : 'c' ;
        ''')

        master = textwrap.dedent(
        r'''
        lexer grammar M7;
        options {
            language=Python;
        }
        import S7;
        B : 'b' ;
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execLexer(
            master,
            slaves=[slave],
            input="abc"
            )

        self.failUnlessEqual("S.A abc", found)


    def testLexerDelegatorRuleOverridesDelegate(self):
        slave = textwrap.dedent(
        r'''
        lexer grammar S8;
        options {
            language=Python;
        }
        @members {
            def capture(self, t):
                self.gM8.capture(t)
        }
        A : 'a' {self.capture("S.A")} ;
        ''')

        master = textwrap.dedent(
        r'''
        lexer grammar M8;
        options {
            language=Python;
        }
        import S8;
        A : 'a' {self.capture("M.A ");} ;
        WS : (' '|'\n') {self.skip()} ;
        ''')

        found = self.execLexer(
            master,
            slaves=[slave],
            input="a"
            )

        self.failUnlessEqual("M.A a", found)

        # @Test public void testLexerDelegatorRuleOverridesDelegateLeavingNoRules() throws Exception {
        #         // M.Tokens has nothing to predict tokens from S.  Should
        #         // not include S.Tokens alt in this case?
        #         String slave =
        #                 "lexer grammar S;\n" +
        #                 "A : 'a' {System.out.println(\"S.A\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String master =
        #                 "lexer grammar M;\n" +
        #                 "import S;\n" +
        #                 "A : 'a' {System.out.println(\"M.A\");} ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         writeFile(tmpdir, "/M.g", master);

        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         composite.assignTokenTypes();
        #         composite.defineGrammarSymbols();
        #         composite.createNFAs();
        #         g.createLookaheadDFAs(false);

        #         // predict only alts from M not S
        #         String expectingDFA =
        #                 ".s0-'a'->.s1\n" +
        #                 ".s0-{'\\n', ' '}->:s3=>2\n" +
        #                 ".s1-<EOT>->:s2=>1\n";
        #         org.antlr.analysis.DFA dfa = g.getLookaheadDFA(1);
        #         FASerializer serializer = new FASerializer(g);
        #         String result = serializer.serialize(dfa.startState);
        #         assertEquals(expectingDFA, result);

        #         // must not be a "unreachable alt: Tokens" error
        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
        # }

        # @Test public void testInvalidImportMechanism() throws Exception {
        #         // M.Tokens has nothing to predict tokens from S.  Should
        #         // not include S.Tokens alt in this case?
        #         String slave =
        #                 "lexer grammar S;\n" +
        #                 "A : 'a' {System.out.println(\"S.A\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String master =
        #                 "tree grammar M;\n" +
        #                 "import S;\n" +
        #                 "a : A ;";
        #         writeFile(tmpdir, "/M.g", master);

        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();

        #         assertEquals("unexpected errors: "+equeue, 1, equeue.errors.size());
        #         assertEquals("unexpected errors: "+equeue, 0, equeue.warnings.size());

        #         String expectedError =
        #                 "error(161): "+tmpdir.toString().replaceFirst("\\-[0-9]+","")+"/M.g:2:8: tree grammar M cannot import lexer grammar S";
        #         assertEquals(expectedError, equeue.errors.get(0).toString().replaceFirst("\\-[0-9]+",""));
        # }

        # @Test public void testSyntacticPredicateRulesAreNotInherited() throws Exception {
        #         // if this compiles, it means that synpred1_S is defined in S.java
        #         // but not MParser.java.  MParser has its own synpred1_M which must
        #         // be separate to compile.
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 "a : 'a' {System.out.println(\"S.a1\");}\n" +
        #                 "  | 'a' {System.out.println(\"S.a2\");}\n" +
        #                 "  ;\n" +
        #                 "b : 'x' | 'y' {;} ;\n"; // preds generated but not need in DFA here
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String master =
        #                 "grammar M;\n" +
        #                 "options {backtrack=true;}\n" +
        #                 "import S;\n" +
        #                 "start : a b ;\n" +
        #                 "nonsense : 'q' | 'q' {;} ;" + // forces def of preds here in M
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         String found = execParser("M.g", master, "MParser", "MLexer",
        #                                                           "start", "ax", debug);
        #         assertEquals("S.a1\n", found);
        # }

        # @Test public void testKeywordVSIDGivesNoWarning() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "lexer grammar S;\n" +
        #                 "A : 'abc' {System.out.println(\"S.A\");} ;\n" +
        #                 "ID : 'a'..'z'+ ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "a : A {System.out.println(\"M.a\");} ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         String found = execParser("M.g", master, "MParser", "MLexer",
        #                                                           "a", "abc", debug);

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
        #         assertEquals("unexpected warnings: "+equeue, 0, equeue.warnings.size());

        #         assertEquals("S.A\nM.a\n", found);
        # }

        # @Test public void testWarningForUndefinedToken() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "lexer grammar S;\n" +
        #                 "A : 'abc' {System.out.println(\"S.A\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "a : ABC A {System.out.println(\"M.a\");} ;\n" +
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         // A is defined in S but M should still see it and not give warning.
        #         // only problem is ABC.

        #         rawGenerateAndBuildRecognizer("M.g", master, "MParser", "MLexer", debug);

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
        #         assertEquals("unexpected warnings: "+equeue, 1, equeue.warnings.size());

        #         String expectedError =
        #                 "warning(105): "+tmpdir.toString().replaceFirst("\\-[0-9]+","")+"/M.g:3:5: no lexer rule corresponding to token: ABC";
        #         assertEquals(expectedError, equeue.warnings.get(0).toString().replaceFirst("\\-[0-9]+",""));
        # }

        # /** Make sure that M can import S that imports T. */
        # @Test public void test3LevelImport() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar T;\n" +
        #                 "a : T ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "T.g", slave);
        #         String slave2 =
        #                 "parser grammar S;\n" + // A, B, C token type order
        #                 "import T;\n" +
        #                 "a : S ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave2);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "a : M ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();
        #         g.composite.defineGrammarSymbols();

        #         String expectedTokenIDToTypeMap = "[M=6, S=5, T=4]";
        #         String expectedStringLiteralToTypeMap = "{}";
        #         String expectedTypeToTokenList = "[T, S, M]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, g.composite.stringLiteralToTypeMap.toString());
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());

        #         boolean ok =
        #                 rawGenerateAndBuildRecognizer("M.g", master, "MParser", null, false);
        #         boolean expecting = true; // should be ok
        #         assertEquals(expecting, ok);
        # }

        # @Test public void testBigTreeOfImports() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar T;\n" +
        #                 "x : T ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "T.g", slave);
        #         slave =
        #                 "parser grammar S;\n" +
        #                 "import T;\n" +
        #                 "y : S ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);

        #         slave =
        #                 "parser grammar C;\n" +
        #                 "i : C ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "C.g", slave);
        #         slave =
        #                 "parser grammar B;\n" +
        #                 "j : B ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "B.g", slave);
        #         slave =
        #                 "parser grammar A;\n" +
        #                 "import B,C;\n" +
        #                 "k : A ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "A.g", slave);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S,A;\n" +
        #                 "a : M ;\n" ;
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();
        #         g.composite.defineGrammarSymbols();

        #         String expectedTokenIDToTypeMap = "[A=8, B=6, C=7, M=9, S=5, T=4]";
        #         String expectedStringLiteralToTypeMap = "{}";
        #         String expectedTypeToTokenList = "[T, S, B, C, A, M]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, g.composite.stringLiteralToTypeMap.toString());
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());

        #         boolean ok =
        #                 rawGenerateAndBuildRecognizer("M.g", master, "MParser", null, false);
        #         boolean expecting = true; // should be ok
        #         assertEquals(expecting, ok);
        # }

        # @Test public void testRulesVisibleThroughMultilevelImport() throws Exception {
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String slave =
        #                 "parser grammar T;\n" +
        #                 "x : T ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "T.g", slave);
        #         String slave2 =
        #                 "parser grammar S;\n" + // A, B, C token type order
        #                 "import T;\n" +
        #                 "a : S ;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave2);

        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "a : M x ;\n" ; // x MUST BE VISIBLE TO M
        #         writeFile(tmpdir, "M.g", master);
        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/M.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();
        #         g.composite.defineGrammarSymbols();

        #         String expectedTokenIDToTypeMap = "[M=6, S=5, T=4]";
        #         String expectedStringLiteralToTypeMap = "{}";
        #         String expectedTypeToTokenList = "[T, S, M]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, g.composite.stringLiteralToTypeMap.toString());
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());
        # }

        # @Test public void testNestedComposite() throws Exception {
        #         // Wasn't compiling. http://www.antlr.org/jira/browse/ANTLR-438
        #         ErrorQueue equeue = new ErrorQueue();
        #         ErrorManager.setErrorListener(equeue);
        #         String gstr =
        #                 "lexer grammar L;\n" +
        #                 "T1: '1';\n" +
        #                 "T2: '2';\n" +
        #                 "T3: '3';\n" +
        #                 "T4: '4';\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "L.g", gstr);
        #         gstr =
        #                 "parser grammar G1;\n" +
        #                 "s: a | b;\n" +
        #                 "a: T1;\n" +
        #                 "b: T2;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "G1.g", gstr);

        #         gstr =
        #                 "parser grammar G2;\n" +
        #                 "import G1;\n" +
        #                 "a: T3;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "G2.g", gstr);
        #         String G3str =
        #                 "grammar G3;\n" +
        #                 "import G2;\n" +
        #                 "b: T4;\n" ;
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "G3.g", G3str);

        #         Tool antlr = newTool(new String[] {"-lib", tmpdir});
        #         CompositeGrammar composite = new CompositeGrammar();
        #         Grammar g = new Grammar(antlr,tmpdir+"/G3.g",composite);
        #         composite.setDelegationRoot(g);
        #         g.parseAndBuildAST();
        #         g.composite.assignTokenTypes();
        #         g.composite.defineGrammarSymbols();

        #         String expectedTokenIDToTypeMap = "[T1=4, T2=5, T3=6, T4=7]";
        #         String expectedStringLiteralToTypeMap = "{}";
        #         String expectedTypeToTokenList = "[T1, T2, T3, T4]";

        #         assertEquals(expectedTokenIDToTypeMap,
        #                                  realElements(g.composite.tokenIDToTypeMap).toString());
        #         assertEquals(expectedStringLiteralToTypeMap, g.composite.stringLiteralToTypeMap.toString());
        #         assertEquals(expectedTypeToTokenList,
        #                                  realElements(g.composite.typeToTokenList).toString());

        #         assertEquals("unexpected errors: "+equeue, 0, equeue.errors.size());

        #         boolean ok =
        #                 rawGenerateAndBuildRecognizer("G3.g", G3str, "G3Parser", null, false);
        #         boolean expecting = true; // should be ok
        #         assertEquals(expecting, ok);
        # }

        # @Test public void testHeadersPropogatedCorrectlyToImportedGrammars() throws Exception {
        #         String slave =
        #                 "parser grammar S;\n" +
        #                 "a : B {System.out.print(\"S.a\");} ;\n";
        #         mkdir(tmpdir);
        #         writeFile(tmpdir, "S.g", slave);
        #         String master =
        #                 "grammar M;\n" +
        #                 "import S;\n" +
        #                 "@header{package mypackage;}\n" +
        #                 "@lexer::header{package mypackage;}\n" +
        #                 "s : a ;\n" +
        #                 "B : 'b' ;" + // defines B from inherited token space
        #                 "WS : (' '|'\\n') {skip();} ;\n" ;
        #         boolean ok = antlr("M.g", "M.g", master, debug);
        #         boolean expecting = true; // should be ok
        #         assertEquals(expecting, ok);
        # }


if __name__ == '__main__':
    unittest.main()
