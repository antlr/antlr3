import antlr3
import testbase
import unittest

class t005lexer(testbase.ANTLRTest):
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
        stream = antlr3.StringStream('fofoofooo')
        lexer = self.getLexer(stream)

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 0)
        self.assertEqual(token.stop, 1)
        self.assertEqual(token.text, 'fo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 2)
        self.assertEqual(token.stop, 4)
        self.assertEqual(token.text, 'foo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 5)
        self.assertEqual(token.stop, 8)
        self.assertEqual(token.text, 'fooo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.EOF)
        

    def testMalformedInput1(self):
        stream = antlr3.StringStream('2')
        lexer = self.getLexer(stream)

        try:
            token = lexer.nextToken()
            self.fail()

        except antlr3.MismatchedTokenException as exc:
            self.assertEqual(exc.expecting, 'f')
            self.assertEqual(exc.unexpectedType, '2')


    def testMalformedInput2(self):
        stream = antlr3.StringStream('f')
        lexer = self.getLexer(stream)

        try:
            token = lexer.nextToken()
            self.fail()

        except antlr3.EarlyExitException as exc:
            self.assertEqual(exc.unexpectedType, antlr3.EOF)
            

if __name__ == '__main__':
    unittest.main()
