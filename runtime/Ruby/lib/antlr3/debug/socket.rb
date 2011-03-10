#!/usr/bin/ruby
# encoding: utf-8

require 'socket'

module ANTLR3
module Debug


=begin rdoc ANTLR3::Debug::EventSocketProxy

A proxy debug event listener that forwards events over a socket to
a debugger (or any other listener) using a simple text-based protocol;
one event per line.  ANTLRWorks listens on server socket with a
RemoteDebugEventSocketListener instance.  These two objects must therefore
be kept in sync.  New events must be handled on both sides of socket.

=end
class EventSocketProxy
  include EventListener
  
  SOCKET_ADDR_PACK = 'snCCCCa8'.freeze
  
  def initialize( recognizer, options = {} )
    super()
    @grammar_file_name = recognizer.grammar_file_name
    @adaptor = options[ :adaptor ]
    @port = options[ :port ] || DEFAULT_PORT
    @log = options[ :log ]
    @socket = nil
    @connection = nil
  end
  
  def log!( message, *interpolation_arguments )
    @log and @log.printf( message, *interpolation_arguments )
  end
  
  def handshake
    unless @socket
      begin
        @socket = Socket.new( Socket::AF_INET, Socket::SOCK_STREAM, 0 )
        @socket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
        @socket.bind( Socket.pack_sockaddr_in( @port, '' ) )
        @socket.listen( 1 )
        log!( "waiting for incoming connection on port %i\n", @port )
        
        @connection, addr = @socket.accept
        port, host = Socket.unpack_sockaddr_in( addr )
        log!( "Accepted connection from %s:%s\n", host, port )
        
        @connection.setsockopt( Socket::SOL_TCP, Socket::TCP_NODELAY, 1 )
        
        write( 'ANTLR %s', PROTOCOL_VERSION )
        write( 'grammar %p', @grammar_file_name )
        ack
      rescue IOError => error
        log!( "handshake failed due to an IOError:\n" )
        log!( "  %s: %s", error.class, error.message )
        log!( "  Backtrace: " )
        log!( "  - %s", error.backtrace.join( "\n  - " ) )
        @connection and @connection.close
        @socket and @socket.close
        @socket = nil
        raise
      end
    end
    return self
  end
  
  def write( message, *interpolation_arguments )
    message << ?\n
    log!( "---> #{ message }", *interpolation_arguments )
    @connection.printf( message, *interpolation_arguments )
    @connection.flush
  end
  
  def ack
    line = @connection.readline
    log!( "<--- %s", line )
    line
  end
  
  def transmit( event, *interpolation_arguments )
    write( event, *interpolation_arguments )
    ack()
  rescue IOError
    @connection.close
    raise
  end
  
  def commence
    # don't bother sending event; listener will trigger upon connection
  end
  
  def terminate
    transmit 'terminate'
    @connection.close
    @socket.close
  end
  
  def enter_rule( grammar_file_name, rule_name )
    transmit "%s\t%s\t%s", :enter_rule, grammar_file_name, rule_name
  end
  
  def enter_alternative( alt )
    transmit "%s\t%s", :enter_alternative, alt
  end
  
  def exit_rule( grammar_file_name, rule_name )
    transmit "%s\t%s\t%s", :exit_rule, grammar_file_name, rule_name
  end
  
  def enter_subrule( decision_number )
    transmit "%s\t%i", :enter_subrule, decision_number
  end
  
  def exit_subrule( decision_number )
    transmit "%s\t%i", :exit_subrule, decision_number
  end
  
  def enter_decision( decision_number )
    transmit "%s\t%i", :enter_decision, decision_number
  end
  
  def exit_decision( decision_number )
    transmit "%s\t%i", :exit_decision, decision_number
  end
  
  def consume_token( token )
    transmit "%s\t%s", :consume_token, serialize_token( token )
  end
  
  def consume_hidden_token( token )
    transmit "%s\t%s", :consume_hidden_token, serialize_token( token )
  end
  
  def look( i, item )
    case item
    when AST::Tree
      look_tree( i, item )
    when nil
    else
      transmit "%s\t%i\t%s", :look, i, serialize_token( item )
    end
  end
  
  def mark( i )
    transmit "%s\t%i", :mark, i
  end
  
  def rewind( i = nil )
    i ? transmit( "%s\t%i", :rewind, i ) : transmit( '%s', :rewind )
  end
  
  def begin_backtrack( level )
    transmit "%s\t%i", :begin_backtrack, level
  end
  def end_backtrack( level, successful )
    transmit "%s\t%i\t%p", :end_backtrack, level, ( successful ? true : false )
  end
  
  def location( line, position )
    transmit "%s\t%i\t%i", :location, line, position
  end
  
  def recognition_exception( exception )
    transmit "%s\t%p\t%i\t%i\t%i", :recognition_exception, exception.class,
      exception.index, exception.line, exception.column
  end
  
  def begin_resync
    transmit '%s', :begin_resync
  end
  
  def end_resync
    transmit '%s', :end_resync
  end
  
  def semantic_predicate( result, predicate )
    pure_boolean = !( !result )
    transmit "%s\t%s\t%s", :semantic_predicate, pure_boolean, escape_newlines( predicate )
  end
  
  def consume_node( tree )
    transmit "%s\t%s", :consume_node, serialize_node( tree )
  end
  
  def adaptor
    @adaptor ||= ANTLR3::CommonTreeAdaptor.new
  end
  
  def look_tree( i, tree )
    transmit "%s\t%s\t%s", :look_tree, i, serialize_node( tree )
  end
  
  def flat_node( tree )
    transmit "%s\t%i", :flat_node, adaptor.unique_id( tree )
  end
  
  def error_node( tree )
    transmit "%s\t%i\t%i\t%p", :error_node, adaptor.unique_id( tree ),
            Token::INVALID_TOKEN_TYPE, escape_newlines( tree.to_s )
  end
  
  def create_node( node, token = nil )
    if token
      transmit "%s\t%i\t%i", :create_node, adaptor.unique_id( node ),
              token.token_index
    else
      transmit "%s\t%i\t%i\t%p", :create_node, adaptor.unique_id( node ),
          adaptor.type_of( node ), adaptor.text_of( node )
    end
  end
  
  def become_root( new_root, old_root )
    transmit "%s\t%i\t%i", :become_root, adaptor.unique_id( new_root ),
              adaptor.unique_id( old_root )
  end
  
  def add_child( root, child )
    transmit "%s\t%i\t%i", :add_child, adaptor.unique_id( root ),
             adaptor.unique_id( child )
  end
  
  def set_token_boundaries( t, token_start_index, token_stop_index )
    transmit "%s\t%i\t%i\t%i", :set_token_boundaries, adaptor.unique_id( t ),
                               token_start_index, token_stop_index
  end
  
  attr_accessor :adaptor
  
  def serialize_token( token )
    [ token.token_index, token.type, token.channel,
     token.line, token.column,
     escape_newlines( token.text ) ].join( "\t" )
  end
  
  def serialize_node( node )
    adaptor ||= ANTLR3::AST::CommonTreeAdaptor.new
    id = adaptor.unique_id( node )
    type = adaptor.type_of( node )
    token = adaptor.token( node )
    line = token.line rescue -1
    col  = token.column rescue -1
    index = adaptor.token_start_index( node )
    [ id, type, line, col, index ].join( "\t" )
  end
  
  
  def escape_newlines( text )
    text.inspect.tap do |t|
      t.gsub!( /%/, '%%' )
    end
  end
