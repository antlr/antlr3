#!/usr/bin/ruby
# encoding: utf-8

require 'antlr3'

module ANTLR3
=begin rdoc ANTLR3::FilterMode

If a lexer grammar specifies the <tt>filter = true</t> option, the generated
Lexer code will include this module. It modifies the standard
<tt>next_token</tt> to catch RecognitionErrors and skip ahead in the input until
the token! method can match a token without raising a RecognitionError.

See http://www.antlr.org/wiki/display/ANTLR3/Lexical+filters for more info on
lexer filter mode.

=end
module FilterMode
  def next_token
    # if at end-of-file, return the EOF token
    @input.peek == ANTLR3::EOF and return ANTLR3::EOF_TOKEN
    
    @state.token                = nil
    @state.channel              = ANTLR3::DEFAULT_CHANNEL
    @state.token_start_position = @input.index
    @state.token_start_column   = @input.column
    @state.token_start_line     = @input.line
    @state.text                 = nil
    @state.backtracking         = 1
    
    m = @input.mark
    token!
    @input.release( m )
    emit
    return @state.token
  rescue ANTLR3::BacktrackingFailed
    # token! backtracks with synpred at backtracking==2
    # and we set the synpredgate to allow actions at level 1.
    @input.rewind( m )
    @input.consume # advance one char and try again
    retry
  rescue ANTLR3::Error::RecognitionError => re
    # shouldn't happen in backtracking mode, but...
    report_error( re )
    recover( re )
  ensure
    @state.backtracking = 0
  end
  
  def memoize( rule, start_index, success )
    super( rule, start_index, success ) if @state.backtracking > 1
  end
  
  def already_parsed_rule?( rule )
    @state.backtracking > 1 ? super( rule ) : false
  end
end
end
