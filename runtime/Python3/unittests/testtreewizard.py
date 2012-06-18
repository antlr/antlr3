
from io import StringIO
import os
import unittest

from antlr3.tree import CommonTreeAdaptor, CommonTree, INVALID_TOKEN_TYPE
from antlr3.treewizard import TreeWizard, computeTokenTypes, \
     TreePatternLexer, EOF, ID, BEGIN, END, PERCENT, COLON, DOT, ARG, \
     TreePatternParser, \
     TreePattern, WildcardTreePattern, TreePatternTreeAdaptor


class TestComputeTokenTypes(unittest.TestCase):
    """Test case for the computeTokenTypes function."""

    def testNone(self):
        """computeTokenTypes(None) -> {}"""

        typeMap = computeTokenTypes(None)
        self.assertIsInstance(typeMap, dict)
        self.assertEqual(typeMap, {})


    def testList(self):
        """computeTokenTypes(['a', 'b']) -> { 'a': 0, 'b': 1 }"""

        typeMap = computeTokenTypes(['a', 'b'])
        self.assertIsInstance(typeMap, dict)
        self.assertEqual(typeMap, { 'a': 0, 'b': 1 })


class TestTreePatternLexer(unittest.TestCase):
    """Test case for the TreePatternLexer class."""

    def testBegin(self):
        """TreePatternLexer(): '('"""

        lexer = TreePatternLexer('(')
        type = lexer.nextToken()
        self.assertEqual(type, BEGIN)
        self.assertEqual(lexer.sval, '')
        self.assertFalse(lexer.error)


    def testEnd(self):
        """TreePatternLexer(): ')'"""

        lexer = TreePatternLexer(')')
        type = lexer.nextToken()
        self.assertEqual(type, END)
        self.assertEqual(lexer.sval, '')
        self.assertFalse(lexer.error)


    def testPercent(self):
        """TreePatternLexer(): '%'"""

        lexer = TreePatternLexer('%')
        type = lexer.nextToken()
        self.assertEqual(type, PERCENT)
        self.assertEqual(lexer.sval, '')
        self.assertFalse(lexer.error)


    def testDot(self):
        """TreePatternLexer(): '.'"""

        lexer = TreePatternLexer('.')
        type = lexer.nextToken()
        self.assertEqual(type, DOT)
        self.assertEqual(lexer.sval, '')
        self.assertFalse(lexer.error)


    def testColon(self):
        """TreePatternLexer(): ':'"""

        lexer = TreePatternLexer(':')
        type = lexer.nextToken()
        self.assertEqual(type, COLON)
        self.assertEqual(lexer.sval, '')
        self.assertFalse(lexer.error)


    def testEOF(self):
        """TreePatternLexer(): EOF"""

        lexer = TreePatternLexer('  \n \r \t ')
        type = lexer.nextToken()
        self.assertEqual(type, EOF)
        self.assertEqual(lexer.sval, '')
        self.assertFalse(lexer.error)


    def testID(self):
        """TreePatternLexer(): ID"""

        lexer = TreePatternLexer('_foo12_bar')
        type = lexer.nextToken()
        self.assertEqual(type, ID)
        self.assertEqual(lexer.sval, '_foo12_bar')
        self.assertFalse(lexer.error)


    def testARG(self):
        """TreePatternLexer(): ARG"""

        lexer = TreePatternLexer(r'[ \]bla\n]')
        type = lexer.nextToken()
        self.assertEqual(type, ARG)
        self.assertEqual(lexer.sval, r' ]bla\n')
        self.assertFalse(lexer.error)


    def testError(self):
        """TreePatternLexer(): error"""

        lexer = TreePatternLexer('1')
        type = lexer.nextToken()
        self.assertEqual(type, EOF)
        self.assertEqual(lexer.sval, '')
        self.assertTrue(lexer.error)