end

=begin rdoc ANTLR3::Debug::RemoteEventSocketListener

A debugging event listener which intercepts debug event messages sent by a EventSocketProxy
over an IP socket.

=end
class RemoteEventSocketListener < ::Thread
  autoload :StringIO, 'stringio'
  ESCAPE_MAP = Hash.new { |h, k| k }
  ESCAPE_MAP.update( 
    ?n => ?\n, ?t => ?\t, ?a => ?\a, ?b => ?\b, ?e => ?\e,
    ?f => ?\f, ?r => ?\r, ?v => ?\v
  )
  
  attr_reader :host, :port
  
  def initialize( options = {} )
    @listener = listener
    @host = options.fetch( :host, 'localhost' )
    @port = options.fetch( :port, DEFAULT_PORT )
    @buffer = StringIO.new
    super do
      connect do
        handshake
        loop do
          yield( read_event )
        end
      end
    end
  end
  
private
  
  def handshake
    @version = @socket.readline.split( "\t" )[ -1 ]
    @grammar_file = @socket.readline.split( "\t" )[ -1 ]
    ack
  end
  
  def ack
    @socket.puts( "ack" )
    @socket.flush
  end
  
  def unpack_event( event )
    event.nil? and raise( StopIteration )
    event.chomp!
    name, *elements = event.split( "\t",-1 )
    name = name.to_sym
    name == :terminate and raise StopIteration
    elements.map! do |elem|
      elem.empty? and next( nil )
      case elem
      when /^\d+$/ then Integer( elem )
      when /^\d+\.\d+$/ then Float( elem )
      when /^true$/ then true
      when /^false$/ then false
      when /^"(.*)"$/ then parse_string( $1 )
      end
    end
    elements.unshift( name )
    return( elements )
  end
  
  def read_event
    event = @socket.readline or raise( StopIteration )
    ack
    return unpack_event( event )
  end
  
  def connect
    TCPSocket.open( @host, @port ) do |socket|
      @socket = socket
      yield
    end
  end
  
  def parse_string( string )
    @buffer.string = string
    @buffer.rewind
    out = ''
    until @buffer.eof?
      case c = @buffer.getc
      when ?\\                    # escape
        nc = @buffer.getc
        out << 
          if nc.between?( ?0, ?9 )  # octal integer
            @buffer.ungetc( nc )
            @buffer.read( 3 ).to_i( 8 ).chr
          elsif nc == ?x
            @buffer.read( 2 ).to_i( 16 ).chr
          else
            ESCAPE_MAP[ nc ]
          end
      else
        out << c
      end
    end
    return out
  end
  
end # class RemoteEventSocketListener
end # module Debug
end # module ANTLR3
