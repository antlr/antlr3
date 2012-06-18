import antlr3
import testbase
import unittest
import os
import sys
from io import StringIO
import textwrap

class t012lexerXML(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar('t012lexerXMLLexer.g')
        
        
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
        inputPath = os.path.splitext(__file__)[0] + '.input'
        with open(inputPath) as f:
            data = f.read()
        stream = antlr3.StringStream(data)
        lexer = self.getLexer(stream)

        while True:
            token = lexer.nextToken()
            if token.type == self.lexerModule.EOF:
                break


        output = lexer.outbuf.getvalue()

        outputPath = os.path.splitext(__file__)[0] + '.output'

        with open(outputPath) as f:
            testOutput = f.read()

        self.assertEqual(output, testOutput)


    def testMalformedInput1(self):
        input = textwrap.dedent("""\
        <?xml version='1.0'?>
        <document d>
        </document>
        """)

        stream = antlr3.StringStream(input)
        lexer = self.getLexer(stream)

        try:
            while True:
                token = lexer.nextToken()
                # Should raise NoViableAltException before hitting EOF
                if token.type == antlr3.EOF:
                    self.fail()

        except antlr3.NoViableAltException as exc:
            self.assertEqual(exc.unexpectedType, '>')
            self.assertEqual(exc.charPositionInLine, 11)
            self.assertEqual(exc.line, 2)


    def testMalformedInput2(self):
        input = textwrap.dedent("""\
        <?tml version='1.0'?>
        <document>
        </document>
        """)

        stream = antlr3.StringStream(input)
        lexer = self.getLexer(stream)

        try:
            while True:
                token = lexer.nextToken()
                # Should raise NoViableAltException before hitting EOF
                if token.type == antlr3.EOF:
                    self.fail()

        except antlr3.MismatchedSetException as exc:
            self.assertEqual(exc.unexpectedType, 't')
            self.assertEqual(exc.charPositionInLine, 2)
            self.assertEqual(exc.line, 1)


    def testMalformedInput3(self):
        input = textwrap.dedent("""\
        <?xml version='1.0'?>
        <docu ment attr="foo">
        </document>
        """)

        stream = antlr3.StringStream(input)
        lexer = self.getLexer(stream)

        try:
            while True:
                token = lexer.nextToken()
                # Should raise NoViableAltException before hitting EOF
                if token.type == antlr3.EOF:
                    self.fail()

        except antlr3.NoViableAltException as exc:
            self.assertEqual(exc.unexpectedType, 'a')
            self.assertEqual(exc.charPositionInLine, 11)
            self.assertEqual(exc.line, 2)

            
if __name__ == '__main__':
    unittest.main()
