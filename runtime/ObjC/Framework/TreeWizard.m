//
//  ANTLRTreeWizard.m
//  ANTLR
//
//  Created by Alan Condit on 6/18/10.
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

#import "ANTLRTreeWizard.h"
#import "ANTLRTreePatternLexer.h"
#import "ANTLRTreePatternParser.h"
#import "ANTLRIntArray.h"

@implementation ANTLRVisitor

+ (ANTLRVisitor *)newANTLRVisitor:(NSInteger)anAction Actor:(id)anActor Object:(id)anObject1 Object:(id)anObject2
{
    return [[ANTLRVisitor alloc] initWithAction:anAction Actor:(id)anActor Object:(id)anObject1 Object:(id)anObject2];
}

- (id) initWithAction:(NSInteger)anAction Actor:(id)anActor Object:(id)anObject1 Object:(id)anObject2
{
    if ((self = [super init]) != nil) {
        action = anAction;
        actor = anActor;
        if ( actor ) [actor retain];
        object1 = anObject1;
        if ( object1 ) [object1 retain];
        object2 = anObject2;
        if ( object2 ) [object2 retain];
    }
    return self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRVisitor" );
#endif
    if ( actor ) [actor release];
    if ( object1 ) [object1 release];
    if ( object2 ) [object2 release];
    [super dealloc];
}

- (void) visit:(ANTLRCommonTree *)t Parent:(ANTLRCommonTree *)parent ChildIndex:(NSInteger)childIndex Map:(ANTLRMap *)labels
{
    switch (action) {
        case 0:
            [(ANTLRMap *)object2 /* labels */ clear];
            if ( [(ANTLRTreeWizard *)actor _parse:t Pattern:object1/* tpattern */ Map:object2 /* labels */] ) {
                [self visit:t Parent:parent ChildIndex:childIndex Map:object2 /* labels */];
            }
            break;
        case 1:
            if ( [(ANTLRTreeWizard *)actor _parse:t Pattern:object1/* tpattern */ Map:nil] ) {
                [(AMutableArray *)object2/* subtrees */ addObject:t];
            }
            break;
    }
    // [self visit:t];
    return;
}

- (void) visit:(ANTLRCommonTree *)t
{
    [object1 addObject:t];
    return;
}

@synthesize action;
@synthesize actor;
@synthesize object1;
@synthesize object2;
@end

/** When using %label:TOKENNAME in a tree for parse(), we must
 *  track the label.
 */
@implementation ANTLRTreePattern

@synthesize label;
@synthesize hasTextArg;

+ (ANTLRCommonTree *)newANTLRTreePattern:(id<ANTLRToken>)payload
{
    return (ANTLRCommonTree *)[[ANTLRTreePattern alloc] initWithToken:payload];
}

- (id) initWithToken:(id<ANTLRToken>)payload
{
    self = [super initWithToken:payload];
    if ( self != nil ) {
    }
    return (ANTLRCommonTree *)self;
}

- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRTreePattern" );
#endif
    if ( label ) [label release];
    [super dealloc];
}

- (NSString *)toString
{
    if ( label != nil ) {
        return [NSString stringWithFormat:@"\% %@ : %@", label, [super toString]];
    }
    else {
        return [super toString];				
    }
}

@end

@implementation ANTLRWildcardTreePattern

+ (ANTLRWildcardTreePattern *)newANTLRWildcardTreePattern:(id<ANTLRToken>)payload
{
    return(ANTLRWildcardTreePattern *)[[ANTLRWildcardTreePattern alloc] initWithToken:(id<ANTLRToken>)payload];
}

- (id) initWithToken:(id<ANTLRToken>)payload
{
    self = [super initWithToken:payload];
    if ( self != nil ) {
    }
    return self;
}

@end

/** This adaptor creates TreePattern objects for use during scan() */
@implementation ANTLRTreePatternTreeAdaptor