class TestTreePatternParser(unittest.TestCase):
    """Test case for the TreePatternParser class."""

    def setUp(self):
        """Setup text fixure

        We need a tree adaptor, use CommonTreeAdaptor.
        And a constant list of token names.

        """

        self.adaptor = CommonTreeAdaptor()
        self.tokens = [
            "", "", "", "", "", "A", "B", "C", "D", "E", "ID", "VAR"
            ]
        self.wizard = TreeWizard(self.adaptor, tokenNames=self.tokens)


    def testSingleNode(self):
        """TreePatternParser: 'ID'"""
        lexer = TreePatternLexer('ID')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsInstance(tree, CommonTree)
        self.assertEqual(tree.getType(), 10)
        self.assertEqual(tree.getText(), 'ID')


    def testSingleNodeWithArg(self):
        """TreePatternParser: 'ID[foo]'"""
        lexer = TreePatternLexer('ID[foo]')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsInstance(tree, CommonTree)
        self.assertEqual(tree.getType(), 10)
        self.assertEqual(tree.getText(), 'foo')


    def testSingleLevelTree(self):
        """TreePatternParser: '(A B)'"""
        lexer = TreePatternLexer('(A B)')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsInstance(tree, CommonTree)
        self.assertEqual(tree.getType(), 5)
        self.assertEqual(tree.getText(), 'A')
        self.assertEqual(tree.getChildCount(), 1)
        self.assertEqual(tree.getChild(0).getType(), 6)
        self.assertEqual(tree.getChild(0).getText(), 'B')


    def testNil(self):
        """TreePatternParser: 'nil'"""
        lexer = TreePatternLexer('nil')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsInstance(tree, CommonTree)
        self.assertEqual(tree.getType(), 0)
        self.assertIsNone(tree.getText())


    def testWildcard(self):
        """TreePatternParser: '(.)'"""
        lexer = TreePatternLexer('(.)')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsInstance(tree, WildcardTreePattern)


    def testLabel(self):
        """TreePatternParser: '(%a:A)'"""
        lexer = TreePatternLexer('(%a:A)')
        parser = TreePatternParser(lexer, self.wizard, TreePatternTreeAdaptor())
        tree = parser.pattern()
        self.assertIsInstance(tree, TreePattern)
        self.assertEqual(tree.label, 'a')


    def testError1(self):
        """TreePatternParser: ')'"""
        lexer = TreePatternLexer(')')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsNone(tree)


    def testError2(self):
        """TreePatternParser: '()'"""
        lexer = TreePatternLexer('()')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsNone(tree)


    def testError3(self):
        """TreePatternParser: '(A ])'"""
        lexer = TreePatternLexer('(A ])')
        parser = TreePatternParser(lexer, self.wizard, self.adaptor)
        tree = parser.pattern()
        self.assertIsNone(tree)


