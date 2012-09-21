import os
import sys
import antlr3
import testbase
import unittest
from io import StringIO

class t020fuzzy(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar('t020fuzzyLexer.g')
        

    def testValid(self):
        inputPath = os.path.splitext(__file__)[0] + '.input'
        with open(inputPath) as f:
            stream = antlr3.StringStream(f.read())
        lexer = self.getLexer(stream)

        while True:
            token = lexer.nextToken()
            if token.type == antlr3.EOF:
                break


        output = lexer.output.getvalue()

        outputPath = os.path.splitext(__file__)[0] + '.output'
        with open(outputPath) as f:
            testOutput = f.read()

        self.assertEqual(output, testOutput)


if __name__ == '__main__':
    unittest.main()
