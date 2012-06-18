import antlr3
import testbase
import unittest

class t011lexer(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar()
        
        
    def lexerClass(self, base):
        class TLexer(base):
            def emitErrorMessage(self, msg):
                # report errors to /dev/null
                pass

            def reportError(self, re):
                # no error recovery yet, just crash!
                raise re

        return TLexer
    
        
    def testValid(self):
        stream = antlr3.StringStream('foobar _Ab98 \n A12sdf')
        lexer = self.getLexer(stream)

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.IDENTIFIER)
        self.assertEqual(token.start, 0)
        self.assertEqual(token.stop, 5)
        self.assertEqual(token.text, 'foobar')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.WS)
        self.assertEqual(token.start, 6)
        self.assertEqual(token.stop, 6)
        self.assertEqual(token.text, ' ')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.IDENTIFIER)
        self.assertEqual(token.start, 7)
        self.assertEqual(token.stop, 11)
        self.assertEqual(token.text, '_Ab98')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.WS)
        self.assertEqual(token.start, 12)
        self.assertEqual(token.stop, 14)
        self.assertEqual(token.text, ' \n ')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.IDENTIFIER)
        self.assertEqual(token.start, 15)
        self.assertEqual(token.stop, 20)
        self.assertEqual(token.text, 'A12sdf')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.EOF)


    def testMalformedInput(self):
        stream = antlr3.StringStream('a-b')
        lexer = self.getLexer(stream)

        lexer.nextToken()
        try:
            token = lexer.nextToken()
            self.fail(token)

        except antlr3.NoViableAltException as exc:
            self.assertEqual(exc.unexpectedType, '-')
            self.assertEqual(exc.charPositionInLine, 1)
            self.assertEqual(exc.line, 1)

            

if __name__ == '__main__':
    unittest.main()
