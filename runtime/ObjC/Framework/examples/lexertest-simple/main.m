#import <Cocoa/Cocoa.h>
#import "TestLexer.h"
#import "antlr3.h"
#import <unistd.h>

int main(int argc, const char * argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:@"abB9Cdd44"];
	TestLexer *lexer = [[TestLexer alloc] initWithCharStream:stream];
	id<ANTLRToken> currentToken;
	while ((currentToken = [[lexer nextToken] retain]) && [currentToken getType] != ANTLRTokenTypeEOF) {
		NSLog(@"%@", currentToken);
	}
	[lexer release];
	[stream release];
	
	[pool release];
    // sleep for objectalloc
    // while (1) sleep(60);
	return 0;
}