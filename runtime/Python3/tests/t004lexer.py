import antlr3
import testbase
import unittest

class t004lexer(testbase.ANTLRTest):
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
        stream = antlr3.StringStream('ffofoofooo')
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
        self.assertEqual(token.text, 'fo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 3)
        self.assertEqual(token.stop, 5)
        self.assertEqual(token.text, 'foo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 6)
        self.assertEqual(token.stop, 9)
        self.assertEqual(token.text, 'fooo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.EOF)
        

    def testMalformedInput(self):
        stream = antlr3.StringStream('2')
        lexer = self.getLexer(stream)

        try:
            token = lexer.nextToken()
            self.fail()

        except antlr3.MismatchedTokenException as exc:
            self.assertEqual(exc.expecting, 'f')
            self.assertEqual(exc.unexpectedType, '2')
            

if __name__ == '__main__':
    unittest.main()

