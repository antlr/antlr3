import antlr3
import testbase
import unittest
import textwrap


class t022scopes(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar()
        

    def parserClass(self, base):
        class TParser(base):
            def emitErrorMessage(self, msg):
                # report errors to /dev/null
                pass

            def reportError(self, re):
                # no error recovery yet, just crash!
                raise re

        return TParser

        
    def testa1(self):
        cStream = antlr3.StringStream('foobar')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        parser.a()
        

    def testb1(self):
        cStream = antlr3.StringStream('foobar')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)

        self.assertRaises(antlr3.RecognitionException, parser.b, False)
        

    def testb2(self):
        cStream = antlr3.StringStream('foobar')
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        parser.b(True)
        

    def testc1(self):
        cStream = antlr3.StringStream(
            textwrap.dedent('''\
            {
                int i;
                int j;
                i = 0;
            }
            '''))

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        symbols = parser.c()

        self.assertEqual(
            symbols,
            set(['i', 'j'])
            )
        

    def testc2(self):
        cStream = antlr3.StringStream(
            textwrap.dedent('''\
            {
                int i;
                int j;
                i = 0;
                x = 4;
            }
            '''))

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)

        self.assertRaisesRegex(RuntimeError, r'x', parser.c)


    def testd1(self):
        cStream = antlr3.StringStream(
            textwrap.dedent('''\
            {
                int i;
                int j;
                i = 0;
                {
                    int i;
                    int x;
                    x = 5;
                }
            }
            '''))

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        symbols = parser.d()

        self.assertEqual(
            symbols,
            set(['i', 'j'])
            )


    def teste1(self):
        cStream = antlr3.StringStream(
            textwrap.dedent('''\
            { { { { 12 } } } }
            '''))

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        res = parser.e()

        self.assertEqual(res, 12)


    def testf1(self):
        cStream = antlr3.StringStream(
            textwrap.dedent('''\
            { { { { 12 } } } }
            '''))

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        res = parser.f()

        self.assertIsNone(res)


    def testf2(self):
        cStream = antlr3.StringStream(
            textwrap.dedent('''\
            { { 12 } }
            '''))

        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        res = parser.f()

        self.assertIsNone(res)



if __name__ == '__main__':
    unittest.main()
