#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'
require 'test/unit'
require 'spec'

include ANTLR3
include ANTLR3::AST

class TestTreeNodeStream < Test::Unit::TestCase
  def setup
    @adaptor = CommonTreeAdaptor.new
  end
  
  def new_stream(t)
    CommonTreeNodeStream.new(t)
  end
  
  def test_single_node
    t = CommonTree.new(CommonToken.new { |t| t.type = 101 })
    stream = new_stream(t)
    expecting = '101'
    
    found = nodes_only_string(stream)
    
    found.should == expecting
    
    expecting = '<UNKNOWN: 101>'
    found = stream.inspect
    
    found.should == expecting
  end
  
  def test_two_children_of_nil_root
    v = Class.new(CommonTree) do
      def initialize(token = nil, type = nil, x = nil)
        @x = x
        super(token || (CommonToken.new { |t| t.type = type } if type))
      end
      def to_s
        (@token.text rescue '') + '<V>'
      end
    end
    
    root_0 = @adaptor.create_flat_list
    t = v.new(nil, 101, 2)
    u = v.new CommonToken.create(:type => 102, :text => '102')
    @adaptor.add_child(root_0, t)
    @adaptor.add_child(root_0, u)
    
    assert(root_0.parent.nil?)
    root_0.child_index.should == -1
    t.child_index.should == 0
    u.child_index.should == 1
    
  end
  
  def test_4_nodes
    t = CommonTree.new CommonToken[101]
    t.add_child( CommonTree.new CommonToken[102] )
    t.child(0).add_child(CommonTree.new CommonToken[103])
    t.add_child(CommonTree.new CommonToken[104])
    
    stream = new_stream(t)

    expecting = "101 102 103 104"
    found = nodes_only_string(stream)
    found.should == expecting
    
    expecting = "<UNKNOWN: 101> <DOWN> <UNKNOWN: 102> <DOWN> <UNKNOWN: 103> <UP> <UNKNOWN: 104> <UP>"
    found = stream.inspect
    found.should == expecting
  end
  
  def test_list
    root = CommonTree.new(nil)
    t = CommonTree.new CommonToken[101]
    t.add_child CommonTree.new(CommonToken[102])
    t.child(0).add_child(CommonTree.new(CommonToken[103]))
    t.add_child(CommonTree.new(CommonToken[104]))
    
    u = CommonTree.new CommonToken[105]
    
    root.add_child(t)
    root.add_child(u)
    
    stream = CommonTreeNodeStream.new(root)
    
    expecting = '101 102 103 104 105'
    found = nodes_only_string(stream)
    found.should == expecting
    
    expecting = "<UNKNOWN: 101> <DOWN> <UNKNOWN: 102> <DOWN> <UNKNOWN: 103> <UP> <UNKNOWN: 104> <UP> <UNKNOWN: 105>"
    found = stream.inspect
    found.should == expecting
  end
  
  def test_flat_list
    root = CommonTree.new(nil)
    
    root.add_child CommonTree.new(CommonToken[101])
    root.add_child(CommonTree.new(CommonToken[102]))
    root.add_child(CommonTree.new(CommonToken[103]))
    
    stream = CommonTreeNodeStream.new( root )
    
    expecting = '101 102 103'
    found = nodes_only_string(stream)
    found.should == expecting
    
    expecting = '<UNKNOWN: 101> <UNKNOWN: 102> <UNKNOWN: 103>'
    found = stream.inspect
    found.should == expecting
  end
  
  def test_list_with_one_node
    root = CommonTree.new(nil)
    
    root.add_child(CommonTree.new(CommonToken[101]))
    
    stream = CommonTreeNodeStream.new(root)
    
    expecting = '101'
    found = nodes_only_string(stream)
    found.should == expecting
    
    expecting = "<UNKNOWN: 101>"
    found = stream.inspect
    found.should == expecting
  end
  
  def test_a_over_b
    t = CommonTree.new(CommonToken[101])
    t.add_child(CommonTree.new(CommonToken[102]))
    
    stream = new_stream(t)
    expecting = '101 102'
    found = nodes_only_string(stream)
    found.should == expecting
    
    expecting = '<UNKNOWN: 101> <DOWN> <UNKNOWN: 102> <UP>'
    found = stream.inspect
    found.should == expecting
  end
  
  def test_LT
    # ^(101 ^(102 103) 104)
    t = CommonTree.new CommonToken[101]
    t.add_child CommonTree.new(CommonToken[102])
    t.child(0).add_child(CommonTree.new(CommonToken[103]))
    t.add_child(CommonTree.new(CommonToken[104]))
    
    stream = new_stream(t)
    [101, DOWN, 102, DOWN, 103, UP, 104, UP, EOF].each_with_index do |type, index|
      stream.look(index + 1).type.should == type
    end
    stream.look(100).type.should == EOF
  end
  
  def test_mark_rewind_entire
    # ^(101 ^(102 103 ^(106 107)) 104 105)
    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r0.add_child(r1)
    r1.add_child(new_node new_token(103))
    r2 = new_node new_token(106)
    r2.add_child new_node( new_token 107 )
    r1.add_child r2
    r0.add_child new_node( new_token 104 )
    r0.add_child new_node( new_token 105 )
    
    stream = CommonTreeNodeStream.new(r0)
    m = stream.mark
    13.times { stream.look(1); stream.consume } # consume until end
    
    stream.look(1).type.should == EOF
    stream.look(-1).type.should == UP
    stream.rewind(m)
    
    13.times { stream.look(1); stream.consume } # consume until end
    
    stream.look(1).type.should == EOF
    stream.look(-1).type.should == UP
  end
  
  def test_mark_rewind_in_middle
    # ^(101 ^(102 103 ^(106 107)) 104 105)
    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r0.add_child r1
    r1.add_child new_node( new_token 103 )
    r2 = new_node new_token(106)
    r2.add_child new_node( new_token 107 )
    r1.add_child r2
    r0.add_child new_node( new_token 104 )
    r0.add_child new_node( new_token 105 )
    
    stream = CommonTreeNodeStream.new(r0)
    7.times { stream.consume }
    
    stream.look(1).type.should == 107
    m = stream.mark
    4.times { stream.consume }
    stream.rewind(m)
    
    [107, UP, UP, 104].each do |val|
      stream.look(1).type.should == val
      stream.consume
    end
    # past rewind position now
    [105, UP].each do |val|
      stream.look(1).type.should == val
      stream.consume
    end
    stream.look(1).type.should == EOF
    stream.look(-1).type.should == UP
  end
  
  def test_mark_rewind_nested
    # ^(101 ^(102 103 ^(106 107)) 104 105)
    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r0.add_child r1
    r1.add_child new_node( new_token 103 )
    r2 = new_node new_token(106)
    r2.add_child new_node( new_token 107 )
    r1.add_child r2
    r0.add_child new_node( new_token 104 )
    r0.add_child new_node( new_token 105 )
    
    stream = CommonTreeNodeStream.new(r0)
    m = stream.mark
    2.times { stream.consume }
    m2 = stream.mark
    4.times { stream.consume }
    stream.rewind(m2)
    stream.look(1).type.should == 102
    stream.consume
    stream.look(1).type.should == DOWN
    stream.consume
    
    stream.rewind(m)
    [101, DOWN, 102].each do |val|
      stream.look(1).type.should == val
      stream.consume
    end
    stream.look(1).type.should == DOWN
  end
  
  def test_seek
    # ^(101 ^(102 103 ^(106 107) ) 104 105)
    # stream has 7 real + 6 nav nodes
    # Sequence of types: 101 DN 102 DN 103 106 DN 107 UP UP 104 105 UP EOF

    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r0.add_child r1
    r1.add_child new_node( new_token 103 )
    r2 = new_node new_token(106)
    r2.add_child new_node( new_token 107 )
    r1.add_child r2
    r0.add_child new_node( new_token 104 )
    r0.add_child new_node( new_token 105 )
    
    stream = CommonTreeNodeStream.new(r0)
    3.times { stream.consume }
    stream.seek(7)
    stream.look(1).type.should == 107
    3.times { stream.consume }
    stream.look(1).type.should == 104
  end
  
  def test_seek_from_start
    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r0.add_child r1
    r1.add_child new_node( new_token 103 )
    r2 = new_node new_token(106)
    r2.add_child new_node( new_token 107 )
    r1.add_child r2
    r0.add_child new_node( new_token 104 )
    r0.add_child new_node( new_token 105 )
    
    stream = CommonTreeNodeStream.new(r0)
    stream.seek(7)
    stream.look(1).type.should == 107
    3.times { stream.consume }
    stream.look(1).type.should == 104
  end
  
  def nodes_only_string(nodes)
    buffer = []
    nodes.size.times do |index|
      t = nodes.look(index + 1)
      type = nodes.tree_adaptor.type_of(t)
      buffer << type.to_s unless type == DOWN or type == UP
    end
    return buffer.join(' ')
  end
  
  def new_token(type, opts = {})
    opts[:type] = type
    CommonToken.create(opts)
  end
  def new_node(token)
    CommonTree.new(token)
  end


