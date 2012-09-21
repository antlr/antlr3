import antlr3
import testbase
import unittest
import os
import sys
from io import StringIO

class t018llstar(testbase.ANTLRTest):
    def setUp(self):
        self.compileGrammar()
        

    def testValid(self):
        inputPath = os.path.splitext(__file__)[0] + '.input'
        with open(inputPath) as f:
            cStream = antlr3.StringStream(f.read())
        lexer = self.getLexer(cStream)
        tStream = antlr3.CommonTokenStream(lexer)
        parser = self.getParser(tStream)
        parser.program()

        output = parser.output.getvalue()

        outputPath = os.path.splitext(__file__)[0] + '.output'
        with open(outputPath) as f:
            testOutput = f.read()

        self.assertEqual(output, testOutput)

if __name__ == '__main__':
    unittest.main()
