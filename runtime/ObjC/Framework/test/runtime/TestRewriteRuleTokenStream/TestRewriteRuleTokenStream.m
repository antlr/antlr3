// [The "BSD licence"]
// Copyright (c) 2007 Kay Roepke
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

#import "TestRewriteRuleTokenStream.h"
#import "ANTLRRewriteRuleTokenStream.h"
#import "ANTLRCommonTreeAdaptor.h"
#import "ANTLRCommonToken.h"

@implementation TestRewriteRuleTokenStream

- (void) setUp
{
    treeAdaptor = [ANTLRCommonTreeAdaptor newTreeAdaptor];
    stream = [ANTLRRewriteRuleTokenStream newANTLRRewriteRuleTokenStream:treeAdaptor
                                                          description:@"rewrite rule token stream"];
    token1 = [ANTLRCommonToken newToken:5];
    token2 = [ANTLRCommonToken newToken:6];
    token3 = [ANTLRCommonToken newToken:7];
    token4 = [ANTLRCommonToken newToken:8];
    [token1 setText:@"token 1"];
    [token2 setText:@"token 2"];
    [token3 setText:@"token 3"];
    [token4 setText:@"token 4"];
}

- (void) tearDown
{
    [token1 release]; token1 = nil;
    [token2 release]; token2 = nil;
    [token3 release]; token3 = nil;
    [token4 release]; token4 = nil;
    
    [treeAdaptor release]; treeAdaptor = nil;
    [stream release]; stream = nil;
}

- (void) test01EmptyRewriteStream
{
    treeAdaptor = [ANTLRCommonTreeAdaptor newTreeAdaptor];
    stream = [ANTLRRewriteRuleTokenStream newANTLRRewriteRuleTokenStream:treeAdaptor
                                                             description:@"rewrite rule token stream"];
    STAssertFalse([stream hasNext], @"-(BOOL)hasNext should be NO, but isn't");
    STAssertThrows([stream nextToken], @"-next on empty stream should throw exception, but doesn't");
}

- (void) test02RewriteStreamCount
{
    treeAdaptor = [ANTLRCommonTreeAdaptor newTreeAdaptor];
    stream = [ANTLRRewriteRuleTokenStream newANTLRRewriteRuleTokenStream:treeAdaptor
                                                             description:@"rewrite rule token stream"];
    token1 = [ANTLRCommonToken newToken:5];
    token2 = [ANTLRCommonToken newToken:6];
    [token1 setText:@"token 1"];
    [token2 setText:@"token 2"];
    STAssertTrue([stream size] == 0,
                 @"empty stream should have count==0");
    [stream addElement:token1];
    STAssertTrue([stream size] == 1,
                 @"single element stream should have count==1");
    [stream addElement:token2];
    STAssertTrue([stream size] == 2,
                 @"multiple stream should have count==2");

}

- (void) test03SingleElement
{
    treeAdaptor = [ANTLRCommonTreeAdaptor newTreeAdaptor];
    stream = [ANTLRRewriteRuleTokenStream newANTLRRewriteRuleTokenStream:treeAdaptor
                                                             description:@"rewrite rule token stream"];
    token1 = [ANTLRCommonToken newToken:5];
    token2 = [ANTLRCommonToken newToken:6];
    token3 = [ANTLRCommonToken newToken:7];
    token4 = [ANTLRCommonToken newToken:8];
    [token1 setText:@"token 1"];
    [token2 setText:@"token 2"];
    [token3 setText:@"token 3"];
    [token4 setText:@"token 4"];
    [stream addElement:token1];
    STAssertTrue([stream hasNext], @"-hasNext should be YES, but isn't");
    ANTLRCommonTree *tree = [stream nextNode];
    STAssertEqualObjects([tree getToken], token1, @"return token from stream should be token1, but isn't");
}

- (void) test04SingleElementDup
{
    [stream addElement:token1];
    ANTLRCommonTree *tree1, *tree2;
    STAssertNoThrow(tree1 = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertNoThrow(tree2 = [stream nextNode],
                    @"stream iteration past element count (single element) should not throw exception"
                    );
    STAssertEqualObjects([tree1 getToken], [tree2 getToken],
                         @"tokens should be the same");
    STAssertFalse(tree1 == tree2, 
                         @"trees should be different, but aren't");
}

- (void) test05MultipleElements
{
    [stream addElement:token1];
    [stream addElement:token2];
    [stream addElement:token3];
    ANTLRCommonTree *tree1, *tree2, *tree3, *tree4;
    STAssertNoThrow(tree1 = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertEqualObjects([tree1 getToken], token1,
                         @"[tree1 token] should be equal to token1"
                         );
    STAssertNoThrow(tree2 = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertEqualObjects([tree2 getToken], token2,
                         @"[tree2 token] should be equal to token2"
                         );
    STAssertNoThrow(tree3 = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertEqualObjects([tree3 getToken], token3,
                         @"[tree3 token] should be equal to token3"
                         );
    STAssertThrows(tree4 = [stream nextNode],
                    @"iterating beyond end of stream should throw an exception"
                    );
}

- (void) test06MultipleElementsAfterReset
{
    [stream addElement:token1];
    [stream addElement:token2];
    [stream addElement:token3];
    ANTLRCommonTree *tree1, *tree2, *tree3;
    
    // consume the stream completely
    STAssertNoThrow(tree1 = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertEqualObjects([tree1 getToken], token1,
                         @"[tree1 token] should be equal to token1"
                         );
    STAssertNoThrow(tree2 = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertEqualObjects([tree2 getToken], token2,
                         @"[tree2 token] should be equal to token2"
                         );
    STAssertNoThrow(tree3 = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    
    [stream reset]; // after resetting the stream it should dup
    
    ANTLRCommonTree *tree1Dup, *tree2Dup, *tree3Dup;

    STAssertNoThrow(tree1Dup = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertTrue(tree1 != tree1Dup,
                 @"[tree1 token] should be equal to token1"
                 );
    STAssertNoThrow(tree2Dup = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertTrue(tree2 != tree2Dup,
                 @"[tree2 token] should be equal to token2"
                 );
    STAssertNoThrow(tree3Dup = [stream nextNode],
                    @"stream iteration should not throw exception"
                    );
    STAssertTrue(tree3 != tree3Dup,
                 @"[tree3 token] should be equal to token3"
                 );
}

@end