end

class TestCommonTreeNodeStream < Test::Unit::TestCase
  def setup
    # before-each-test code
  end
  def teardown
    # after-each-test code
  end
  
  # vvvvvvvv tests vvvvvvvvv
  
  def test_push_pop
    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r1.add_child new_node( new_token 103 )
    r0.add_child r1
    r2 = new_node new_token(104)
    r2.add_child new_node( new_token 105 )
    r0.add_child r2
    r3 = new_node new_token(106)
    r3.add_child new_node( new_token 107 )
    r0.add_child r3
    r0.add_child new_node( new_token 108 )
    r0.add_child new_node( new_token 109 )
    
    stream = CommonTreeNodeStream.new(r0)
    expecting = '<UNKNOWN: 101> <DOWN> <UNKNOWN: 102> <DOWN> <UNKNOWN: 103> <UP> <UNKNOWN: 104> ' +
                '<DOWN> <UNKNOWN: 105> <UP> <UNKNOWN: 106> <DOWN> <UNKNOWN: 107> <UP> ' +
                '<UNKNOWN: 108> <UNKNOWN: 109> <UP>'
    found = stream.inspect
    found.should == expecting
    
    index_of_102 = 2
    index_of_107 = 12
    index_of_107.times { stream.consume }
    
    stream.look(1).type.should == 107
    stream.push(index_of_102)
    stream.look(1).type.should == 102
    stream.consume
    stream.look(1).type.should == DOWN
    stream.consume
    stream.look(1).type.should == 103
    stream.consume
    stream.look(1).type.should == UP
    stream.pop
    stream.look(1).type.should == 107
  end
  
  def test_nested_push_pop
    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r1.add_child new_node( new_token 103 )
    r0.add_child r1
    r2 = new_node new_token(104)
    r2.add_child new_node( new_token 105 )
    r0.add_child r2
    r3 = new_node new_token(106)
    r3.add_child new_node( new_token 107 )
    r0.add_child r3
    r0.add_child new_node( new_token 108 )
    r0.add_child new_node( new_token 109 )
    
    stream = CommonTreeNodeStream.new(r0)
    
    index_of_102 = 2
    index_of_107 = 12
    
    index_of_107.times { stream.consume }
    
    stream.look(1).type.should == 107
    stream.push(index_of_102)
    [102, DOWN, 103].each do |val|
      stream.look(1).type.should == val
      stream.consume
    end
    
    index_of_104 = 6
    stream.push(index_of_104)
    [104,DOWN,105].each do |val|
      stream.look(1).type.should == val
      stream.consume
    end
    stream.look(1).type.should == UP
    stream.pop
    
    stream.look(1).type.should == UP
    stream.pop
    stream.look(1).type.should == 107
  end
  
  def test_push_pop_from_eof
    r0 = new_node new_token(101)
    r1 = new_node new_token(102)
    r1.add_child new_node( new_token 103 )
    r0.add_child r1
    r2 = new_node new_token(104)
    r2.add_child new_node( new_token 105 )
    r0.add_child r2
    r3 = new_node new_token(106)
    r3.add_child new_node( new_token 107 )
    r0.add_child r3
    r0.add_child new_node( new_token 108 )
    r0.add_child new_node( new_token 109 )
    
    stream = CommonTreeNodeStream.new(r0)
    stream.consume until stream.peek(1) == EOF
    
    index_of_102 = 2
    index_of_104 = 6
    stream.look(1).type.should == EOF
    
    stream.push(index_of_102)
    [102, DOWN, 103].each do |val|
      stream.look(1).type.should == val
      stream.consume
    end
    stream.look(1).type.should == UP
    
    stream.pop
    stream.look(1).type.should == EOF
    
    stream.push(index_of_104)
    [104, DOWN, 105].each do |val|
      stream.look(1).type.should == val
      stream.consume
    end
    stream.look(1).type.should == UP
    
    stream.pop
    stream.look(1).type.should == EOF
  end
  
  
  def new_token(type, opts = {})
    opts[:type] = type
    CommonToken.create(opts)
  end
  def new_node(token)
    CommonTree.new(token)
  end
