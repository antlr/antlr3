#import <Foundation/Foundation.h>
#import <ANTLR/ANTLR.h>
#import "PolyLexer.h"
#import "PolyParser.h"
// #import "PolyDifferentiator.h"
// #import "PolyPrinter.h"
// #import "Simplifier.h"


int main(int argc, const char *argv[])
{
    NSError *error;
    NSLog(@"starting polydiff\n");
	NSString *input = [NSString stringWithContentsOfFile:@"../../examples/polydiff/input"  encoding:NSASCIIStringEncoding error:&error];
	ANTLRStringStream *stream = [ANTLRStringStream newANTLRStringStream:input];
	NSLog(@"%@", input);

// BUILD AST
    PolyLexer *lex = [PolyLexer newPolyLexerWithCharStream:stream];
    CommonTokenStream *tokens = [CommonTokenStream newCommonTokenStreamWithTokenSource:lex];
    PolyParser *parser = [PolyParser newPolyParser:tokens];
    PolyParser_poly_return *r = [parser poly];
    NSLog(@"tree=%@", [r.tree toStringTree]);

#ifdef DONTUSENOMO
// DIFFERENTIATE
    CommonTreeNodeStream *nodes = [CommonTreeNodeStream newCommonTreeNodeStream:r.tree];
    [nodes setTokenStream:tokens];
    PolyDifferentiator *differ = [PolyDifferentiator newPolyDifferentiator:nodes];
    PolyDifferentiator_poly_return *r2 = [differ poly];
    NSLog("d/dx=%@", [r2.tree toStringTree]);

// SIMPLIFY / NORMALIZE
    nodes = [CommonTreeNodeStream newCommonTreeNodeStream:r2.tree];
    [nodes setTokenStream:tokens];
    Simplifier *reducer = [Simplifier newSimplifier:nodes];
    Simplifier_poly_return *r3 = [reducer poly];
    NSLog("simplified=%@", [r3.tree toStringTree]);

// CONVERT BACK TO POLYNOMIAL
    nodes = [CommonTreeNodeStream newCommonTreeNodeStream:r3.tree];
    [nodes setTokenStream:tokens];
    PolyPrinter *printer = [PolyPrinter newPolyPrinter:nodes];
    PolyPrinter_poly_return *r4 = [printer poly];
    NSLog( [r4.st toString]);
#endif

    NSLog(@"exiting PolyDiff\n");
    return 0;
}
