#!/usr/bin/ruby
# encoding: utf-8

module ANTLR3
  
  # 
  # The version of the ANTLR tool used while designing and
  # testing the current version of this library
  # 
  ANTLR_MAJOR_VERSION = 3
  ANTLR_MINOR_VERSION = 2
  ANTLR_PATCH_VERSION = 1
  ANTLR_VERSION = [ ANTLR_MAJOR_VERSION, ANTLR_MINOR_VERSION, ANTLR_PATCH_VERSION ].freeze
  ANTLR_VERSION_STRING = ANTLR_VERSION.join( '.' )
  ANTLR_VERSION_STRING.chomp!( '.0' )   # versioning drops minor version at 0
  ANTLR_VERSION_STRING.freeze
  
  # 
  # The version data for the current state the library itself
  # 
  MAJOR_VERSION = 1
  MINOR_VERSION = 8
  PATCH_VERSION = 5
  VERSION = [ MAJOR_VERSION, MINOR_VERSION, PATCH_VERSION ]
  VERSION_STRING = VERSION.join( '.' ).freeze
  
end