end


class TestCommonTree < Test::Unit::TestCase
  def setup
    @adaptor = CommonTreeAdaptor.new
  end
  def teardown
    # after-each-test code
  end
  
  # vvvvvvvv tests vvvvvvvvv
  
  def test_single_node
    t = new_node( new_token 101 )
    assert_nil t.parent
    t.child_index.should == -1
  end
  
  def test_4_nodes
    # ^(101 ^(102 103) 104)
    r0 = new_node( new_token 101 )
    r0.add_child new_node( new_token 102 )
    r0.child(0).add_child new_node( new_token 103 )
    r0.add_child new_node( new_token 104 )
    
    assert_nil r0.parent
    r0.child_index.should == -1
  end
  
  def test_list
    # ^(nil 101 102 103)
    r0 = CommonTree.new(nil)
    c0 = new_node( new_token 101 )
    r0.add_child c0
    c1 = new_node( new_token 102 )
    r0.add_child c1
    c2 = new_node( new_token 103 )
    r0.add_child c2
    
    assert_nil r0.parent
    r0.child_index.should == -1
    c0.parent.should == r0
    c0.child_index.should == 0
    c1.parent.should == r0
    c1.child_index.should == 1
    c2.parent.should == r0
    c2.child_index.should == 2
  end
  
  def test_list2
    # ^(nil 101 102 103)
    root = new_node( new_token 5 )
    r0 = CommonTree.new(nil)
    c0 = new_node( new_token 101 )
    r0.add_child c0
    c1 = new_node( new_token 102 )
    r0.add_child c1
    c2 = new_node( new_token 103 )
    r0.add_child c2
    
    root.add_child r0
    
    assert_nil root.parent
    root.child_index.should == -1
    c0.parent.should == root
    c0.child_index.should == 0
    c1.parent.should == root            # note -- actual python tests all use c0 here, which i think might be wrong
    c1.child_index.should == 1
    c2.parent.should == root            # note -- actual python tests all use c0 here, which i think might be wrong
    c2.child_index.should == 2
  end
  
  def test_add_list_to_exist_children
    root = new_node( new_token 5 )
    root.add_child new_node( new_token 6 )
    
    r0 = CommonTree.new(nil)
    c0 = new_node( new_token 101 )
    r0.add_child c0
    c1 = new_node( new_token 102 )
    r0.add_child c1
    c2 = new_node( new_token 103 )
    r0.add_child c2
    # ^(nil c0=101 c1=102 c2=103)
    
    root.add_child(r0)
    
    assert_nil root.parent
    root.child_index.should == -1
    c0.parent.should == root
    c0.child_index.should == 1
    c1.parent.should == root
    c1.child_index.should == 2
    c2.parent.should == root
    c2.child_index.should == 3
  end
  
  def test_copy_tree
    r0 = new_node( new_token 101 )
    r1 = new_node( new_token 102 )
    r2 = new_node( new_token 106 )
    r0.add_child( r1 )
    r1.add_child( new_node( new_token 103 ) )
    r2.add_child( new_node( new_token 107 ) )
    r1.add_child( r2 )
    r0.add_child( new_node( new_token 104 ) )
    r0.add_child( new_node( new_token 105 ) )
    
    dup = @adaptor.copy_tree( r0 )
    assert_nil dup.parent
    dup.child_index.should == -1
    dup.sanity_check
  end
  
  def test_become_root
    new_root = new_node( new_token 5 )
    
    old_root = new_node nil
    old_root.add_child( new_node( new_token 101 ) )
    old_root.add_child( new_node( new_token 102 ) )
    old_root.add_child( new_node( new_token 103 ) )
    
    @adaptor.become_root(new_root, old_root)
    new_root.sanity_check
  end
  
  def test_become_root2
    new_root = new_node( new_token 5 )
    
    old_root = new_node( new_token 101 )
    old_root.add_child( new_node( new_token 102 ) )
    old_root.add_child( new_node( new_token 103 ) )
    
    @adaptor.become_root(new_root, old_root)
    new_root.sanity_check
  end
  
  def test_become_root3
    new_root = new_node nil
    new_root.add_child( new_node( new_token 5 ) )
    
    old_root = new_node nil
    old_root.add_child( new_node( new_token 101 ) )
    old_root.add_child( new_node( new_token 102 ) )
    old_root.add_child( new_node( new_token 103 ) )
    
    @adaptor.become_root(new_root, old_root)
    new_root.sanity_check
  end
  
  def test_become_root5
    new_root = new_node nil
    new_root.add_child( new_node( new_token 5 ) )
    
    old_root = new_node( new_token 101 )
    old_root.add_child( new_node( new_token 102 ) )
    old_root.add_child( new_node( new_token 103 ) )
    
    @adaptor.become_root(new_root, old_root)
    new_root.sanity_check
  end
  
  def test_become_root6
    root_0 = @adaptor.create_flat_list
    root_1 = @adaptor.create_flat_list
    root_1 = @adaptor.become_root( new_node( new_token 5 ), root_1 )
    
    @adaptor.add_child( root_1, new_node( new_token 6 ) )
    @adaptor.add_child( root_0, root_1 )
    root_0.sanity_check
  end
  
  def test_replace_with_no_children
    t = new_node( new_token 101 )
    new_child = new_node( new_token 5 )
    error = false
    assert_raise(IndexError) do
      t.replace_children(0, 0, new_child)
    end
  end
  
  def test_replace_with_one_children
    t = new_node( new_token 99, :text => 'a' )
    c0 = new_node( new_token 99, :text => 'b' )
    t.add_child(c0)
    
    new_child = new_node( new_token 99, :text => 'c' )
    t.replace_children(0,0,new_child)
    
    t.inspect.should == '(a c)'
    t.sanity_check

  end
  def test_replace_in_middle
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_child = new_node( new_token 99, :text => 'x' )
    t.replace_children(1, 1, new_child)
    t.inspect.should == '(a b x d)'
    t.sanity_check
  end
  
  def test_replace_at_left
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_child = new_node( new_token 99, :text => 'x' )
    t.replace_children(0, 0, new_child)
    t.inspect.should == '(a x c d)'
    t.sanity_check
  end
  
  def test_replace_at_left
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_child = new_node( new_token 99, :text => 'x' )
    t.replace_children(2, 2, new_child)
    t.inspect.should == '(a b c x)'
    t.sanity_check
  end
  
  def test_replace_one_with_two_at_left
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_children = @adaptor.create_flat_list
    new_children.add_child new_node( new_token 99, :text => 'x' )
    new_children.add_child new_node( new_token 99, :text => 'y' )
    
    t.replace_children(0, 0, new_children)
    t.inspect.should == '(a x y c d)'
    t.sanity_check
  end
  
  def test_replace_one_with_two_at_right
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_children = @adaptor.create_flat_list
    new_children.add_child new_node( new_token 99, :text => 'x' )
    new_children.add_child new_node( new_token 99, :text => 'y' )
    
    t.replace_children(2, 2, new_children)
    t.inspect.should == '(a b c x y)'
    t.sanity_check
  end
  
  def test_replace_one_with_two_in_middle
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_children = @adaptor.create_flat_list
    new_children.add_child new_node( new_token 99, :text => 'x' )
    new_children.add_child new_node( new_token 99, :text => 'y' )
    
    t.replace_children(1, 1, new_children)
    t.inspect.should == '(a b x y d)'
    t.sanity_check
  end
  
  def test_replace_two_with_one_at_left
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_child = new_node( new_token 99, :text => 'x' )
    
    t.replace_children(0, 1, new_child)
    t.inspect.should == '(a x d)'
    t.sanity_check
  end
  
  def test_replace_two_with_one_at_right
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_child = new_node( new_token 99, :text => 'x' )
    
    t.replace_children(1, 2, new_child)
    t.inspect.should == '(a b x)'
    t.sanity_check
  end
  
  def test_replace_all_with_one
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_child = new_node( new_token 99, :text => 'x' )
    
    t.replace_children(0, 2, new_child)
    t.inspect.should == '(a x)'
    t.sanity_check
  end
  
  def test_replace_all_with_two
    t = new_node( new_token 99, :text => 'a' )
    t.add_child new_node( new_token 99, :text => 'b' )
    t.add_child new_node( new_token 99, :text => 'c' )
    t.add_child new_node( new_token 99, :text => 'd' )
    
    new_children = @adaptor.create_flat_list
    new_children.add_child new_node( new_token 99, :text => 'x' )
    new_children.add_child new_node( new_token 99, :text => 'y' )
    
    t.replace_children(0, 1, new_children)
    t.inspect.should == '(a x y d)'
    t.sanity_check
  end
  
  def new_token(type, opts = {})
    opts[:type] = type
    CommonToken.create(opts)
  end
  def new_node(token)
    CommonTree.new(token)
  end
