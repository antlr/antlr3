
import unittest
import textwrap
import antlr3
import antlr3.tree
import testbase
import sys
from io import StringIO

class T(testbase.ANTLRTest):
    def setUp(self):
        self.oldPath = sys.path[:]
        sys.path.insert(0, self.baseDir)


    def tearDown(self):
        sys.path = self.oldPath


    def testOverrideMain(self):
        grammar = textwrap.dedent(
            r"""lexer grammar T3;
            options {
              language = Python3;
              }

            @main {
            def main(argv):
                raise RuntimeError("no")
            }

            ID: ('a'..'z' | '\u00c0'..'\u00ff')+;
            WS: ' '+ { $channel = HIDDEN };
            """)


        stdout = StringIO()

        lexerMod = self.compileInlineGrammar(grammar, returnModule=True)
        self.assertRaises(RuntimeError, lexerMod.main, ['lexer.py'])


    def testLexerFromFile(self):
        input = "foo bar"
        inputPath = self.writeFile("input.txt", input)

        grammar = textwrap.dedent(
            r"""lexer grammar T1;
            options {
              language = Python3;
              }

            ID: 'a'..'z'+;
            WS: ' '+ { $channel = HIDDEN };
            """)


        stdout = StringIO()

        lexerMod = self.compileInlineGrammar(grammar, returnModule=True)
        lexerMod.main(
            ['lexer.py', inputPath],
            stdout=stdout
            )

        self.assertEqual(len(stdout.getvalue().splitlines()), 3)


    def testLexerFromStdIO(self):
        input = "foo bar"

        grammar = textwrap.dedent(
            r"""lexer grammar T2;
            options {
              language = Python3;
              }

            ID: 'a'..'z'+;
            WS: ' '+ { $channel = HIDDEN };
            """)


        stdout = StringIO()

        lexerMod = self.compileInlineGrammar(grammar, returnModule=True)
        lexerMod.main(
            ['lexer.py'],
            stdin=StringIO(input),
            stdout=stdout
            )

        self.assertEqual(len(stdout.getvalue().splitlines()), 3)


    def testLexerEncoding(self):
        input = "föö bär"

        grammar = textwrap.dedent(
            r"""lexer grammar T3;
            options {
              language = Python3;
              }

            ID: ('a'..'z' | '\u00c0'..'\u00ff')+;
            WS: ' '+ { $channel = HIDDEN };
            """)


        stdout = StringIO()

        lexerMod = self.compileInlineGrammar(grammar, returnModule=True)
        lexerMod.main(
            ['lexer.py'],
            stdin=StringIO(input),
            stdout=stdout
            )

        self.assertEqual(len(stdout.getvalue().splitlines()), 3)


    def testCombined(self):
        input = "foo bar"

        grammar = textwrap.dedent(
            r"""grammar T4;
            options {
              language = Python3;
              }

            r returns [res]: (ID)+ EOF { $res = $text };

            ID: 'a'..'z'+;
            WS: ' '+ { $channel = HIDDEN };
            """)


        stdout = StringIO()

        lexerMod, parserMod = self.compileInlineGrammar(grammar, returnModule=True)
        parserMod.main(
            ['combined.py', '--rule', 'r'],
            stdin=StringIO(input),
            stdout=stdout
            )

        stdout = stdout.getvalue()
        self.assertEqual(len(stdout.splitlines()), 1, stdout)


    def testCombinedOutputAST(self):
        input = "foo + bar"

        grammar = textwrap.dedent(
            r"""grammar T5;
            options {
              language = Python3;
              output = AST;
            }

            r: ID OP^ ID EOF!;

            ID: 'a'..'z'+;
            OP: '+';
            WS: ' '+ { $channel = HIDDEN };
            """)


        stdout = StringIO()

        lexerMod, parserMod = self.compileInlineGrammar(grammar, returnModule=True)
        parserMod.main(
            ['combined.py', '--rule', 'r'],
            stdin=StringIO(input),
            stdout=stdout
            )

        stdout = stdout.getvalue().strip()
        self.assertEqual(stdout, "(+ foo bar)")


    def testTreeParser(self):
        grammar = textwrap.dedent(
            r'''grammar T6;
            options {
              language = Python3;
              output = AST;
            }

            r: ID OP^ ID EOF!;

            ID: 'a'..'z'+;
            OP: '+';
            WS: ' '+ { $channel = HIDDEN };
            ''')

        treeGrammar = textwrap.dedent(
            r'''tree grammar T6Walker;
            options {
            language=Python3;
            ASTLabelType=CommonTree;
            tokenVocab=T6;
            }
            r returns [res]: ^(OP a=ID b=ID)
              { $res = "{} {} {}".format($a.text, $OP.text, $b.text) }
              ;
            ''')

        lexerMod, parserMod = self.compileInlineGrammar(grammar, returnModule=True)
        walkerMod = self.compileInlineGrammar(treeGrammar, returnModule=True)

        stdout = StringIO()
        walkerMod.main(
            ['walker.py', '--rule', 'r', '--parser', 'T6Parser', '--parser-rule', 'r', '--lexer', 'T6Lexer'],
            stdin=StringIO("a+b"),
            stdout=stdout
            )

        stdout = stdout.getvalue().strip()
        self.assertEqual(stdout, "'a + b'")


    def testTreeParserRewrite(self):
        grammar = textwrap.dedent(
            r'''grammar T7;
            options {
              language = Python3;
              output = AST;
            }

            r: ID OP^ ID EOF!;

            ID: 'a'..'z'+;
            OP: '+';
            WS: ' '+ { $channel = HIDDEN };
            ''')

        treeGrammar = textwrap.dedent(
            r'''tree grammar T7Walker;
            options {
              language=Python3;
              ASTLabelType=CommonTree;
              tokenVocab=T7;
              output=AST;
            }
            tokens {
              ARG;
            }
            r: ^(OP a=ID b=ID) -> ^(OP ^(ARG ID) ^(ARG ID));
            ''')

        lexerMod, parserMod = self.compileInlineGrammar(grammar, returnModule=True)
        walkerMod = self.compileInlineGrammar(treeGrammar, returnModule=True)

        stdout = StringIO()
        walkerMod.main(
            ['walker.py', '--rule', 'r', '--parser', 'T7Parser', '--parser-rule', 'r', '--lexer', 'T7Lexer'],
            stdin=StringIO("a+b"),
            stdout=stdout
            )

        stdout = stdout.getvalue().strip()
        self.assertEqual(stdout, "(+ (ARG a) (ARG b))")



    def testGrammarImport(self):
        slave = textwrap.dedent(
            r'''
            parser grammar T8S;
            options {
              language=Python3;
            }

            a : B;
            ''')

        parserName = self.writeInlineGrammar(slave)[0]
        # slave parsers are imported as normal python modules
        # to force reloading current version, purge module from sys.modules
        if parserName + 'Parser' in sys.modules:
            del sys.modules[parserName+'Parser']

        master = textwrap.dedent(
            r'''
            grammar T8M;
            options {
              language=Python3;
            }
            import T8S;
            s returns [res]: a { $res = $a.text };
            B : 'b' ; // defines B from inherited token space
            WS : (' '|'\n') {self.skip()} ;
            ''')

        stdout = StringIO()

        lexerMod, parserMod = self.compileInlineGrammar(master, returnModule=True)
        parserMod.main(
            ['import.py', '--rule', 's'],
            stdin=StringIO("b"),
            stdout=stdout
            )

        stdout = stdout.getvalue().strip()
        self.assertEqual(stdout, "'b'")


if __name__ == '__main__':
    unittest.main()