+ (ANTLRTreePatternTreeAdaptor *)newTreeAdaptor
{
    return [[ANTLRTreePatternTreeAdaptor alloc] init];
}

- (id) init
{
    self = [super init];
    if ( self != nil ) {
    }
    return self;
}

- (ANTLRCommonTree *)createTreePattern:(id<ANTLRToken>)payload
{
    return (ANTLRCommonTree *)[super create:payload];
}
          
@end

@implementation ANTLRTreeWizard

// TODO: build indexes for the wizard

/** During fillBuffer(), we can make a reverse index from a set
 *  of token types of interest to the list of indexes into the
 *  node stream.  This lets us convert a node pointer to a
 *  stream index semi-efficiently for a list of interesting
 *  nodes such as function definition nodes (you'll want to seek
 *  to their bodies for an interpreter).  Also useful for doing
 *  dynamic searches; i.e., go find me all PLUS nodes.
 protected Map tokenTypeToStreamIndexesMap;
 
 ** If tokenTypesToReverseIndex set to INDEX_ALL then indexing
 *  occurs for all token types.
 public static final Set INDEX_ALL = new HashSet();
 
 ** A set of token types user would like to index for faster lookup.
 *  If this is INDEX_ALL, then all token types are tracked.  If nil,
 *  then none are indexed.
 protected Set tokenTypesToReverseIndex = nil;
 */

+ (ANTLRTreeWizard *) newANTLRTreeWizard:(id<ANTLRTreeAdaptor>)anAdaptor
{
    return [[ANTLRTreeWizard alloc] initWithAdaptor:anAdaptor];
}

+ (ANTLRTreeWizard *)newANTLRTreeWizard:(id<ANTLRTreeAdaptor>)anAdaptor Map:(ANTLRMap *)aTokenNameToTypeMap
{
    return [[ANTLRTreeWizard alloc] initWithAdaptor:anAdaptor Map:aTokenNameToTypeMap];
}

+ (ANTLRTreeWizard *)newANTLRTreeWizard:(id<ANTLRTreeAdaptor>)anAdaptor TokenNames:(NSArray *)theTokNams
{
    return [[ANTLRTreeWizard alloc] initWithTokenNames:anAdaptor TokenNames:theTokNams];
}

+ (ANTLRTreeWizard *)newANTLRTreeWizardWithTokenNames:(NSArray *)theTokNams
{
    return [[ANTLRTreeWizard alloc] initWithTokenNames:theTokNams];
}

- (id) init
{
    if ((self = [super init]) != nil) {
    }
    return self;
}

- (id) initWithAdaptor:(id<ANTLRTreeAdaptor>)anAdaptor
{
    if ((self = [super init]) != nil) {
        adaptor = anAdaptor;
        if ( adaptor ) [adaptor retain];
    }
    return self;
}
            
- (id) initWithAdaptor:(id<ANTLRTreeAdaptor>)anAdaptor Map:(ANTLRMap *)aTokenNameToTypeMap
{
    if ((self = [super init]) != nil) {
        adaptor = anAdaptor;
        if ( adaptor ) [adaptor retain];
        tokenNameToTypeMap = aTokenNameToTypeMap;
   }
    return self;
}

- (id) initWithTokenNames:(NSArray *)theTokNams
{
    if ((self = [super init]) != nil) {
#pragma warning Fix initWithTokenNames.
        // adaptor = anAdaptor;
        //tokenNameToTypeMap = aTokenNameToTypeMap;
        tokenNameToTypeMap = [[self computeTokenTypes:theTokNams] retain];
    }
    return self;
}
             
- (id) initWithTokenNames:(id<ANTLRTreeAdaptor>)anAdaptor TokenNames:(NSArray *)theTokNams
{
    if ((self = [super init]) != nil) {
        adaptor = anAdaptor;
        if ( adaptor ) [adaptor retain];
        // tokenNameToTypeMap = aTokenNameToTypeMap;
        tokenNameToTypeMap = [[self computeTokenTypes:theTokNams] retain];
    }
    return self;
}
            
