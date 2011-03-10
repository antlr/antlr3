#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'antlr3/tree/wizard'
require 'test/unit'
require 'spec'

include ANTLR3
include ANTLR3::AST

class TestPatternLexer < Test::Unit::TestCase
  
  # vvvvvvvv tests vvvvvvvvv
  
  def test_open
    lexer = Wizard::PatternLexer.new( '(' )
    type = lexer.next_token
    assert_equal( type, :open )
    assert_equal( lexer.text, '' )
    assert_equal( lexer.error, false )
  end
  
  def test_close
    lexer = Wizard::PatternLexer.new(')')
    type = lexer.next_token
    assert_equal(type, :close)
    assert_equal(lexer.text, '')
    assert_equal(lexer.error, false)
  end
  
  def test_percent
    lexer = Wizard::PatternLexer.new('%')
    type = lexer.next_token
    assert_equal(type, :percent)
    assert_equal(lexer.text, '')
    assert_equal(lexer.error, false)
  end
  
  def test_dot
    lexer = Wizard::PatternLexer.new('.')
    type = lexer.next_token
    assert_equal(type, :dot)
    assert_equal(lexer.text, '')
    assert_equal(lexer.error, false)
  end
  
  def test_eof
    lexer = Wizard::PatternLexer.new(" \n \r \t ")
    type = lexer.next_token
    assert_equal(type, EOF)
    assert_equal(lexer.text, '')
    assert_equal(lexer.error, false)
  end
  
  def test_id
    lexer = Wizard::PatternLexer.new('__whatever_1__')
    type = lexer.next_token
    assert_equal(:identifier, type)
    assert_equal('__whatever_1__', lexer.text)
    assert( !(lexer.error) )
  end
  
  def test_arg
    lexer = Wizard::PatternLexer.new('[ \]bla\n]')
    type = lexer.next_token
    assert_equal(type, :argument)
    assert_equal(' ]bla\n', lexer.text)
    assert( !(lexer.error) )
  end
  
  def test_error
    lexer = Wizard::PatternLexer.new("1")
    type = lexer.next_token
    assert_equal(type, EOF)
    assert_equal(lexer.text, '')
    assert_equal(lexer.error, true)
  end
  
end


class TestPatternParser < Test::Unit::TestCase
  Tokens = TokenScheme.build %w(A B C D E ID VAR)
  include Tokens
  
  def setup
    @adaptor = CommonTreeAdaptor.new( Tokens.token_class )
    @pattern_adaptor = Wizard::PatternAdaptor.new( Tokens.token_class )
    @wizard = Wizard.new( :adaptor => @adaptor, :token_scheme => Tokens )
  end
  
  # vvvvvvvv tests vvvvvvvvv
  def test_single_node
    tree = Wizard::PatternParser.parse( 'ID', Tokens, @adaptor )
    
    assert_instance_of(CommonTree, tree)
    assert_equal( ID, tree.type )
    assert_equal( 'ID', tree.text )
  end
  
  def test_single_node_with_arg
    tree = Wizard::PatternParser.parse( 'ID[foo]', Tokens, @adaptor )
    
    assert_instance_of( CommonTree, tree )
    assert_equal( ID, tree.type )
    assert_equal( 'foo', tree.text )
  end
  
  def test_single_level_tree
    tree = Wizard::PatternParser.parse( '(A B)', Tokens, @adaptor )
    
    assert_instance_of( CommonTree, tree )
    assert_equal(A, tree.type)
    assert_equal('A', tree.text)
    assert_equal(tree.child_count, 1)
    assert_equal(tree.child(0).type, B)
    assert_equal(tree.child(0).text, 'B')
  end
  
  def test_nil
    tree = Wizard::PatternParser.parse( 'nil', Tokens, @adaptor )
    
    assert_instance_of(CommonTree, tree)
    assert_equal(0, tree.type)
    assert_nil tree.text
  end
  
  def test_wildcard
    tree = Wizard::PatternParser.parse( '(.)', Tokens, @adaptor )
    assert_instance_of( Wizard::WildcardPattern, tree )
  end
  
  def test_label
    tree = Wizard::PatternParser.parse( '(%a:A)', Tokens, @pattern_adaptor )
    assert_instance_of(Wizard::Pattern, tree)
    assert_equal('a', tree.label)
  end
  
  def test_error_1
    tree = Wizard::PatternParser.parse( ')', Tokens, @adaptor )
    assert_nil tree
  end
  
  def test_error_2
    tree = Wizard::PatternParser.parse( '()', Tokens, @adaptor )
    assert_nil tree
  end
  
  def test_error_3
    tree = Wizard::PatternParser.parse( '(A ])', Tokens, @adaptor )
    assert_nil tree
  end
  
end


