#!/usr/bin/env ruby
#
# GroupFile.g
# 
# Generated using ANTLR version: 3.2.1-SNAPSHOT Jun 18, 2010 05:38:11
# Ruby runtime library version: 1.7.5
# Input grammar file: GroupFile.g
# Generated at: 2010-07-03 23:15:35
# 

# ~~~> start load path setup
this_directory = File.expand_path( File.dirname( __FILE__ ) )
$LOAD_PATH.unshift( this_directory ) unless $LOAD_PATH.include?( this_directory )

antlr_load_failed = proc do
  load_path = $LOAD_PATH.map { |dir| '  - ' << dir }.join( $/ )
  raise LoadError, <<-END.strip!
  
Failed to load the ANTLR3 runtime library (version 1.7.5):

Ensure the library has been installed on your system and is available
on the load path. If rubygems is available on your system, this can
be done with the command:
  
  gem install antlr3

Current load path:
#{ load_path }

  END
end

defined?( ANTLR3 ) or begin
  
  # 1: try to load the ruby antlr3 runtime library from the system path
  require 'antlr3'
  
rescue LoadError
  
  # 2: try to load rubygems if it isn't already loaded
  defined?( Gem ) or begin
    require 'rubygems'
  rescue LoadError
    antlr_load_failed.call
  end
  
  # 3: try to activate the antlr3 gem
  begin
    Gem.activate( 'antlr3', '~> 1.7.5' )
  rescue Gem::LoadError
    antlr_load_failed.call
  end
  
  require 'antlr3'
  
end
# <~~~ end load path setup

# - - - - - - begin action @lexer::header - - - - - -
# GroupFile.g


module ANTLR3
module Template

# - - - - - - end action @lexer::header - - - - - - -


