#import <Foundation/Foundation.h>
#import "CombinedLexer.h"
#import <ANTLR/ANTLR.h>

int main(int argc, const char * argv[])
{
    NSLog(@"starting combined\n");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *string = @"xyyyyaxyyyyb";
	NSLog(@"%@", string);
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:string];
	CombinedLexer *lexer = [CombinedLexer newCombinedLexerWithCharStream:stream];
	id<Token> currentToken;
	while ((currentToken = [lexer nextToken]) && currentToken.type != TokenTypeEOF) {
		NSLog(@"%@", currentToken);
	}
	[lexer release];
	[stream release];
	
	[pool release];
    NSLog(@"exiting combined\n");
	return 0;
}