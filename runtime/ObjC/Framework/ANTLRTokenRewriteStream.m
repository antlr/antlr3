//
//  ANTLRTokenRewriteStream.m
//  ANTLR
//
//  Created by Alan Condit on 6/19/10.
// [The "BSD licence"]
// Copyright (c) 2010 Alan Condit
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "ANTLRTokenRewriteStream.h"
#import "ANTLRRuntimeException.h"

static NSString *DEFAULT_PROGRAM_NAME = @"default";
static NSInteger PROGRAM_INIT_SIZE = 100;
static NSInteger MIN_TOKEN_INDEX = 0;

extern NSInteger debug;

// Define the rewrite operation hierarchy

@implementation ANTLRRewriteOperation

@synthesize instructionIndex;
@synthesize rwIndex;
@synthesize text;

+ (ANTLRRewriteOperation *) newANTLRRewriteOperation:(NSInteger)anIndex Text:(NSString *)theText
{
    return [[ANTLRRewriteOperation alloc] initWithIndex:anIndex Text:theText];
}
    
- (id) initWithIndex:(NSInteger)anIndex Text:(NSString *)theText
{
    if ((self = [super init]) != nil) {
        rwIndex = anIndex;
        text = theText;
    }
    return self;
}

/** Execute the rewrite operation by possibly adding to the buffer.
 *  Return the rwIndex of the next token to operate on.
 */
- (NSInteger) execute:(NSString *)buf
{
    return rwIndex;
}
    
- (NSString *)toString
{
    NSString *opName = [self className];
    int $index = [self indexOf:'$' inString:opName];
    opName = [opName substringWithRange:NSMakeRange($index+1, [opName length])];
    return [NSString stringWithFormat:@"<%@%d:\"%@\">", opName, rwIndex, opName];			
}

- (NSInteger) indexOf:(char)aChar inString:(NSString *)aString
{
    char indexedChar;

    for( int i = 0; i < [aString length]; i++ ) {
        indexedChar = [aString characterAtIndex:i];
        if (indexedChar == aChar) {
            return i;
        }
    }
    return -1;
}
                                                    
@end

@implementation ANTLRInsertBeforeOp

+ (ANTLRInsertBeforeOp *) newANTLRInsertBeforeOp:(NSInteger) anIndex Text:(NSString *)theText
{
    return [[ANTLRInsertBeforeOp alloc] initWithIndex:anIndex Text:theText];
}

- (id) initWithIndex:(NSInteger)anIndex Text:(NSString *)theText
{
    if ((self = [super initWithIndex:anIndex Text:theText]) != nil) {
        rwIndex = anIndex;
        text = theText;
    }
    return self;
}


- (NSInteger) execute:(NSMutableString *)buf
{
    [buf appendString:text];
    if ( ((ANTLRCommonToken *)[tokens objectAtIndex:rwIndex]).type != ANTLRTokenTypeEOF ) {
        [buf appendString:[[tokens objectAtIndex:rwIndex] text]];
    }
    return rwIndex+1;
}

@end
     
/** I'm going to try replacing range from x..y with (y-x)+1 ANTLRReplaceOp
 *  instructions.
 */
@implementation ANTLRReplaceOp

@synthesize lastIndex;

+ (ANTLRReplaceOp *) newANTLRReplaceOp:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString*)theText
{
    return [[ANTLRReplaceOp alloc] initWithIndex:from ToIndex:to Text:theText];
}

- (id) initWithIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText
{
    if ((self = [super initWithIndex:from Text:theText]) != nil) {
        lastIndex = to;
    }
    return self;
}
 
 
- (NSInteger) execute:(NSMutableString *)buf
{
    if ( text!=nil ) {
        [buf appendString:text];
    }
        return lastIndex+1;
}

- (NSString *)toString
{
    return [NSString stringWithFormat:@"<ANTLRReplaceOp@ %d..%d :>%@\n", rwIndex, lastIndex, text];
}

@end

@implementation ANTLRDeleteOp

