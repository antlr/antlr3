import antlr3
import testbase
import unittest

class t009lexer(testbase.ANTLRTest):
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
        stream = antlr3.StringStream('085')
        lexer = self.getLexer(stream)

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.DIGIT)
        self.assertEqual(token.start, 0)
        self.assertEqual(token.stop, 0)
        self.assertEqual(token.text, '0')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.DIGIT)
        self.assertEqual(token.start, 1)
        self.assertEqual(token.stop, 1)
        self.assertEqual(token.text, '8')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.DIGIT)
        self.assertEqual(token.start, 2)
        self.assertEqual(token.stop, 2)
        self.assertEqual(token.text, '5')

        token = lexer.nextToken()
        self.assertEqual(token.type, self.lexerModule.EOF)


    def testMalformedInput(self):
        stream = antlr3.StringStream('2a')
        lexer = self.getLexer(stream)

        lexer.nextToken()
        try:
            token = lexer.nextToken()
            self.fail(token)

        except antlr3.MismatchedSetException as exc:
            # TODO: This should provide more useful information
            self.assertIsNone(exc.expecting)
            self.assertEqual(exc.unexpectedType, 'a')
            self.assertEqual(exc.charPositionInLine, 1)
            self.assertEqual(exc.line, 1)


if __name__ == '__main__':
    unittest.main()