- (void) dealloc
{
#ifdef DEBUG_DEALLOC
    NSLog( @"called dealloc in ANTLRTreePatternTreeAdaptor" );
#endif
    if ( adaptor ) [adaptor release];
    if ( tokenNameToTypeMap ) [tokenNameToTypeMap release];
    [super dealloc];
}

/** Compute a Map<String, Integer> that is an inverted index of
 *  tokenNames (which maps int token types to names).
 */
- (ANTLRMap *)computeTokenTypes:(NSArray *)theTokNams
{
    ANTLRMap *m = [ANTLRMap newANTLRMap];
    if ( theTokNams == nil ) {
        return m;
    }
    for (int ttype = ANTLRTokenTypeMIN; ttype < [theTokNams count]; ttype++) {
        NSString *name = (NSString *) [theTokNams objectAtIndex:ttype];
        [m putName:name TType:ttype];
    }
    return m;
}

/** Using the map of token names to token types, return the type. */
- (NSInteger)getTokenType:(NSString *)tokenName
{
    if ( tokenNameToTypeMap == nil ) {
        return ANTLRTokenTypeInvalid;
    }
    NSInteger aTType = (NSInteger)[tokenNameToTypeMap getTType:tokenName];
    if ( aTType != -1 ) {
        return aTType;
    }
    return ANTLRTokenTypeInvalid;
}

/** Walk the entire tree and make a node name to nodes mapping.
 *  For now, use recursion but later nonrecursive version may be
 *  more efficient.  Returns Map<Integer, List> where the List is
 *  of your AST node type.  The Integer is the token type of the node.
 *
 *  TODO: save this index so that find and visit are faster
 */
- (ANTLRMap *)index:(ANTLRCommonTree *)t
{
    ANTLRMap *m = [ANTLRMap newANTLRMap];
    [self _index:t Map:m];
    return m;
}

/** Do the work for index */
- (void) _index:(ANTLRCommonTree *)t Map:(ANTLRMap *)m
{
    if ( t==nil ) {
        return;
    }
#pragma warning Fix _index use of ANTLRMap.
    NSInteger ttype = [adaptor getType:t];
    ANTLRMap *elements = (ANTLRMap *)[m getName:ttype];
    if ( elements == nil ) {
        elements = [ANTLRMap newANTLRMapWithLen:100];
        [m putNode:ttype Node:elements];
    }
    [elements addObject:t];
    int n = [adaptor getChildCount:t];
    for (int i=0; i<n; i++) {
        ANTLRCommonTree * child = [adaptor getChild:t At:i];
        [self _index:child Map:m];
    }
}

/** Return a List of tree nodes with token type ttype */
- (AMutableArray *)find:(ANTLRCommonTree *)t Type:(NSInteger)ttype
{
#ifdef DONTUSENOMO
    final List nodes = new ArrayList();
    visit(t, ttype, new TreeWizard.Visitor() {
        public void visit(Object t) {
            [nodes addObject t];
        }
    } );
#endif
    AMutableArray *nodes = [AMutableArray arrayWithCapacity:100];
    ANTLRVisitor *contextVisitor = [ANTLRVisitor newANTLRVisitor:3 Actor:self Object:(id)nodes Object:nil];
    [self visit:t Type:ttype Visitor:contextVisitor];
    return nodes;
}