+ (ANTLRDeleteOp *) newANTLRDeleteOp:(NSInteger)from ToIndex:(NSInteger)to
{
    // super(from To:to, null);
    return [[ANTLRDeleteOp alloc] initWithIndex:from ToIndex:to];
}

 - (id) initWithIndex:(NSInteger)from ToIndex:(NSInteger)to
{
    if ((self = [super initWithIndex:from ToIndex:to Text:nil]) != nil) {
        lastIndex = to;
    }
    return self;
}
     
- (NSString *)toString
{
    return [NSString stringWithFormat:@"<DeleteOp@ %d..%d\n",  rwIndex, lastIndex];
}

@end


@implementation ANTLRTokenRewriteStream

@synthesize programs;
@synthesize lastRewriteTokenIndexes;

+ (ANTLRTokenRewriteStream *)newANTLRTokenRewriteStream
{
    return [[ANTLRTokenRewriteStream alloc] init];
}

+ (ANTLRTokenRewriteStream *)newANTLRTokenRewriteStream:(id<ANTLRTokenSource>) aTokenSource
{
    return [[ANTLRTokenRewriteStream alloc] initWithTokenSource:aTokenSource];
}

+ (ANTLRTokenRewriteStream *)newANTLRTokenRewriteStream:(id<ANTLRTokenSource>) aTokenSource Channel:(NSInteger)aChannel
{
    return [[ANTLRTokenRewriteStream alloc] initWithTokenSource:aTokenSource Channel:aChannel];
}
 
- (id) init
{
    if ((self = [super init]) != nil) {
        programs = [ANTLRHashMap newANTLRHashMap];
        [programs addObject:[ANTLRMapElement newANTLRMapElementWithName:DEFAULT_PROGRAM_NAME Node:[ANTLRHashMap newANTLRHashMapWithLen:PROGRAM_INIT_SIZE]]];
        lastRewriteTokenIndexes = [ANTLRHashMap newANTLRHashMap];
    }
    return self;
}
 
- (id)initWithTokenSource:(id<ANTLRTokenSource>)aTokenSource
{
    if ((self = [super init]) != nil) {
        programs = [ANTLRHashMap newANTLRHashMap];
        [programs addObject:[ANTLRMapElement newANTLRMapElementWithName:DEFAULT_PROGRAM_NAME Node:[ANTLRHashMap newANTLRHashMapWithLen:PROGRAM_INIT_SIZE]]];
        lastRewriteTokenIndexes = [ANTLRHashMap newANTLRHashMap];
        tokenSource = aTokenSource;
    }
    return self;
}

- (id)initWithTokenSource:(id<ANTLRTokenSource>)aTokenSource Channel:(NSInteger)aChannel
{
    if ((self = [super init]) != nil) {
        programs = [ANTLRHashMap newANTLRHashMap];
        [programs addObject:[ANTLRMapElement newANTLRMapElementWithName:DEFAULT_PROGRAM_NAME Node:[ANTLRHashMap newANTLRHashMapWithLen:PROGRAM_INIT_SIZE]]];
        lastRewriteTokenIndexes = [ANTLRHashMap newANTLRHashMap];
        tokenSource = aTokenSource;
        channel = aChannel;
    }
    return self;
}
 
- (ANTLRHashMap *)getPrograms
{
    return programs;
}
 
- (void)setPrograms:(ANTLRHashMap *)aProgList
{
    programs = aProgList;
}

- (void) rollback:(NSInteger)instructionIndex
{
    [self rollback:DEFAULT_PROGRAM_NAME Index:instructionIndex];
}

/** Rollback the instruction stream for a program so that
 *  the indicated instruction (via instructionIndex) is no
 *  longer in the stream.  UNTESTED!
 */
- (void) rollback:(NSString *)programName Index:(NSInteger)anInstructionIndex
{
    id object;
    ANTLRHashMap *is;

    //    AMutableArray *is = [programs get(programName)];
    is = [self getPrograms];
    object = [is getName:programName];
    if ( is != nil ) {
#pragma warning this has to be fixed
        [programs insertObject:programName  atIndex:anInstructionIndex];
    }
}

