#!/usr/bin/ruby
# encoding: utf-8

=begin      ::about::
author:     Kyle Yetter <kcy5b@yahoo.com>
created on: March 19, 2010
purpose:    Loads the ANTLR recognition code for ANTLR Template Group files
=end

require 'antlr3/template/group-file-lexer'
require 'antlr3/template/group-file-parser'

module ANTLR3
module Template
class Group
  Lexer  = GroupFile::Lexer
  Parser = GroupFile::Parser
end
end
end
