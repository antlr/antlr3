#import <Cocoa/Cocoa.h>
#import "antlr3.h"
#import "TreeRewriteLexer.h"
#import "TreeRewriteParser.h"
//#import "stdio.h"
//#include <unistd.h>

int main() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"23 42"];
	TreeRewriteLexer *lexer = [TreeRewriteLexer newTreeRewriteLexerWithCharStream:stream];
	
//    id<ANTLRToken> currentToken;
//    while ((currentToken = [lexer nextToken]) && [currentToken type] != ANTLRTokenTypeEOF) {
//        NSLog(@"%@", currentToken);
//    }
	
	ANTLRCommonTokenStream *tokenStream = [ANTLRCommonTokenStream newANTLRCommonTokenStreamWithTokenSource:lexer];
	TreeRewriteParser *parser = [[TreeRewriteParser alloc] initWithTokenStream:tokenStream];
	ANTLRCommonTree *rule_tree = [[parser rule] getTree];
	NSLog(@"tree: %@", [rule_tree treeDescription]);
//	ANTLRCommonTreeNodeStream *treeStream = [[ANTLRCommonTreeNodeStream alloc] initWithTree:program_tree];
//	SimpleCTP *walker = [[SimpleCTP alloc] initWithTreeNodeStream:treeStream];
//	[walker program];

	[lexer release];
	[stream release];
	[tokenStream release];
	[parser release];
//	[treeStream release];
//	[walker release];

	[pool release];
    // sleep for objectalloc
    // while(1) sleep(60);
	return 0;
}