- (void) deleteProgram
{
    [self deleteProgram:DEFAULT_PROGRAM_NAME];
}

/** Reset the program so that no instructions exist */
- (void) deleteProgram:(NSString *)programName
{
    [self rollback:programName Index:MIN_TOKEN_INDEX];
}

- (void) insertAfterToken:(id<ANTLRToken>)t Text:(NSString *)theText
{
    [self insertAfterProgNam:DEFAULT_PROGRAM_NAME Index:[t getTokenIndex] Text:theText];
}

- (void) insertAfterIndex:(NSInteger)anIndex Text:(NSString *)theText
{
    [self insertAfterProgNam:DEFAULT_PROGRAM_NAME Index:(NSInteger)anIndex Text:(NSString *)theText];
}

- (void) insertAfterProgNam:(NSString *)programName Index:(NSInteger)anIndex Text:(NSString *)theText
{
    // to insert after, just insert before next rwIndex (even if past end)
    [self insertBeforeProgName:programName Index:anIndex+1 Text:theText];
    //addToSortedRewriteList(programName, new InsertAfterOp(rwIndex,text));
}









- (void) insertBeforeToken:(id<ANTLRToken>)t Text:(NSString *)theText
{
    [self insertBeforeProgName:DEFAULT_PROGRAM_NAME Index:[t getTokenIndex] Text:theText];
}

- (void) insertBeforeIndex:(NSInteger)anIndex Text:(NSString *)theText
{
    [self insertBeforeProgName:DEFAULT_PROGRAM_NAME Index:anIndex Text:theText];
}

- (void) insertBeforeProgName:(NSString *)programName Index:(NSInteger)rwIndex Text:(NSString *)theText
{
    //addToSortedRewriteList(programName, new ANTLRInsertBeforeOp(rwIndex,text));
    ANTLRRewriteOperation *op = [ANTLRInsertBeforeOp newANTLRInsertBeforeOp:rwIndex Text:theText];
    ANTLRHashMap *rewrites = [self getProgram:programName];
    op.instructionIndex = [rewrites count];
    [rewrites addObject:op];		
}

- (void) replaceFromIndex:(NSInteger)anIndex Text:(NSString *)theText
{
    [self replaceProgNam:DEFAULT_PROGRAM_NAME FromIndex:anIndex ToIndex:anIndex Text:theText];
}

- (void) replaceFromIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText
{
    [self replaceProgNam:DEFAULT_PROGRAM_NAME FromIndex:from ToIndex:to Text:theText];
}

- (void) replaceFromToken:(id<ANTLRToken>)anIndexT Text:(NSString *)theText
{
    [self replaceProgNam:DEFAULT_PROGRAM_NAME FromIndex:[anIndexT getTokenIndex] ToIndex:[anIndexT getTokenIndex] Text:theText];
}

- (void) replaceFromToken:(id<ANTLRToken>)from ToToken:(id<ANTLRToken>)to Text:(NSString *)theText
{
    [self replaceProgNam:DEFAULT_PROGRAM_NAME FromIndex:[from getTokenIndex] ToIndex:[to getTokenIndex] Text:theText];
}

- (void) replaceProgNam:(NSString *)programName Token:(id<ANTLRToken>)from Token:(id<ANTLRToken>)to Text:(NSString *)theText
{
    [self replaceProgNam:programName FromIndex:[from getTokenIndex] ToIndex:[to getTokenIndex] Text:theText];
}
                         
- (void) replaceProgNam:(NSString *)programName FromIndex:(NSInteger)from ToIndex:(NSInteger)to Text:(NSString *)theText
{
    if ( from > to || from < 0 || to < 0 || to >= [tokens count] ) {
        @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"replace: range invalid: %d..%d size=%d\n", from, to, [tokens count]]];
    }
    ANTLRRewriteOperation *op = [ANTLRReplaceOp newANTLRReplaceOp:from ToIndex:to Text:theText];
    ANTLRHashMap *rewrites = (ANTLRHashMap *)[lastRewriteTokenIndexes getName:programName];
    op.instructionIndex = [rewrites count];
    [rewrites addObject:op];
}