/** Return a List of subtrees matching pattern. */
- (AMutableArray *)find:(ANTLRCommonTree *)t Pattern:(NSString *)pattern
{
    AMutableArray *subtrees = [AMutableArray arrayWithCapacity:100];
    // Create a TreePattern from the pattern
    ANTLRTreePatternLexer *tokenizer = [ANTLRTreePatternLexer newANTLRTreePatternLexer:pattern];
    ANTLRTreePatternParser *parser = [ANTLRTreePatternParser newANTLRTreePatternParser:tokenizer
                                                                                     Wizard:self
                                                                                    Adaptor:[ANTLRTreePatternTreeAdaptor newTreeAdaptor]];
    ANTLRCommonTree *tpattern = (ANTLRCommonTree *)[parser pattern];
    // don't allow invalid patterns
    if ( tpattern == nil ||
        [tpattern isNil] ||
        [tpattern class] == [ANTLRWildcardTreePattern class] )
    {
        return nil;
    }
    int rootTokenType = [tpattern type];
#ifdef DONTUSENOMO
    visit(t, rootTokenType, new TreeWizard.ContextVisitor() {
        public void visit(Object t, Object parent, int childIndex, Map labels) {
            if ( _parse(t, tpattern, null) ) {
                subtrees.add(t);
            }
        }
    } );
#endif
    ANTLRVisitor *contextVisitor = [ANTLRVisitor newANTLRVisitor:1 Actor:self Object:tpattern Object:subtrees];
    [self visit:t Type:rootTokenType Visitor:contextVisitor];
    return subtrees;
}

- (ANTLRTreeWizard *)findFirst:(ANTLRCommonTree *) t Type:(NSInteger)ttype
{
    return nil;
}

- (ANTLRTreeWizard *)findFirst:(ANTLRCommonTree *) t Pattern:(NSString *)pattern
{
    return nil;
}

/** Visit every ttype node in t, invoking the visitor.  This is a quicker
 *  version of the general visit(t, pattern) method.  The labels arg
 *  of the visitor action method is never set (it's nil) since using
 *  a token type rather than a pattern doesn't let us set a label.
 */
- (void) visit:(ANTLRCommonTree *)t Type:(NSInteger)ttype Visitor:(ANTLRVisitor *)visitor
{
    [self _visit:t Parent:nil ChildIndex:0 Type:ttype Visitor:visitor];
}

/** Do the recursive work for visit */
- (void) _visit:(ANTLRCommonTree *)t
         Parent:(ANTLRCommonTree *)parent
     ChildIndex:(NSInteger)childIndex
           Type:(NSInteger)ttype
        Visitor:(ANTLRVisitor *)visitor
{
    if ( t == nil ) {
        return;
    }
    if ( [adaptor getType:t] == ttype ) {
        [visitor visit:t Parent:parent ChildIndex:childIndex Map:nil];
    }
    int n = [adaptor getChildCount:t];
    for (int i=0; i<n; i++) {
        ANTLRCommonTree * child = [adaptor getChild:t At:i];
        [self _visit:child Parent:t ChildIndex:i Type:ttype Visitor:visitor];
    }
}

/** For all subtrees that match the pattern, execute the visit action.
 *  The implementation uses the root node of the pattern in combination
 *  with visit(t, ttype, visitor) so nil-rooted patterns are not allowed.
 *  Patterns with wildcard roots are also not allowed.
 */
- (void)visit:(ANTLRCommonTree *)t Pattern:(NSString *)pattern Visitor:(ANTLRVisitor *)visitor
{
    // Create a TreePattern from the pattern
    ANTLRTreePatternLexer *tokenizer = [ANTLRTreePatternLexer newANTLRTreePatternLexer:pattern];
    ANTLRTreePatternParser *parser =
    [ANTLRTreePatternParser newANTLRTreePatternParser:tokenizer Wizard:self Adaptor:[ANTLRTreePatternTreeAdaptor newTreeAdaptor]];
    ANTLRCommonTree *tpattern = [parser pattern];
    // don't allow invalid patterns
    if ( tpattern == nil ||
        [tpattern isNil] ||
        [tpattern class] == [ANTLRWildcardTreePattern class] )
    {
        return;
    }
    ANTLRMapElement *labels = [ANTLRMap newANTLRMap]; // reused for each _parse
    int rootTokenType = [tpattern type];
#pragma warning This is another one of those screwy nested constructs that I have to figure out
#ifdef DONTUSENOMO
    visit(t, rootTokenType, new TreeWizard.ContextVisitor() {
        public void visit(Object t, Object parent, int childIndex, Map unusedlabels) {
            // the unusedlabels arg is null as visit on token type doesn't set.
            labels.clear();
            if ( _parse(t, tpattern, labels) ) {
                visitor.visit(t, parent, childIndex, labels);
            }
        }
    });
#endif
    ANTLRVisitor *contextVisitor = [ANTLRVisitor newANTLRVisitor:0 Actor:self Object:tpattern Object:labels];
    [self visit:t Type:rootTokenType Visitor:contextVisitor];
}

