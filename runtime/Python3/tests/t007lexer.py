import antlr3
import testbase
import unittest

class t007lexer(testbase.ANTLRTest):
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
        stream = antlr3.StringStream('fofababbooabb')
        lexer = self.getLexer(stream)

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 0)
        self.assertEqual(token.stop, 1)
        self.assertEqual(token.text, 'fo')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.FOO)
        self.assertEqual(token.start, 2)
        self.assertEqual(token.stop, 12)
        self.assertEqual(token.text, 'fababbooabb')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.EOF)


    def testMalformedInput(self):
        stream = antlr3.StringStream('foaboao')
        lexer = self.getLexer(stream)

        try:
            token = lexer.nextToken()
            self.fail(token)

        except antlr3.EarlyExitException as exc:
            self.assertEqual(exc.unexpectedType, 'o')
            self.assertEqual(exc.charPositionInLine, 6)
            self.assertEqual(exc.line, 1)
            

if __name__ == '__main__':
    unittest.main()