- (void) delete:(NSInteger)anIndex
{
    [self delete:DEFAULT_PROGRAM_NAME  FromIndex:(NSInteger)anIndex  ToIndex:(NSInteger)anIndex];
}

- (void) delete:(NSInteger)from ToIndex:(NSInteger)to
{
    [self delete:DEFAULT_PROGRAM_NAME FromIndex:from ToIndex:to];
}

- (void) deleteToken:(id<ANTLRToken>)anIndexT
{
    [self delete:DEFAULT_PROGRAM_NAME FromIndex:[anIndexT getTokenIndex] ToIndex:[anIndexT getTokenIndex]];
}

- (void) deleteFromToken:(id<ANTLRToken>)from ToToken:(id<ANTLRToken>)to
{
    [self delete:DEFAULT_PROGRAM_NAME FromIndex:[from getTokenIndex] ToIndex:[to getTokenIndex]];
}

- (void) delete:(NSString *)programName FromToken:(id<ANTLRToken>)from ToToken:(id<ANTLRToken>)to
{
    [self replaceProgNam:programName FromIndex:[from getTokenIndex] ToIndex:[to getTokenIndex] Text:nil];
}

- (void) delete:(NSString *)programName FromIndex:(NSInteger)from ToIndex:(NSInteger)to
{
    [self replaceProgNam:programName FromIndex:from ToIndex:to Text:nil];
}

- (NSInteger)getLastRewriteTokenIndex
{
    return [self getLastRewriteTokenIndex:DEFAULT_PROGRAM_NAME];
}

- (NSInteger)getLastRewriteTokenIndex:(NSString *)programName
{
#pragma warning fix this to look up the hashed name
    NSInteger anInt = -1;
    ANTLRMapElement *node = [lastRewriteTokenIndexes lookup:programName Scope:0];
    if ( node != nil ) {
        anInt = [lastRewriteTokenIndexes hash:programName];
    }
    return anInt;
}

- (void)setLastRewriteTokenIndex:(NSString *)programName Index:(NSInteger)anInt
{
    [lastRewriteTokenIndexes insertObject:programName atIndex:anInt];
}

-(ANTLRHashMap *) getProgram:(NSString *)name
{
   ANTLRHashMap *is = (ANTLRHashMap *)[programs getName:name];
    if ( is == nil ) {
        is = [self initializeProgram:name];
    }
    return is;
}

-(ANTLRHashMap *) initializeProgram:(NSString *)name
{
    ANTLRHashMap *is = [ANTLRHashMap newANTLRHashMapWithLen:PROGRAM_INIT_SIZE];
    [is putName:name Node:nil];
    return is;
}

- (NSString *)toOriginalString
{
    [super fill];
    return [self toOriginalString:MIN_TOKEN_INDEX End:[tokens count]-1];
}

- (NSString *)toOriginalString:(NSInteger)start End:(NSInteger)end
{
    NSMutableString *buf = [NSMutableString stringWithCapacity:100];
    for (int i = start; i >= MIN_TOKEN_INDEX && i <= end && i< [tokens count]; i++) {
        if ( [[lastRewriteTokenIndexes objectAtIndex:i] type] != ANTLRTokenTypeEOF )
            [buf appendString:[[tokens objectAtIndex:i] text]];
    }
    return [NSString stringWithString:buf];
}

- (NSString *)toString
{
    [super fill];
    return [self toStringFromStart:MIN_TOKEN_INDEX ToEnd:[tokens count]-1];
}

- (NSString *)toString:(NSString *)programName
{
    [super fill];
    return [self toString:programName FromStart:MIN_TOKEN_INDEX ToEnd:[[programs objectAtIndex:MIN_TOKEN_INDEX] count]-1];
}

