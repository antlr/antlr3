#!/usr/bin/ruby
# encoding: utf-8

=begin LICENSE

[The "BSD licence"]
Copyright (c) 2009-2010 Kyle Yetter
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

 1. Redistributions of source code must retain the above copyright
    notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
    derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

=end

module ANTLR3
  

=begin rdoc ANTLR3::Constants

A simple module to keep track of the various built-in token types, channels, and
token names used by ANTLR throughout the runtime library.

=end
module Constants
  # built-in token channel IDs
  
  # the channel to which most tokens will be assigned
  DEFAULT = DEFAULT_CHANNEL = DEFAULT_TOKEN_CHANNEL = :default
  
  # the channel for tokens which should not be passed to a parser by a token stream
  HIDDEN  = HIDDEN_CHANNEL  = :hidden
  
  # flag used by recognizers during memoization to
  # represent a previous prediction failure
  MEMO_RULE_FAILED = -2
  
  # flag used by recognizers during memoization to indicate
  # that the rule has not been memoized yet
  MEMO_RULE_UNKNOWN = -1
  
  # built-in token types used internally by ANTLR3
  
  INVALID_TOKEN_TYPE = 0
  
  EOF = -1
  
  
  # Imaginary tree-navigation token type indicating the ascent after moving through the
  # children of a node
  UP = 3
  
  # Imaginary tree-navigation token type indicating a descent into the children of a node
  DOWN = 2
  
  # End of Rule (used internally by DFAs)
  EOR_TOKEN_TYPE = 1
  
  # The smallest possible value of non-builtin ANTLR-generated token types
  MIN_TOKEN_TYPE = 4
  
  # A hash mapping built in token types to their respective names
  # returning a string "<UNKNOWN: #{type}>" for non-builtin token
  # types
  BUILT_IN_TOKEN_NAMES = Hash.new do |h, k|
    "<UNKNOWN: #{ k }>"
  end
  
  BUILT_IN_TOKEN_NAMES.update( 
    0 => "<invalid>".freeze, 1 => "<EOR>".freeze, 
    2 => "<DOWN>".freeze, 3 => "<UP>".freeze, 
    -1 => "<EOF>".freeze
  )
  
  
end

include Constants
end
