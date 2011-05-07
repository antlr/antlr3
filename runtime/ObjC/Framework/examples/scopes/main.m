#import <Cocoa/Cocoa.h>
#import <antlr3.h>
#import "SymbolTableLexer.h"
#import "SymbolTableParser.h"

int main() {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *string = [NSString stringWithContentsOfFile:@"/Users/acondit/source/antlr3/acondit_localhost/code/antlr/antlr3-main/runtime/ObjC/Framework/examples/scopes/input"];
	NSLog(@"input is : %@", string);
	ANTLRStringStream *stream = [[ANTLRStringStream alloc] initWithStringNoCopy:string];
	SymbolTableLexer *lexer = [[SymbolTableLexer alloc] initWithCharStream:stream];
	
//	ANTLRCommonToken *currentToken;
//	while ((currentToken = [lexer nextToken]) && [currentToken getType] != ANTLRTokenTypeEOF) {
//		NSLog(@"%@", currentToken);
//	}
	
	ANTLRCommonTokenStream *tokens = [[ANTLRCommonTokenStream alloc] initWithTokenSource:lexer];
	SymbolTableParser *parser = [[SymbolTableParser alloc] initWithTokenStream:tokens];
	[parser prog];

	[lexer release];
	[stream release];
	[tokens release];
	[parser release];
	
	[pool release];
	return 0;
}