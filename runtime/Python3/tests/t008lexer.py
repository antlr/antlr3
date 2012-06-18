import antlr3
import testbase
import unittest

class t008lexer(testbase.ANTLRTest):
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
        stream = antlr3.StringStream('ffaf')
        lexer = self.getLexer(stream)

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 0)
        self.assertEqual(token.stop, 0)
        self.assertEqual(token.text, 'f')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 1)
        self.assertEqual(token.stop, 2)
        self.assertEqual(token.text, 'fa')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 3)
        self.assertEqual(token.stop, 3)
        self.assertEqual(token.text, 'f')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.EOF)


    def testMalformedInput(self):
        stream = antlr3.StringStream('fafb')
        lexer = self.getLexer(stream)

        lexer.nextToken()
        lexer.nextToken()
        try:
            token = lexer.nextToken()
            self.fail(token)

        except antlr3.MismatchedTokenException as exc:
            self.assertEqual(exc.unexpectedType, 'b')
            self.assertEqual(exc.charPositionInLine, 3)
            self.assertEqual(exc.line, 1)
            

if __name__ == '__main__':
    unittest.main()
