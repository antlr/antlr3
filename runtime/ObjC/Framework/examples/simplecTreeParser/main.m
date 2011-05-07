#import <Cocoa/Cocoa.h>
#import "antlr3.h"
#import "SimpleCLexer.h"
#import "SimpleCParser.h"
#import "SimpleCWalker.h"
#import "stdio.h"
#include <unistd.h>

int main(int argc, const char * argv[]) {
    NSError *anError;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    char *inp = "/Users/acondit/source/antlr3/acondit_localhost/code/antlr/antlr3-main/runtime/ObjC/Framework/examples/simplecTreeParser/input";
    
/*
    if (argc < 2) {
        NSLog(@"provide the input file, please");
        return 1;
    }
 */
	
	// simply read in the input file in one gulp
	NSString *string = [NSString stringWithContentsOfFile:[NSString stringWithCString:inp encoding:NSASCIIStringEncoding] encoding:NSASCIIStringEncoding error:&anError];
	NSLog(@"input is : %@", string);

	// create a stream over the input, so the lexer can seek back and forth, but don't copy the string,
	// as we make sure it will not go away.
	// If the string would be coming from a volatile source, say a text field, we could opt to copy the string.
	// That way we could do the parsing in a different thread, and still let the user edit the original string.
	// But here we do it the simple way.
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:string];
	
	// Actually create the lexer feeding of the character stream.
	SimpleCLexer *lexer = [SimpleCLexer newSimpleCLexerWithCharStream:stream];
	
	// For fun, you could print all tokens the lexer recognized, but we can only do it once. After that
	// we would need to reset the lexer, and lex again.
//    id<ANTLRToken> currentToken;
//    while ((currentToken = [lexer nextToken]) && [currentToken type] != ANTLRTokenTypeEOF) {
//        NSLog(@"%@", currentToken);
//    }
//	  [lexer reset];
	
	// Since the parser needs to scan back and forth over the tokens, we put them into a stream, too.
	ANTLRCommonTokenStream *tokenStream = [ANTLRCommonTokenStream newANTLRCommonTokenStreamWithTokenSource:lexer];

	// Construct a parser and feed it the token stream.
	SimpleCParser *parser = [[SimpleCParser alloc] initWithTokenStream:tokenStream];
	
	// We start the parsing process by calling a parser rule. In theory you can call any parser rule here,
	// but it obviously has to match the input token stream. Otherwise parsing would fail.
	// Also watch out for internal dependencies in your grammar (e.g. you use a symbol table that's only
	// initialized when you call a specific parser rule).
	// This is a simple example, so we just call the top-most rule 'program'.
	// Since we want to parse the AST the parser builds, we just ask the returned object for that.
	ANTLRCommonTree *program_tree = [[parser program] getTree];

    NSLog(@"Reached end of first parse\n");
	// Print the matched tree as a Lisp-style string
	NSLog(@"tree: %@", [program_tree treeDescription]);
	
	// Create a new tree node stream that's feeding off of the root node (thus seeing the whole tree)
	ANTLRCommonTreeNodeStream *treeStream = [ANTLRCommonTreeNodeStream newANTLRCommonTreeNodeStream:program_tree];
	// tell the TreeNodeStream where the tokens originally came from, so we can retrieve arbitrary tokens and their text.
	[treeStream setTokenStream:tokenStream];
	
	// Create the treeparser instance, passing it the stream of nodes
	SimpleCWalker *walker = [[SimpleCWalker alloc] initWithStream:treeStream];
	// As with parsers, you can invoke any treeparser rule here.
	[walker program];

	// Whew, done. Release everything that we are responsible for.
	[lexer release];
	[stream release];
	[tokenStream release];
	[parser release];
	[treeStream release];
	[walker release];

	[pool release];

    // use this for ObjectAlloc on Tiger
    //while(1) sleep(5);
	return 0;
}