/** Given a pattern like (ASSIGN %lhs:ID %rhs:.) with optional labels
 *  on the various nodes and '.' (dot) as the node/subtree wildcard,
 *  return true if the pattern matches and fill the labels Map with
 *  the labels pointing at the appropriate nodes.  Return false if
 *  the pattern is malformed or the tree does not match.
 *
 *  If a node specifies a text arg in pattern, then that must match
 *  for that node in t.
 *
 *  TODO: what's a better way to indicate bad pattern? Exceptions are a hassle 
 */
- (BOOL)parse:(ANTLRCommonTree *)t Pattern:(NSString *)pattern Map:(ANTLRMap *)labels
{
#ifdef DONTUSENOMO
    TreePatternLexer tokenizer = new TreePatternLexer(pattern);
    TreePatternParser parser =
    new TreePatternParser(tokenizer, this, new TreePatternTreeAdaptor());
    TreePattern tpattern = (TreePattern)parser.pattern();
    /*
     System.out.println("t="+((Tree)t).toStringTree());
     System.out.println("scant="+tpattern.toStringTree());
     */
    boolean matched = _parse(t, tpattern, labels);
    return matched;
#endif
    ANTLRTreePatternLexer *tokenizer = [ANTLRTreePatternLexer newANTLRTreePatternLexer:pattern];
    ANTLRTreePatternParser *parser = [ANTLRTreePatternParser newANTLRTreePatternParser:tokenizer
                                                                                Wizard:self
                                                                               Adaptor:[ANTLRTreePatternTreeAdaptor newTreeAdaptor]];
    ANTLRCommonTree *tpattern = [parser pattern];
    /*
     System.out.println("t="+((Tree)t).toStringTree());
     System.out.println("scant="+tpattern.toStringTree());
     */
    //BOOL matched = [self _parse:t Pattern:tpattern Map:labels];
    //return matched;
    return [self _parse:t Pattern:tpattern Map:labels];
}

- (BOOL) parse:(ANTLRCommonTree *)t Pattern:(NSString *)pattern
{
    return [self parse:t Pattern:pattern Map:nil];
}

/** Do the work for parse. Check to see if the t2 pattern fits the
 *  structure and token types in t1.  Check text if the pattern has
 *  text arguments on nodes.  Fill labels map with pointers to nodes
 *  in tree matched against nodes in pattern with labels.
 */
- (BOOL) _parse:(ANTLRCommonTree *)t1 Pattern:(ANTLRCommonTree *)aTPattern Map:(ANTLRMap *)labels
{
    ANTLRTreePattern *tpattern;
    // make sure both are non-nil
    if ( t1 == nil || aTPattern == nil ) {
        return NO;
    }
    if ( [aTPattern isKindOfClass:[ANTLRWildcardTreePattern class]] ) {
        tpattern = (ANTLRTreePattern *)aTPattern;
    }
    // check roots (wildcard matches anything)
    if ( [tpattern class] != [ANTLRWildcardTreePattern class] ) {
        if ( [adaptor getType:t1] != [tpattern type] )
            return NO;
        // if pattern has text, check node text
        if ( tpattern.hasTextArg && ![[adaptor getText:t1] isEqualToString:[tpattern text]] ) {
            return NO;
        }
    }
    if ( tpattern.label != nil && labels!=nil ) {
        // map label in pattern to node in t1
        [labels putName:tpattern.label Node:t1];
    }
    // check children
    int n1 = [adaptor getChildCount:t1];
    int n2 = [tpattern getChildCount];
    if ( n1 != n2 ) {
        return NO;
    }
    for (int i=0; i<n1; i++) {
        ANTLRCommonTree * child1 = [adaptor getChild:t1 At:i];
        ANTLRCommonTree *child2 = (ANTLRCommonTree *)[tpattern getChild:i];
        if ( ![self _parse:child1 Pattern:child2 Map:labels] ) {
            return NO;
        }
    }
    return YES;
}