class TestTreeWizard(unittest.TestCase):
    """Test case for the TreeWizard class."""

    def setUp(self):
        """Setup text fixure

        We need a tree adaptor, use CommonTreeAdaptor.
        And a constant list of token names.

        """

        self.adaptor = CommonTreeAdaptor()
        self.tokens = [
            "", "", "", "", "", "A", "B", "C", "D", "E", "ID", "VAR"
            ]


    def testInit(self):
        """TreeWizard.__init__()"""

        wiz = TreeWizard(
            self.adaptor,
            tokenNames=['a', 'b']
            )

        self.assertIs(wiz.adaptor, self.adaptor)
        self.assertEqual(
            wiz.tokenNameToTypeMap,
            { 'a': 0, 'b': 1 }
            )


    def testGetTokenType(self):
        """TreeWizard.getTokenType()"""

        wiz = TreeWizard(
            self.adaptor,
            tokenNames=self.tokens
            )

        self.assertEqual(
            wiz.getTokenType('A'),
            5
            )

        self.assertEqual(
            wiz.getTokenType('VAR'),
            11
            )

        self.assertEqual(
            wiz.getTokenType('invalid'),
            INVALID_TOKEN_TYPE
            )

    def testSingleNode(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("ID")
        found = t.toStringTree()
        expecting = "ID"
        self.assertEqual(expecting, found)


    def testSingleNodeWithArg(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("ID[foo]")
        found = t.toStringTree()
        expecting = "foo"
        self.assertEqual(expecting, found)


    def testSingleNodeTree(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A)")
        found = t.toStringTree()
        expecting = "A"
        self.assertEqual(expecting, found)


    def testSingleLevelTree(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C D)")
        found = t.toStringTree()
        expecting = "(A B C D)"
        self.assertEqual(expecting, found)


    def testListTree(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(nil A B C)")
        found = t.toStringTree()
        expecting = "A B C"
        self.assertEqual(expecting, found)


    def testInvalidListTree(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("A B C")
        self.assertIsNone(t)


    def testDoubleLevelTree(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A (B C) (B D) E)")
        found = t.toStringTree()
        expecting = "(A (B C) (B D) E)"
        self.assertEqual(expecting, found)


    def __simplifyIndexMap(self, indexMap):
        return dict( # stringify nodes for easy comparing
            (ttype, [str(node) for node in nodes])
            for ttype, nodes in indexMap.items()
            )

    def testSingleNodeIndex(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("ID")
        indexMap = wiz.index(tree)
        found = self.__simplifyIndexMap(indexMap)
        expecting = { 10: ["ID"] }
        self.assertEqual(expecting, found)


    def testNoRepeatsIndex(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B C D)")
        indexMap = wiz.index(tree)
        found = self.__simplifyIndexMap(indexMap)
        expecting = { 8:['D'], 6:['B'], 7:['C'], 5:['A'] }
        self.assertEqual(expecting, found)


    def testRepeatsIndex(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B (A C B) B D D)")
        indexMap = wiz.index(tree)
        found = self.__simplifyIndexMap(indexMap)
        expecting = { 8: ['D', 'D'], 6: ['B', 'B', 'B'], 7: ['C'], 5: ['A', 'A'] }
        self.assertEqual(expecting, found)


    def testNoRepeatsVisit(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B C D)")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(str(node))

        wiz.visit(tree, wiz.getTokenType("B"), visitor)

        expecting = ['B']
        self.assertEqual(expecting, elements)


    def testNoRepeatsVisit2(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B (A C B) B D D)")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(str(node))

        wiz.visit(tree, wiz.getTokenType("C"), visitor)

        expecting = ['C']
        self.assertEqual(expecting, elements)


    def testRepeatsVisit(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B (A C B) B D D)")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(str(node))

        wiz.visit(tree, wiz.getTokenType("B"), visitor)

        expecting = ['B', 'B', 'B']
        self.assertEqual(expecting, elements)


    def testRepeatsVisit2(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B (A C B) B D D)")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(str(node))

        wiz.visit(tree, wiz.getTokenType("A"), visitor)

        expecting = ['A', 'A']
        self.assertEqual(expecting, elements)


    def testRepeatsVisitWithContext(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B (A C B) B D D)")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append('{}@{}[{}]'.format(node, parent, childIndex))

        wiz.visit(tree, wiz.getTokenType("B"), visitor)

        expecting = ['B@A[0]', 'B@A[1]', 'B@A[2]']
        self.assertEqual(expecting, elements)


    def testRepeatsVisitWithNullParentAndContext(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B (A C B) B D D)")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(
                '{}@{}[{}]'.format(
                    node, parent or 'nil', childIndex)
                )

        wiz.visit(tree, wiz.getTokenType("A"), visitor)

        expecting = ['A@nil[0]', 'A@A[1]']
        self.assertEqual(expecting, elements)


    def testVisitPattern(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B C (A B) D)")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(
                str(node)
                )

        wiz.visit(tree, '(A B)', visitor)

        expecting = ['A'] # shouldn't match overall root, just (A B)
        self.assertEqual(expecting, elements)


    def testVisitPatternMultiple(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B C (A B) (D (A B)))")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(
                '{}@{}[{}]'.format(node, parent or 'nil', childIndex)
                )

        wiz.visit(tree, '(A B)', visitor)

        expecting = ['A@A[2]', 'A@D[0]']
        self.assertEqual(expecting, elements)


    def testVisitPatternMultipleWithLabels(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        tree = wiz.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")

        elements = []
        def visitor(node, parent, childIndex, labels):
            elements.append(
                '{}@{}[{}]{}&{}'.format(
                    node,
                    parent or 'nil',
                    childIndex,
                    labels['a'],
                    labels['b'],
                    )
                )

        wiz.visit(tree, '(%a:A %b:B)', visitor)

        expecting = ['foo@A[2]foo&bar', 'big@D[0]big&dog']
        self.assertEqual(expecting, elements)


    def testParse(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C)")
        valid = wiz.parse(t, "(A B C)")
        self.assertTrue(valid)


    def testParseSingleNode(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("A")
        valid = wiz.parse(t, "A")
        self.assertTrue(valid)


    def testParseSingleNodeFails(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("A")
        valid = wiz.parse(t, "B")
        self.assertFalse(valid)


    def testParseFlatTree(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(nil A B C)")
        valid = wiz.parse(t, "(nil A B C)")
        self.assertTrue(valid)


    def testParseFlatTreeFails(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(nil A B C)")
        valid = wiz.parse(t, "(nil A B)")
        self.assertFalse(valid)


    def testParseFlatTreeFails2(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(nil A B C)")
        valid = wiz.parse(t, "(nil A B A)")
        self.assertFalse(valid)


    def testWildcard(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C)")
        valid = wiz.parse(t, "(A . .)")
        self.assertTrue(valid)


    def testParseWithText(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B[foo] C[bar])")
        # C pattern has no text arg so despite [bar] in t, no need
        # to match text--check structure only.
        valid = wiz.parse(t, "(A B[foo] C)")
        self.assertTrue(valid)


    def testParseWithText2(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B[T__32] (C (D E[a])))")
        # C pattern has no text arg so despite [bar] in t, no need
        # to match text--check structure only.
        valid = wiz.parse(t, "(A B[foo] C)")
        self.assertEqual("(A T__32 (C (D a)))", t.toStringTree())


    def testParseWithTextFails(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C)")
        valid = wiz.parse(t, "(A[foo] B C)")
        self.assertFalse(valid) # fails


    def testParseLabels(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C)")
        labels = {}
        valid = wiz.parse(t, "(%a:A %b:B %c:C)", labels)
        self.assertTrue(valid)
        self.assertEqual("A", str(labels["a"]))
        self.assertEqual("B", str(labels["b"]))
        self.assertEqual("C", str(labels["c"]))


    def testParseWithWildcardLabels(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C)")
        labels = {}
        valid = wiz.parse(t, "(A %b:. %c:.)", labels)
        self.assertTrue(valid)
        self.assertEqual("B", str(labels["b"]))
        self.assertEqual("C", str(labels["c"]))


    def testParseLabelsAndTestText(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B[foo] C)")
        labels = {}
        valid = wiz.parse(t, "(%a:A %b:B[foo] %c:C)", labels)
        self.assertTrue(valid)
        self.assertEqual("A", str(labels["a"]))
        self.assertEqual("foo", str(labels["b"]))
        self.assertEqual("C", str(labels["c"]))


    def testParseLabelsInNestedTree(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A (B C) (D E))")
        labels = {}
        valid = wiz.parse(t, "(%a:A (%b:B %c:C) (%d:D %e:E) )", labels)
        self.assertTrue(valid)
        self.assertEqual("A", str(labels["a"]))
        self.assertEqual("B", str(labels["b"]))
        self.assertEqual("C", str(labels["c"]))
        self.assertEqual("D", str(labels["d"]))
        self.assertEqual("E", str(labels["e"]))


    def testEquals(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t1 = wiz.create("(A B C)")
        t2 = wiz.create("(A B C)")
        same = wiz.equals(t1, t2)
        self.assertTrue(same)


    def testEqualsWithText(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t1 = wiz.create("(A B[foo] C)")
        t2 = wiz.create("(A B[foo] C)")
        same = wiz.equals(t1, t2)
        self.assertTrue(same)


    def testEqualsWithMismatchedText(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t1 = wiz.create("(A B[foo] C)")
        t2 = wiz.create("(A B C)")
        same = wiz.equals(t1, t2)
        self.assertFalse(same)


    def testEqualsWithMismatchedList(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t1 = wiz.create("(A B C)")
        t2 = wiz.create("(A B A)")
        same = wiz.equals(t1, t2)
        self.assertFalse(same)


    def testEqualsWithMismatchedListLength(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t1 = wiz.create("(A B C)")
        t2 = wiz.create("(A B)")
        same = wiz.equals(t1, t2)
        self.assertFalse(same)


    def testFindPattern(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")
        subtrees = wiz.find(t, "(A B)")
        found = [str(node) for node in subtrees]
        expecting = ['foo', 'big']
        self.assertEqual(expecting, found)


    def testFindTokenType(self):
        wiz = TreeWizard(self.adaptor, self.tokens)
        t = wiz.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")
        subtrees = wiz.find(t, wiz.getTokenType('A'))
        found = [str(node) for node in subtrees]
        expecting = ['A', 'foo', 'big']
        self.assertEqual(expecting, found)



if __name__ == "__main__":
    unittest.main(testRunner=unittest.TextTestRunner(verbosity=2))