class TestTreeWizard < Test::Unit::TestCase
  Tokens = TokenScheme.build %w(A B C D E ID VAR)
  include Tokens

  def setup
    @adaptor = CommonTreeAdaptor.new( Tokens.token_class )
    @wizard = Wizard.new( :adaptor => @adaptor, :token_scheme => Tokens )
  end
  
  def create_wizard( tokens )
    Wizard.new( :tokens => tokens )
  end
  
  # vvvvvvvv tests vvvvvvvvv
  def test_init
    @wizard = Wizard.new( :tokens => %w(A B), :adaptor => @adaptor )
    
    assert_equal( @wizard.adaptor, @adaptor )
    assert_kind_of( ANTLR3::TokenScheme, @wizard.token_scheme )
  end
  
  def test_single_node
    t = @wizard.create("ID")
    assert_equal(t.inspect, 'ID')
  end
  
  def test_single_node_with_arg
    t = @wizard.create("ID[foo]")
    
    assert_equal(t.inspect, 'foo')
  end
  
  def test_single_node_tree
    t = @wizard.create("(A)")
    assert_equal(t.inspect, 'A')
  end
  
  def test_single_level_tree
    t = @wizard.create("(A B C D)")
    assert_equal(t.inspect, '(A B C D)')
  end
  
  def test_list_tree
    t = @wizard.create("(nil A B C)")
    assert_equal(t.inspect, 'A B C')
  end
  
  def test_invalid_list_tree
    t = @wizard.create("A B C")
    assert_nil t
  end
  
  def test_double_level_tree
    t = @wizard.create("(A (B C) (B D) E)")
    assert_equal(t.inspect, "(A (B C) (B D) E)")
  end
  
  SIMPLIFY_MAP = lambda do |imap|
    Hash[
      imap.map { |type, nodes| [type, nodes.map { |n| n.to_s }] }
    ]
  end
  
  def test_single_node_index
    tree = @wizard.create("ID")
    index_map = SIMPLIFY_MAP[@wizard.index(tree)]
    
    assert_equal(index_map, ID => %w(ID))
  end
  
  
  def test_no_repeats_index
    tree = @wizard.create("(A B C D)")
    index_map = SIMPLIFY_MAP[@wizard.index(tree)]
    
    assert_equal(index_map,
        D => %w(D), B => %w(B),
        C => %w(C), A => %w(A)
    )
  end
  
  def test_repeats_index
    tree = @wizard.create("(A B (A C B) B D D)")
    index_map = SIMPLIFY_MAP[@wizard.index(tree)]
    
    assert_equal(index_map,
        D => %w(D D), B => %w(B B B),
        C => %w(C), A => %w(A A)
    )
  end
  
  
  def test_no_repeats_visit
    tree = @wizard.create("(A B C D)")
    
    elements = []
    @wizard.visit( tree, B ) do |node, parent, child_index, labels|
      elements << node.to_s
    end
    
    assert_equal( %w(B), elements )
  end
  
  
  def test_no_repeats_visit2
    tree = @wizard.create("(A B (A C B) B D D)")
    
    elements = []
    @wizard.visit( tree, C ) do |node, parent, child_index, labels|
      elements << node.to_s
    end
    
    assert_equal(%w(C), elements)
  end
  
  
  def test_repeats_visit
    tree = @wizard.create("(A B (A C B) B D D)")
    
    elements = []
    @wizard.visit( tree, B ) do |node, parent, child_index, labels|
      elements << node.to_s
    end
    
    assert_equal(%w(B B B), elements)
  end
  
  
  def test_repeats_visit2
    tree = @wizard.create("(A B (A C B) B D D)")
    
    elements = []
    @wizard.visit( tree, A ) do |node, parent, child_index, labels|
      elements << node.to_s
    end
    
    assert_equal(%w(A A), elements)
  end
  
  def context(node, parent, index)
    '%s@%s[%d]' % [node.to_s, (parent || 'nil').to_s, index]
  end
  
  def test_repeats_visit_with_context
    tree = @wizard.create("(A B (A C B) B D D)")
    
    elements = []
    @wizard.visit( tree, B ) do |node, parent, child_index, labels|
      elements << context(node, parent, child_index)
    end
    
    assert_equal(['B@A[0]', 'B@A[1]', 'B@A[2]'], elements)
  end
  
  
  def test_repeats_visit_with_null_parent_and_context
    tree = @wizard.create("(A B (A C B) B D D)")
    
    elements = []
    @wizard.visit( tree, A ) do |node, parent, child_index, labels|
      elements << context(node, parent, child_index)
    end
    
    assert_equal(['A@nil[-1]', 'A@A[1]'], elements)
  end
  
  def test_visit_pattern
    tree = @wizard.create("(A B C (A B) D)")
    
    elements = []
    @wizard.visit(tree, '(A B)') do |node, parent, child_index, labels|
      elements << node.to_s
    end
    
    assert_equal(%w(A), elements)
  end
  
  
  def test_visit_pattern_multiple
    tree = @wizard.create("(A B C (A B) (D (A B)))")
    
    elements = []
    @wizard.visit(tree, '(A B)') do |node, parent, child_index, labels|
      elements << context(node, parent, child_index)
    end
    
    assert_equal( %w(A@A[2] A@D[0]) , elements )
  end
  
  def labeled_context(node, parent, index, labels, *names)
    suffix = names.map { |n| labels[n].to_s }.join('&')
    '%s@%s[%d]%s' % [node.to_s, (parent || 'nil').to_s, index, suffix]
  end
    
  def test_visit_pattern_multiple_with_labels
    tree = @wizard.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")
    
    elements = []
    @wizard.visit(tree, '(%a:A %b:B)') do |node, parent, child_index, labels|
      elements << labeled_context(node, parent, child_index, labels, 'a', 'b')
    end
    
    assert_equal( ['foo@A[2]foo&bar', 'big@D[0]big&dog'] , elements )
  end
  
  
  def test_match
    tree = @wizard.create("(A B C)")
    assert @wizard.match(tree, "(A B C)")
  end
  
  def test_match_single_node
    tree = @wizard.create('A')
    assert @wizard.match(tree, 'A')
  end
  
  def test_match_single_node_fails
    tree = @wizard.create('A')
    assert( !(@wizard.match(tree, 'B')) )
  end
  
  
  def test_match_flat_tree
    tree = @wizard.create('(nil A B C)')
    assert @wizard.match(tree, '(nil A B C)')
  end
  
  def test_match_flat_tree_fails
    tree = @wizard.create('(nil A B C)')
    assert( !(@wizard.match(tree, '(nil A B)')) )
  end

  def test_match_flat_tree_fails2
    tree = @wizard.create('(nil A B C)')
    assert( !(@wizard.match(tree, '(nil A B A)')) )
  end
  
  def test_wildcard
    tree = @wizard.create('(A B C)')
    assert @wizard.match(tree, '(A . .)')
  end
  
  def test_match_with_text
    tree = @wizard.create('(A B[foo] C[bar])')
    assert @wizard.match(tree, '(A B[foo] C)')
  end
  
  def test_match_with_text_fails
    tree = @wizard.create('(A B C)')
    assert( !(@wizard.match(tree, '(A[foo] B C)')) )
  end
  
  def test_match_labels
    tree = @wizard.create('(A B C)')
    labels = @wizard.match( tree, '(%a:A %b:B %c:C)' )
    
    assert_equal('A', labels['a'].to_s)
    assert_equal('B', labels['b'].to_s)
    assert_equal('C', labels['c'].to_s)
  end
  
  def test_match_with_wildcard_labels
    tree = @wizard.create('(A B C)')
    labels = @wizard.match(tree, '(A %b:. %c:.)')
    assert_kind_of( Hash, labels )
    assert_equal('B', labels['b'].to_s)
    assert_equal('C', labels['c'].to_s)
  end
  
  
  def test_match_labels_and_test_text
    tree = @wizard.create('(A B[foo] C)')
    labels = @wizard.match( tree, '(%a:A %b:B[foo] %c:C)' )
    assert_kind_of( Hash, labels )
    assert_equal('A', labels['a'].to_s)
    assert_equal('foo', labels['b'].to_s)
    assert_equal('C', labels['c'].to_s)
  end
  
  def test_match_labels_in_nested_tree
    tree = @wizard.create('(A (B C) (D E))')
    labels = @wizard.match( tree, '(%a:A (%b:B %c:C) (%d:D %e:E))' )
    assert_kind_of( Hash, labels )
    assert_equal('A', labels['a'].to_s)
    assert_equal('B', labels['b'].to_s)
    assert_equal('C', labels['c'].to_s)
    assert_equal('D', labels['d'].to_s)
    assert_equal('E', labels['e'].to_s)
  end
  
  
  def test_equals
    tree1 = @wizard.create("(A B C)")
    tree2 = @wizard.create("(A B C)")
    assert @wizard.equals(tree1, tree2)
  end
  
  
  def test_equals_with_text
    tree1 = @wizard.create("(A B[foo] C)")
    tree2 = @wizard.create("(A B[foo] C)")
    assert @wizard.equals(tree1, tree2)
  end
  
  
  def test_equals_with_mismatched_text
    tree1 = @wizard.create("(A B[foo] C)")
    tree2 = @wizard.create("(A B C)")
    assert( !(@wizard.equals(tree1, tree2)) )
  end
  
  
  def test_equals_with_mismatched_list
    tree1 = @wizard.create("(A B C)")
    tree2 = @wizard.create("(A B A)")
    assert( !(@wizard.equals(tree1, tree2)) )
  end
  
  def test_equals_with_mismatched_list_length
    tree1 = @wizard.create("(A B C)")
    tree2 = @wizard.create("(A B)")
    assert( !(@wizard.equals(tree1, tree2)) )
  end
  
  def test_find_pattern
    tree = @wizard.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")
    subtrees = @wizard.find(tree, "(A B)").map { |t| t.to_s }
    assert_equal(%w(foo big), subtrees)
  end
  
  def test_find_token_type
    tree = @wizard.create("(A B C (A[foo] B[bar]) (D (A[big] B[dog])))")
    subtrees = @wizard.find( tree, A ).map { |t| t.to_s }
    assert_equal(%w(A foo big), subtrees)
  end
end