/** Create a tree or node from the indicated tree pattern that closely
 *  follows ANTLR tree grammar tree element syntax:
 *
 * 		(root child1 ... child2).
 *
 *  You can also just pass in a node: ID
 * 
 *  Any node can have a text argument: ID[foo]
 *  (notice there are no quotes around foo--it's clear it's a string).
 *
 *  nil is a special name meaning "give me a nil node".  Useful for
 *  making lists: (nil A B C) is a list of A B C.
 */
- (ANTLRCommonTree *) createTree:(NSString *)pattern
{
    ANTLRTreePatternLexer *tokenizer = [ANTLRTreePatternLexer newANTLRTreePatternLexer:pattern];
    ANTLRTreePatternParser *parser = [ANTLRTreePatternParser newANTLRTreePatternParser:tokenizer Wizard:self Adaptor:adaptor];
    ANTLRCommonTree * t = [parser pattern];
    return t;
}

/** Compare t1 and t2; return true if token types/text, structure match exactly.
 *  The trees are examined in their entirety so that (A B) does not match
 *  (A B C) nor (A (B C)). 
 // TODO: allow them to pass in a comparator
 *  TODO: have a version that is nonstatic so it can use instance adaptor
 *
 *  I cannot rely on the tree node's equals() implementation as I make
 *  no constraints at all on the node types nor interface etc... 
 */
- (BOOL)equals:(id)t1 O2:(id)t2 Adaptor:(id<ANTLRTreeAdaptor>)anAdaptor
{
    return [self _equals:t1 O2:t2 Adaptor:anAdaptor];
}

/** Compare type, structure, and text of two trees, assuming adaptor in
 *  this instance of a TreeWizard.
 */
- (BOOL)equals:(id)t1 O2:(id)t2
{
    return [self _equals:t1 O2:t2 Adaptor:adaptor];
}

- (BOOL) _equals:(id)t1 O2:(id)t2 Adaptor:(id<ANTLRTreeAdaptor>)anAdaptor
{
    // make sure both are non-nil
    if ( t1==nil || t2==nil ) {
        return NO;
    }
    // check roots
    if ( [anAdaptor getType:t1] != [anAdaptor getType:t2] ) {
        return NO;
    }
    if ( ![[anAdaptor getText:t1] isEqualTo:[anAdaptor getText:t2]] ) {
        return NO;
    }
    // check children
    NSInteger n1 = [anAdaptor getChildCount:t1];
    NSInteger n2 = [anAdaptor getChildCount:t2];
    if ( n1 != n2 ) {
        return NO;
    }
    for (int i=0; i<n1; i++) {
        ANTLRCommonTree * child1 = [anAdaptor getChild:t1 At:i];
        ANTLRCommonTree * child2 = [anAdaptor getChild:t2 At:i];
        if ( ![self _equals:child1 O2:child2 Adaptor:anAdaptor] ) {
            return NO;
        }
    }
    return YES;
}

// TODO: next stuff taken from CommonTreeNodeStream