module GroupFile
  # TokenData defines all of the token type integer values
  # as constants, which will be included in all 
  # ANTLR-generated recognizers.
  const_defined?( :TokenData ) or TokenData = ANTLR3::TokenScheme.new

  module TokenData

    # define the token constants
    define_tokens( :ID => 5, :EOF => -1, :T__19 => 19, :WS => 9, :T__16 => 16, 
                   :T__15 => 15, :T__18 => 18, :T__17 => 17, :T__12 => 12, 
                   :TEMPLATE => 6, :T__11 => 11, :T__14 => 14, :T__13 => 13, 
                   :T__10 => 10, :CONSTANT => 4, :COMMENT => 8, :STRING => 7 )
    
  end


  class Lexer < ANTLR3::Lexer
    @grammar_home = GroupFile
    include TokenData

    
    begin
      generated_using( "GroupFile.g", "3.2.1-SNAPSHOT Jun 18, 2010 05:38:11", "1.7.5" )
    rescue NoMethodError => error
      # ignore
    end
    
    RULE_NAMES   = [ "T__10", "T__11", "T__12", "T__13", "T__14", "T__15", 
                     "T__16", "T__17", "T__18", "T__19", "CONSTANT", "ID", 
                     "TEMPLATE", "STRING", "COMMENT", "WS" ].freeze
    RULE_METHODS = [ :t__10!, :t__11!, :t__12!, :t__13!, :t__14!, :t__15!, 
                     :t__16!, :t__17!, :t__18!, :t__19!, :constant!, :id!, 
                     :template!, :string!, :comment!, :ws! ].freeze

    
    def initialize( input=nil, options = {} )
      super( input, options )

    end
    
    
    # - - - - - - - - - - - lexer rules - - - - - - - - - - - -
    # lexer rule t__10! (T__10)
    # (in GroupFile.g)
    def t__10!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 1 )

      type = T__10
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 16:9: 'group'
      match( "group" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 1 )

    end

    # lexer rule t__11! (T__11)
    # (in GroupFile.g)
    def t__11!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 2 )

      type = T__11
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 17:9: '::'
      match( "::" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 2 )

    end

    # lexer rule t__12! (T__12)
    # (in GroupFile.g)
    def t__12!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 3 )

      type = T__12
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 18:9: ';'
      match( 0x3b )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 3 )

    end

    # lexer rule t__13! (T__13)
    # (in GroupFile.g)
    def t__13!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 4 )

      type = T__13
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 19:9: '::='
      match( "::=" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 4 )

    end

    # lexer rule t__14! (T__14)
    # (in GroupFile.g)
    def t__14!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 5 )

      type = T__14
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 20:9: '('
      match( 0x28 )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 5 )

    end

    # lexer rule t__15! (T__15)
    # (in GroupFile.g)
    def t__15!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 6 )

      type = T__15
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 21:9: ')'
      match( 0x29 )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 6 )

    end

    # lexer rule t__16! (T__16)
    # (in GroupFile.g)
    def t__16!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 7 )

      type = T__16
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 22:9: ','
      match( 0x2c )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 7 )

    end

    # lexer rule t__17! (T__17)
    # (in GroupFile.g)
    def t__17!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 8 )

      type = T__17
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 23:9: '*'
      match( 0x2a )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 8 )

    end

    # lexer rule t__18! (T__18)
    # (in GroupFile.g)
    def t__18!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 9 )

      type = T__18
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 24:9: '&'
      match( 0x26 )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 9 )

    end

    # lexer rule t__19! (T__19)
    # (in GroupFile.g)
    def t__19!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 10 )

      type = T__19
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 25:9: '='
      match( 0x3d )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 10 )

    end

    # lexer rule constant! (CONSTANT)
    # (in GroupFile.g)
    def constant!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 11 )

      type = CONSTANT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 125:5: 'A' .. 'Z' ( 'a' .. 'z' | '_' | 'A' .. 'Z' | '0' .. '9' )*
      match_range( 0x41, 0x5a )
      # at line 125:14: ( 'a' .. 'z' | '_' | 'A' .. 'Z' | '0' .. '9' )*
      while true # decision 1
        alt_1 = 2
        look_1_0 = @input.peek( 1 )

        if ( look_1_0.between?( 0x30, 0x39 ) || look_1_0.between?( 0x41, 0x5a ) || look_1_0 == 0x5f || look_1_0.between?( 0x61, 0x7a ) )
          alt_1 = 1

        end
        case alt_1
        when 1
          # at line 
          if @input.peek( 1 ).between?( 0x30, 0x39 ) || @input.peek( 1 ).between?( 0x41, 0x5a ) || @input.peek( 1 ) == 0x5f || @input.peek( 1 ).between?( 0x61, 0x7a )
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 1
        end
      end # loop for decision 1

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 11 )

    end

    # lexer rule id! (ID)
    # (in GroupFile.g)
    def id!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 12 )

      type = ID
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 129:5: ( 'a' .. 'z' | '_' ) ( 'a' .. 'z' | '_' | 'A' .. 'Z' | '0' .. '9' )*
      if @input.peek( 1 ) == 0x5f || @input.peek( 1 ).between?( 0x61, 0x7a )
        @input.consume
      else
        mse = MismatchedSet( nil )
        recover mse
        raise mse
      end


      # at line 130:5: ( 'a' .. 'z' | '_' | 'A' .. 'Z' | '0' .. '9' )*
      while true # decision 2
        alt_2 = 2
        look_2_0 = @input.peek( 1 )

        if ( look_2_0.between?( 0x30, 0x39 ) || look_2_0.between?( 0x41, 0x5a ) || look_2_0 == 0x5f || look_2_0.between?( 0x61, 0x7a ) )
          alt_2 = 1

        end
        case alt_2
        when 1
          # at line 
          if @input.peek( 1 ).between?( 0x30, 0x39 ) || @input.peek( 1 ).between?( 0x41, 0x5a ) || @input.peek( 1 ) == 0x5f || @input.peek( 1 ).between?( 0x61, 0x7a )
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          break # out of loop for decision 2
        end
      end # loop for decision 2

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 12 )

    end

    # lexer rule template! (TEMPLATE)
    # (in GroupFile.g)
    def template!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 13 )

      type = TEMPLATE
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 134:5: '<<<' ( options {greedy=false; } : '\\\\' . | . )* '>>>'
      match( "<<<" )
      # at line 135:5: ( options {greedy=false; } : '\\\\' . | . )*
      while true # decision 3
        alt_3 = 3
        look_3_0 = @input.peek( 1 )

        if ( look_3_0 == 0x3e )
          look_3_1 = @input.peek( 2 )

          if ( look_3_1 == 0x3e )
            look_3_4 = @input.peek( 3 )

            if ( look_3_4 == 0x3e )
              alt_3 = 3
            elsif ( look_3_4.between?( 0x0, 0x3d ) || look_3_4.between?( 0x3f, 0xffff ) )
              alt_3 = 2

            end
          elsif ( look_3_1.between?( 0x0, 0x3d ) || look_3_1.between?( 0x3f, 0xffff ) )
            alt_3 = 2

          end
        elsif ( look_3_0 == 0x5c )
          look_3_2 = @input.peek( 2 )

          if ( look_3_2 == 0x3e )
            alt_3 = 1
          elsif ( look_3_2 == 0x5c )
            alt_3 = 1
          elsif ( look_3_2.between?( 0x0, 0x3d ) || look_3_2.between?( 0x3f, 0x5b ) || look_3_2.between?( 0x5d, 0xffff ) )
            alt_3 = 1

          end
        elsif ( look_3_0.between?( 0x0, 0x3d ) || look_3_0.between?( 0x3f, 0x5b ) || look_3_0.between?( 0x5d, 0xffff ) )
          alt_3 = 2

        end
        case alt_3
        when 1
          # at line 135:35: '\\\\' .
          match( 0x5c )
          match_any

        when 2
          # at line 135:44: .
          match_any

        else
          break # out of loop for decision 3
        end
      end # loop for decision 3
      match( ">>>" )

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 13 )

    end

    # lexer rule string! (STRING)
    # (in GroupFile.g)
    def string!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 14 )

      type = STRING
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 140:3: ( '\"' (~ ( '\\\\' | '\"' ) | '\\\\' . )* '\"' | '\\'' (~ ( '\\\\' | '\\'' ) | '\\\\' . )* '\\'' )
      alt_6 = 2
      look_6_0 = @input.peek( 1 )

      if ( look_6_0 == 0x22 )
        alt_6 = 1
      elsif ( look_6_0 == 0x27 )
        alt_6 = 2
      else
        raise NoViableAlternative( "", 6, 0 )
      end
      case alt_6
      when 1
        # at line 140:5: '\"' (~ ( '\\\\' | '\"' ) | '\\\\' . )* '\"'
        match( 0x22 )
        # at line 140:10: (~ ( '\\\\' | '\"' ) | '\\\\' . )*
        while true # decision 4
          alt_4 = 3
          look_4_0 = @input.peek( 1 )

          if ( look_4_0.between?( 0x0, 0x21 ) || look_4_0.between?( 0x23, 0x5b ) || look_4_0.between?( 0x5d, 0xffff ) )
            alt_4 = 1
          elsif ( look_4_0 == 0x5c )
            alt_4 = 2

          end
          case alt_4
          when 1
            # at line 140:12: ~ ( '\\\\' | '\"' )
            if @input.peek( 1 ).between?( 0x0, 0x21 ) || @input.peek( 1 ).between?( 0x23, 0x5b ) || @input.peek( 1 ).between?( 0x5d, 0xff )
              @input.consume
            else
              mse = MismatchedSet( nil )
              recover mse
              raise mse
            end



          when 2
            # at line 140:31: '\\\\' .
            match( 0x5c )
            match_any

          else
            break # out of loop for decision 4
          end
        end # loop for decision 4
        match( 0x22 )

      when 2
        # at line 141:5: '\\'' (~ ( '\\\\' | '\\'' ) | '\\\\' . )* '\\''
        match( 0x27 )
        # at line 141:10: (~ ( '\\\\' | '\\'' ) | '\\\\' . )*
        while true # decision 5
          alt_5 = 3
          look_5_0 = @input.peek( 1 )

          if ( look_5_0.between?( 0x0, 0x26 ) || look_5_0.between?( 0x28, 0x5b ) || look_5_0.between?( 0x5d, 0xffff ) )
            alt_5 = 1
          elsif ( look_5_0 == 0x5c )
            alt_5 = 2

          end
          case alt_5
          when 1
            # at line 141:12: ~ ( '\\\\' | '\\'' )
            if @input.peek( 1 ).between?( 0x0, 0x26 ) || @input.peek( 1 ).between?( 0x28, 0x5b ) || @input.peek( 1 ).between?( 0x5d, 0xff )
              @input.consume
            else
              mse = MismatchedSet( nil )
              recover mse
              raise mse
            end



          when 2
            # at line 141:31: '\\\\' .
            match( 0x5c )
            match_any

          else
            break # out of loop for decision 5
          end
        end # loop for decision 5
        match( 0x27 )

      end
      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 14 )

    end

    # lexer rule comment! (COMMENT)
    # (in GroupFile.g)
    def comment!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 15 )

      type = COMMENT
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 146:3: ( ( '#' | '//' ) (~ '\\n' )* | '/*' ( . )* '*/' )
      alt_10 = 2
      look_10_0 = @input.peek( 1 )

      if ( look_10_0 == 0x23 )
        alt_10 = 1
      elsif ( look_10_0 == 0x2f )
        look_10_2 = @input.peek( 2 )

        if ( look_10_2 == 0x2f )
          alt_10 = 1
        elsif ( look_10_2 == 0x2a )
          alt_10 = 2
        else
          raise NoViableAlternative( "", 10, 2 )
        end
      else
        raise NoViableAlternative( "", 10, 0 )
      end
      case alt_10
      when 1
        # at line 146:5: ( '#' | '//' ) (~ '\\n' )*
        # at line 146:5: ( '#' | '//' )
        alt_7 = 2
        look_7_0 = @input.peek( 1 )

        if ( look_7_0 == 0x23 )
          alt_7 = 1
        elsif ( look_7_0 == 0x2f )
          alt_7 = 2
        else
          raise NoViableAlternative( "", 7, 0 )
        end
        case alt_7
        when 1
          # at line 146:7: '#'
          match( 0x23 )

        when 2
          # at line 146:13: '//'
          match( "//" )

        end
        # at line 146:20: (~ '\\n' )*
        while true # decision 8
          alt_8 = 2
          look_8_0 = @input.peek( 1 )

          if ( look_8_0.between?( 0x0, 0x9 ) || look_8_0.between?( 0xb, 0xffff ) )
            alt_8 = 1

          end
          case alt_8
          when 1
            # at line 146:20: ~ '\\n'
            if @input.peek( 1 ).between?( 0x0, 0x9 ) || @input.peek( 1 ).between?( 0xb, 0xff )
              @input.consume
            else
              mse = MismatchedSet( nil )
              recover mse
              raise mse
            end



          else
            break # out of loop for decision 8
          end
        end # loop for decision 8

      when 2
        # at line 147:5: '/*' ( . )* '*/'
        match( "/*" )
        # at line 147:10: ( . )*
        while true # decision 9
          alt_9 = 2
          look_9_0 = @input.peek( 1 )

          if ( look_9_0 == 0x2a )
            look_9_1 = @input.peek( 2 )

            if ( look_9_1 == 0x2f )
              alt_9 = 2
            elsif ( look_9_1.between?( 0x0, 0x2e ) || look_9_1.between?( 0x30, 0xffff ) )
              alt_9 = 1

            end
          elsif ( look_9_0.between?( 0x0, 0x29 ) || look_9_0.between?( 0x2b, 0xffff ) )
            alt_9 = 1

          end
          case alt_9
          when 1
            # at line 147:10: .
            match_any

          else
            break # out of loop for decision 9
          end
        end # loop for decision 9
        match( "*/" )

      end
      
      @state.type = type
      @state.channel = channel
    # --> action
     skip 
    # <-- action
    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 15 )

    end

    # lexer rule ws! (WS)
    # (in GroupFile.g)
    def ws!
      # -> uncomment the next line to manually enable rule tracing
      # trace_in( __method__, 16 )

      type = WS
      channel = ANTLR3::DEFAULT_CHANNEL

      
      # - - - - main rule block - - - -
      # at line 151:5: ( ' ' | '\\t' | '\\n' | '\\r' | '\\f' )+
      # at file 151:5: ( ' ' | '\\t' | '\\n' | '\\r' | '\\f' )+
      match_count_11 = 0
      while true
        alt_11 = 2
        look_11_0 = @input.peek( 1 )

        if ( look_11_0.between?( 0x9, 0xa ) || look_11_0.between?( 0xc, 0xd ) || look_11_0 == 0x20 )
          alt_11 = 1

        end
        case alt_11
        when 1
          # at line 
          if @input.peek( 1 ).between?( 0x9, 0xa ) || @input.peek( 1 ).between?( 0xc, 0xd ) || @input.peek( 1 ) == 0x20
            @input.consume
          else
            mse = MismatchedSet( nil )
            recover mse
            raise mse
          end



        else
          match_count_11 > 0 and break
          eee = EarlyExit( 11 )


          raise eee
        end
        match_count_11 += 1
      end

      # --> action
       skip 
      # <-- action

      
      @state.type = type
      @state.channel = channel

    ensure
      # -> uncomment the next line to manually enable rule tracing
      # trace_out( __method__, 16 )

    end

    # main rule used to study the input at the current position,
    # and choose the proper lexer rule to call in order to
    # fetch the next token
    # 
    # usually, you don't make direct calls to this method,
    # but instead use the next_token method, which will
    # build and emit the actual next token
    def token!
      # at line 1:8: ( T__10 | T__11 | T__12 | T__13 | T__14 | T__15 | T__16 | T__17 | T__18 | T__19 | CONSTANT | ID | TEMPLATE | STRING | COMMENT | WS )
      alt_12 = 16
      alt_12 = @dfa12.predict( @input )
      case alt_12
      when 1
        # at line 1:10: T__10
        t__10!

      when 2
        # at line 1:16: T__11
        t__11!

      when 3
        # at line 1:22: T__12
        t__12!

      when 4
        # at line 1:28: T__13
        t__13!

      when 5
        # at line 1:34: T__14
        t__14!

      when 6
        # at line 1:40: T__15
        t__15!

      when 7
        # at line 1:46: T__16
        t__16!

      when 8
        # at line 1:52: T__17
        t__17!

      when 9
        # at line 1:58: T__18
        t__18!

      when 10
        # at line 1:64: T__19
        t__19!

      when 11
        # at line 1:70: CONSTANT
        constant!

      when 12
        # at line 1:79: ID
        id!

      when 13
        # at line 1:82: TEMPLATE
        template!

      when 14
        # at line 1:91: STRING
        string!

      when 15
        # at line 1:98: COMMENT
        comment!

      when 16
        # at line 1:106: WS
        ws!

      end
    end

    
    # - - - - - - - - - - DFA definitions - - - - - - - - - - -
    class DFA12 < ANTLR3::DFA
      EOT = unpack( 1, -1, 1, 11, 14, -1, 1, 11, 1, 20, 1, 11, 2, -1, 1, 
                    11, 1, 23, 1, -1 )
      EOF = unpack( 24, -1 )
      MIN = unpack( 1, 9, 1, 114, 1, 58, 13, -1, 1, 111, 1, 61, 1, 117, 
                    2, -1, 1, 112, 1, 48, 1, -1 )
      MAX = unpack( 1, 122, 1, 114, 1, 58, 13, -1, 1, 111, 1, 61, 1, 117, 
                    2, -1, 1, 112, 1, 122, 1, -1 )
      ACCEPT = unpack( 3, -1, 1, 3, 1, 5, 1, 6, 1, 7, 1, 8, 1, 9, 1, 10, 
                       1, 11, 1, 12, 1, 13, 1, 14, 1, 15, 1, 16, 3, -1, 
                       1, 4, 1, 2, 2, -1, 1, 1 )
      SPECIAL = unpack( 24, -1 )
      TRANSITION = [ 
        unpack( 2, 15, 1, -1, 2, 15, 18, -1, 1, 15, 1, -1, 1, 13, 1, 14, 
                2, -1, 1, 8, 1, 13, 1, 4, 1, 5, 1, 7, 1, -1, 1, 6, 2, -1, 
                1, 14, 10, -1, 1, 2, 1, 3, 1, 12, 1, 9, 3, -1, 26, 10, 4, 
                -1, 1, 11, 1, -1, 6, 11, 1, 1, 19, 11 ),
        unpack( 1, 16 ),
        unpack( 1, 17 ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 18 ),
        unpack( 1, 19 ),
        unpack( 1, 21 ),
        unpack(  ),
        unpack(  ),
        unpack( 1, 22 ),
        unpack( 10, 11, 7, -1, 26, 11, 4, -1, 1, 11, 1, -1, 26, 11 ),
        unpack(  )
      ].freeze
      
      ( 0 ... MIN.length ).zip( MIN, MAX ) do | i, a, z |
        if a > 0 and z < 0
          MAX[ i ] %= 0x10000
        end
      end
      
      @decision = 12
      

      def description
        <<-'__dfa_description__'.strip!
          1:1: Tokens : ( T__10 | T__11 | T__12 | T__13 | T__14 | T__15 | T__16 | T__17 | T__18 | T__19 | CONSTANT | ID | TEMPLATE | STRING | COMMENT | WS );
        __dfa_description__
      end
    end

    
    private
    
    def initialize_dfas
      super rescue nil
      @dfa12 = DFA12.new( self, 12 )

    end
  end # class Lexer < ANTLR3::Lexer

  at_exit { Lexer.main( ARGV ) } if __FILE__ == $0
end
# - - - - - - begin action @lexer::footer - - - - - -
# GroupFile.g


end # module Template
end # module ANTLR3

# - - - - - - end action @lexer::footer - - - - - - -
