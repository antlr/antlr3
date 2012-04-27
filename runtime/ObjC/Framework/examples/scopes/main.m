#import <Foundation/Foundation.h>
#import <ANTLR/ANTLR.h>
#import "SymbolTableLexer.h"
#import "SymbolTableParser.h"

int main()
{
    NSError *error;
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *string = [NSString stringWithContentsOfFile:@"/Users/acondit/source/antlr/code/antlr3/runtime/ObjC/Framework/examples/scopes/input" encoding:NSASCIIStringEncoding error:&error];
	NSLog(@"input is : %@", string);
	ANTLRStringStream *stream = [[ANTLRStringStream alloc] initWithStringNoCopy:string];
	SymbolTableLexer *lexer = [[SymbolTableLexer alloc] initWithCharStream:stream];
	
//	CommonToken *currentToken;
//	while ((currentToken = [lexer nextToken]) && currentToken.type != TokenTypeEOF) {
//		NSLog(@"%@", currentToken);
//	}
	
	CommonTokenStream *tokens = [[CommonTokenStream alloc] initWithTokenSource:lexer];
	SymbolTableParser *parser = [[SymbolTableParser alloc] initWithTokenStream:tokens];
	[parser prog];

	[lexer release];
	[stream release];
	[tokens release];
	[parser release];
	
	[pool release];
	return 0;
}