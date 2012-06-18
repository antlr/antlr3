import antlr3
import testbase
import unittest

class t006lexer(testbase.ANTLRTest):
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
        stream = antlr3.StringStream('fofaaooa')
        lexer = self.getLexer(stream)

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 0)
        self.assertEqual(token.stop, 1)
        self.assertEqual(token.text, 'fo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 2)
        self.assertEqual(token.stop, 7)
        self.assertEqual(token.text, 'faaooa')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.EOF)


    def testMalformedInput(self):
        stream = antlr3.StringStream('fofoaooaoa2')
        lexer = self.getLexer(stream)

        lexer.nextToken()
        lexer.nextToken()
        try:
            token = lexer.nextToken()
            self.fail(token)

        except antlr3.MismatchedTokenException as exc:
            self.assertEqual(exc.expecting, 'f')
            self.assertEqual(exc.unexpectedType, '2')
            self.assertEqual(exc.charPositionInLine, 10)
            self.assertEqual(exc.line, 1)
            

if __name__ == '__main__':
    unittest.main()
