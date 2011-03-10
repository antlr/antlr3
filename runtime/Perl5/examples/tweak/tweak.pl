#!perl

use strict;
use warnings;

use ANTLR::Runtime::ANTLRFileStream;
use ANTLR::Runtime::TokenRewriteStream;
use TLexer;
use TParser;

my $input = ANTLR::Runtime::ANTLRFileStream->new({ file_name => $ARGV[0] });
my $lexer = TLexer->new({ input => $input });
my $tokens = ANTLR::Runtime::TokenRewriteStream({ token_source => $lexer });
my $parser = TParser->new({ input => $tokens });
$parser->program();
print "$tokens\n";