- (NSString *)toStringFromStart:(NSInteger)start ToEnd:(NSInteger)end
{
    return [self toString:DEFAULT_PROGRAM_NAME FromStart:start ToEnd:end];
}

- (NSString *)toString:(NSString *)programName FromStart:(NSInteger)start ToEnd:(NSInteger)end
{
    ANTLRHashMap *rewrites = (ANTLRHashMap *)[programs getName:programName];
    
    // ensure start/end are in range
    if ( end > [tokens count]-1 ) end = [tokens count]-1;
    if ( start < 0 )
        start = 0;
    
    if ( rewrites == nil || [rewrites count] == 0 ) {
        return [self toOriginalString:start End:end]; // no instructions to execute
    }
    NSMutableString *buf = [NSMutableString stringWithCapacity:100];
    
    // First, optimize instruction stream
    ANTLRHashMap *indexToOp = [self reduceToSingleOperationPerIndex:rewrites];
    
    // Walk buffer, executing instructions and emitting tokens
    int i = start;
    while ( i <= end && i < [tokens count] ) {
        ANTLRRewriteOperation *op = (ANTLRRewriteOperation *)[indexToOp objectAtIndex:i];
        [indexToOp setObject:nil atIndex:i]; // remove so any left have rwIndex size-1
        id<ANTLRToken>t = (id<ANTLRToken>) [tokens objectAtIndex:i];
        if ( op == nil ) {
            // no operation at that rwIndex, just dump token
            if ( t.type != ANTLRTokenTypeEOF )
                [buf appendString:t.text];
            i++; // move to next token
        }
        else {
            i = [op execute:buf]; // execute operation and skip
        }
    }
    
    // include stuff after end if it's last rwIndex in buffer
    // So, if they did an insertAfter(lastValidIndex, "foo"), include
    // foo if end==lastValidIndex.
    //if ( end == [tokens size]-1 ) {
    if ( end == [tokens count]-1 ) {
        // Scan any remaining operations after last token
        // should be included (they will be inserts).
        int i2 = 0;
        while ( i2 < [indexToOp count] - 1 ) {
            ANTLRRewriteOperation *op = [indexToOp objectAtIndex:i2];
            if ( op.rwIndex >= [tokens count]-1 ) {
                [buf appendString:op.text];
            }
        }
    }
    return [NSString stringWithString:buf];
}

/** We need to combine operations and report invalid operations (like
 *  overlapping replaces that are not completed nested).  Inserts to
 *  same rwIndex need to be combined etc...   Here are the cases:
 *
 *  I.i.u I.j.v								leave alone, nonoverlapping
 *  I.i.u I.i.v								combine: Iivu
 *
 *  R.i-j.u R.x-y.v	| i-j in x-y			delete first R
 *  R.i-j.u R.i-j.v							delete first R
 *  R.i-j.u R.x-y.v	| x-y in i-j			ERROR
 *  R.i-j.u R.x-y.v	| boundaries overlap	ERROR
 *
 *  I.i.u R.x-y.v | i in x-y				delete I
 *  I.i.u R.x-y.v | i not in x-y			leave alone, nonoverlapping
 *  R.x-y.v I.i.u | i in x-y				ERROR
 *  R.x-y.v I.x.u 							R.x-y.uv (combine, delete I)
 *  R.x-y.v I.i.u | i not in x-y			leave alone, nonoverlapping
 *
 *  I.i.u = insert u before op @ rwIndex i
 *  R.x-y.u = replace x-y indexed tokens with u
 *
 *  First we need to examine replaces.  For any replace op:
 *
 * 		1. wipe out any insertions before op within that range.
 *		2. Drop any replace op before that is contained completely within
 *         that range.
 *		3. Throw exception upon boundary overlap with any previous replace.
 *
 *  Then we can deal with inserts:
 *
 * 		1. for any inserts to same rwIndex, combine even if not adjacent.
 * 		2. for any prior replace with same left boundary, combine this
 *         insert with replace and delete this replace.
 * 		3. throw exception if rwIndex in same range as previous replace
 *
 *  Don't actually delete; make op null in list. Easier to walk list.
 *  Later we can throw as we add to rwIndex -> op map.
 *
 *  Note that I.2 R.2-2 will wipe out I.2 even though, technically, the
 *  inserted stuff would be before the replace range.  But, if you
 *  add tokens in front of a method body '{' and then delete the method
 *  body, I think the stuff before the '{' you added should disappear too.
 *
 *  Return a map from token rwIndex to operation.
 */