end


class TestTreeContext < Test::Unit::TestCase
  TOKEN_NAMES = %w(
    <invalid> <EOR> <DOWN> <UP> VEC ASSIGN PRINT
    PLUS MULT DOT ID INT WS '[' ',' ']'
  )
  Tokens = TokenScheme.build( TOKEN_NAMES )
  
  def setup
    @wizard = Wizard.new( :token_scheme => Tokens )
  end
  
  def teardown
    # after-each-test code
  end
  
  # vvvvvvvv tests vvvvvvvvv
  
  def test_simple_parent
    tree = @wizard.create(
      "(nil (ASSIGN ID[x] INT[3]) (PRINT (MULT ID[x] (VEC INT[1] INT[2] INT[3]))))"
    )
    labels = @wizard.match( tree,
      "(nil (ASSIGN ID[x] INT[3]) (PRINT (MULT ID (VEC INT %x:INT INT))))"
    )
    
    assert_kind_of( Hash, labels )
    @wizard.in_context?( labels.fetch( 'x' ), 'VEC' ).should be_true
  end
  
  def test_no_parent
    tree = @wizard.create(
      '(PRINT (MULT ID[x] (VEC INT[1] INT[2] INT[3])))'
    )
    
    labels = @wizard.match( tree, "(%x:PRINT (MULT ID (VEC INT INT INT)))" )
    assert_kind_of( Hash, labels )
    @wizard.in_context?( labels.fetch( 'x' ), 'VEC' ).should be_false
  end
  
  def test_parent_with_wildcard
    tree = @wizard.create(
      "(nil (ASSIGN ID[x] INT[3]) (PRINT (MULT ID[x] (VEC INT[1] INT[2] INT[3]))))"
    )
    
    labels = @wizard.match( tree,
      "(nil (ASSIGN ID[x] INT[3]) (PRINT (MULT ID (VEC INT %x:INT INT))))"
    )
    assert_kind_of( Hash, labels )
    node = labels.fetch( 'x' )
    @wizard.in_context?( node, 'VEC ...' ).should be_true
  end
end