/** Given a node, add this to the reverse index tokenTypeToStreamIndexesMap.
 *  You can override this method to alter how indexing occurs.  The
 *  default is to create a
 *
 *    Map<Integer token type,ArrayList<Integer stream index>>
 *
 *  This data structure allows you to find all nodes with type INT in order.
 *
 *  If you really need to find a node of type, say, FUNC quickly then perhaps
 *
 *    Map<Integertoken type, Map<Object tree node, Integer stream index>>
 *
 *  would be better for you.  The interior maps map a tree node to
 *  the index so you don't have to search linearly for a specific node.
 *
 *  If you change this method, you will likely need to change
 *  getNodeIndex(), which extracts information.
- (void)fillReverseIndex:(ANTLRCommonTree *)node Index:(NSInteger)streamIndex
{
    //System.out.println("revIndex "+node+"@"+streamIndex);
    if ( tokenTypesToReverseIndex == nil ) {
        return; // no indexing if this is empty (nothing of interest)
    }
    if ( tokenTypeToStreamIndexesMap == nil ) {
        tokenTypeToStreamIndexesMap = [ANTLRMap newANTLRMap]; // first indexing op
    }
    int tokenType = [adaptor getType:node];
    Integer tokenTypeI = new Integer(tokenType);
    if ( !(tokenTypesToReverseIndex == INDEX_ALL ||
            [tokenTypesToReverseIndex contains:tokenTypeI]) ) {
        return; // tokenType not of interest
    }
    NSInteger streamIndexI = streamIndex;
    AMutableArray *indexes = (AMutableArray *)[tokenTypeToStreamIndexesMap objectAtIndex:tokenTypeI];
    if ( indexes==nil ) {
        indexes = [AMutableArray arrayWithCapacity:100]; // no list yet for this token type
        indexes.add(streamIndexI); // not there yet, add
        [tokenTypeToStreamIndexesMap put:tokenTypeI Idexes:indexes];
    }
    else {
        if ( ![indexes contains:streamIndexI] ) {
            [indexes add:streamIndexI]; // not there yet, add
        }
    }
}
 
 ** Track the indicated token type in the reverse index.  Call this
 *  repeatedly for each type or use variant with Set argument to
 *  set all at once.
 * @param tokenType
public void reverseIndex:(NSInteger)tokenType
{
    if ( tokenTypesToReverseIndex == nil ) {
        tokenTypesToReverseIndex = [ANTLRMap newANTLRMap];
    }
    else if ( tokenTypesToReverseIndex == INDEX_ALL ) {
        return;
    }
    tokenTypesToReverseIndex.add(new Integer(tokenType));
}
 
** Track the indicated token types in the reverse index. Set
 *  to INDEX_ALL to track all token types.
public void reverseIndex(Set tokenTypes) {
    tokenTypesToReverseIndex = tokenTypes;
}
 
 ** Given a node pointer, return its index into the node stream.
 *  This is not its Token stream index.  If there is no reverse map
 *  from node to stream index or the map does not contain entries
 *  for node's token type, a linear search of entire stream is used.
 *
 *  Return -1 if exact node pointer not in stream.
public int getNodeIndex(Object node) {
    //System.out.println("get "+node);
    if ( tokenTypeToStreamIndexesMap==nil ) {
        return getNodeIndexLinearly(node);
    }
    int tokenType = adaptor.getType(node);
    Integer tokenTypeI = new Integer(tokenType);
    ArrayList indexes = (ArrayList)tokenTypeToStreamIndexesMap.get(tokenTypeI);
    if ( indexes==nil ) {
        //System.out.println("found linearly; stream index = "+getNodeIndexLinearly(node));
        return getNodeIndexLinearly(node);
    }
    for (int i = 0; i < indexes.size(); i++) {
        Integer streamIndexI = (Integer)indexes.get(i);
        Object n = get(streamIndexI.intValue());
        if ( n==node ) {
            //System.out.println("found in index; stream index = "+streamIndexI);
            return streamIndexI.intValue(); // found it!
        }
    }
    return -1;
}
 
*/

@synthesize adaptor;
@synthesize tokenNameToTypeMap;
@end