- (ANTLRHashMap *)reduceToSingleOperationPerIndex:(ANTLRHashMap *)rewrites
{
    //System.out.println("rewrites="+rewrites);
    if (debug > 1) NSLog(@"rewrites=%@\n", [rewrites getName:DEFAULT_PROGRAM_NAME]);
    // WALK REPLACES
    for (int i = 0; i < [rewrites count]; i++) {
        ANTLRRewriteOperation *op = (ANTLRRewriteOperation *)[rewrites objectAtIndex:i];
        if ( op==nil )
            continue;
        if ( !([[op class] isKindOfClass:[ANTLRReplaceOp class]]) )
            continue;
        ANTLRReplaceOp *rop = (ANTLRReplaceOp *)[rewrites objectAtIndex:i];
        // Wipe prior inserts within range
        //List inserts = getKindOfOps(rewrites, ANTLRInsertBeforeOp.class, i);
        ANTLRHashMap *inserts = [self getKindOfOps:rewrites KindOfClass:[ANTLRInsertBeforeOp class] Index:i];
        for (int j = 0; j < [inserts size]; j++) {
            ANTLRInsertBeforeOp *iop = (ANTLRInsertBeforeOp *)[inserts objectAtIndex:j];
            if ( iop.rwIndex >= rop.rwIndex && iop.rwIndex <= rop.lastIndex ) {
                // delete insert as it's a no-op.
                [rewrites insertObject:nil atIndex:iop.instructionIndex];
            }
        }
        // Drop any prior replaces contained within
        ANTLRHashMap *prevReplaces = [self getKindOfOps:rewrites KindOfClass:[ANTLRReplaceOp class] Index:i];
        for (int j = 0; j < [prevReplaces count]; j++) {
            ANTLRReplaceOp *prevRop = (ANTLRReplaceOp *) [prevReplaces objectAtIndex:j];
            if ( prevRop.rwIndex>=rop.rwIndex && prevRop.lastIndex <= rop.lastIndex ) {
                // delete replace as it's a no-op.
                [rewrites setObject:nil atIndex:prevRop.instructionIndex];
                continue;
            }
            // throw exception unless disjoint or identical
            BOOL disjoint = prevRop.lastIndex<rop.rwIndex || prevRop.rwIndex > rop.lastIndex;
            BOOL same = prevRop.rwIndex==rop.rwIndex && prevRop.lastIndex==rop.lastIndex;
            if ( !disjoint && !same ) {
                @throw [ANTLRIllegalArgumentException newException:
                        [NSString stringWithFormat:@"replace op boundaries of %@, overlap with previous %@\n", rop, prevRop]];
            }
        }
    }
    
    // WALK INSERTS
    for (int i = 0; i < [rewrites count]; i++) {
        ANTLRRewriteOperation *op = (ANTLRRewriteOperation *)[rewrites objectAtIndex:i];
        if ( op == nil )
            continue;
        if ( !([[op class] isKindOfClass:[ANTLRInsertBeforeOp class]]) )
            continue;
        ANTLRInsertBeforeOp *iop = (ANTLRInsertBeforeOp *)[rewrites objectAtIndex:i];
        // combine current insert with prior if any at same rwIndex
        ANTLRHashMap *prevInserts = (ANTLRHashMap *)[self getKindOfOps:rewrites KindOfClass:[ANTLRInsertBeforeOp class] Index:i];
        for (int j = 0; j < [prevInserts count]; j++) {
            ANTLRInsertBeforeOp *prevIop = (ANTLRInsertBeforeOp *) [prevInserts objectAtIndex:j];
            if ( prevIop.rwIndex == iop.rwIndex ) { // combine objects
                                                // convert to strings...we're in process of toString'ing
                                                // whole token buffer so no lazy eval issue with any templates
                iop.text = [self catOpText:iop.text PrevText:prevIop.text];
                // delete redundant prior insert
                [rewrites setObject:nil atIndex:prevIop.instructionIndex];
            }
        }
        // look for replaces where iop.rwIndex is in range; error
        ANTLRHashMap *prevReplaces = (ANTLRHashMap *)[self getKindOfOps:rewrites KindOfClass:[ANTLRReplaceOp class] Index:i];
        for (int j = 0; j < [prevReplaces count]; j++) {
            ANTLRReplaceOp *rop = (ANTLRReplaceOp *) [prevReplaces objectAtIndex:j];
            if ( iop.rwIndex == rop.rwIndex ) {
                rop.text = [self catOpText:iop.text PrevText:rop.text];
                [rewrites setObject:nil atIndex:i];  // delete current insert
                continue;
            }
            if ( iop.rwIndex >= rop.rwIndex && iop.rwIndex <= rop.lastIndex ) {
                @throw [ANTLRIllegalArgumentException newException:[NSString stringWithFormat:@"insert op %d within boundaries of previous %d", iop, rop]];
            }
        }
    }
    // System.out.println("rewrites after="+rewrites);
    ANTLRHashMap *m = [ANTLRHashMap newANTLRHashMapWithLen:15];
    for (int i = 0; i < [rewrites count]; i++) {
        ANTLRRewriteOperation *op = (ANTLRRewriteOperation *)[rewrites objectAtIndex:i];
        if ( op == nil )
            continue; // ignore deleted ops
        if ( [m objectAtIndex:op.rwIndex] != nil ) {
            @throw [ANTLRRuntimeException newException:@"should only be one op per rwIndex\n"];
        }
        //[m put(new Integer(op.rwIndex), op);
        [m setObject:op atIndex:op.rwIndex];
    }
    //System.out.println("rwIndex to op: "+m);
    if (debug > 1) NSLog(@"rwIndex to  op %d\n", (NSInteger)m);
    return m;
}

