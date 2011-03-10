#import <Cocoa/Cocoa.h>
#import "CombinedLexer.h"
#import "antlr3.h"

int main(int argc, const char * argv[])
{
    NSLog(@"starting combined\n");
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString *string = @"xyyyyaxyyyyb";
	NSLog(@"%@", string);
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:string];
	CombinedLexer *lexer = [CombinedLexer newCombinedLexerWithCharStream:stream];
	id<ANTLRToken> currentToken;
	while ((currentToken = [lexer nextToken]) && [currentToken getType] != ANTLRTokenTypeEOF) {
		NSLog(@"%@", currentToken);
	}
	[lexer release];
	[stream release];
	
	[pool release];
    NSLog(@"exiting combined\n");
	return 0;
}