- (NSString *)catOpText:(id)a PrevText:(id)b
{
    NSString *x = @"";
    NSString *y = @"";
    if ( a != nil )
        x = [a toString];
    if ( b != nil )
        y = [b toString];
    return [NSString stringWithFormat:@"%@%@",x, y];
}

- (ANTLRHashMap *)getKindOfOps:(ANTLRHashMap *)rewrites KindOfClass:(Class)kind
{
    return [self getKindOfOps:rewrites KindOfClass:kind Index:[rewrites count]];
}

/** Get all operations before an rwIndex of a particular kind */
- (ANTLRHashMap *)getKindOfOps:(ANTLRHashMap *)rewrites KindOfClass:(Class)kind Index:(NSInteger)before
{
    ANTLRHashMap *ops = [ANTLRHashMap newANTLRHashMapWithLen:15];
    for (int i = 0; i < before && i < [rewrites count]; i++) {
        ANTLRRewriteOperation *op = (ANTLRRewriteOperation *)[rewrites objectAtIndex:i];
        if ( op == nil )
            continue; // ignore deleted
        if ( [op isKindOfClass:(Class)kind] )
            [ops addObject:op];
    }		
    return ops;
}

- (NSMutableString *)toDebugString
{
    return [self toDebugStringFromStart:MIN_TOKEN_INDEX ToEnd:[tokens count]-1];
}

- (NSMutableString *)toDebugStringFromStart:(NSInteger)start ToEnd:(NSInteger)end
{
    NSMutableString *buf = [NSMutableString stringWithCapacity:100];
    for (int i = start; i >= MIN_TOKEN_INDEX && i <= end && i < [tokens count]; i++) {
        [buf appendString:[[tokens objectAtIndex:i] text]];
    }
    return [NSString stringWithString:buf];
}

@end
