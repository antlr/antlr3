//
//  ANTLRMissingTokenException.m
//  ANTLR
//
//  Created by Alan Condit on 6/8/10.
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

#import "ANTLRMissingTokenException.h"


@implementation ANTLRMissingTokenException
/** Used for remote debugger deserialization */
+ (id) newException
{
    return [[ANTLRMissingTokenException alloc] init];
}

+ (id) newException:(NSInteger)expected
             Stream:(id<ANTLRIntStream>)anInput
               With:(id<ANTLRToken>)insertedToken
{
    return [[ANTLRMissingTokenException alloc] init:expected Stream:anInput With:insertedToken];
}

- (id) init
{
    if ((self = [super init]) != nil) {
    }
    return self;
}

- (id) init:(NSInteger)expected Stream:(id<ANTLRIntStream>)anInput With:(id<ANTLRToken>)insertedToken
{
    if ((self = [super initWithStream:anInput]) != nil) {
        expecting = expected;
        input = anInput;
        inserted = insertedToken;
    }
    return self;
}

- (NSInteger) getMissingType
{
    return expecting;
}

- (NSString *)toString
{
    if ( inserted != nil && token != nil ) {
        return [NSString stringWithFormat:@"MissingTokenException(inserted %@ at %@)", inserted, token.text];
    }
    if ( token!=nil ) {
        return [NSString stringWithFormat:@"MissingTokenException(at %@)", token.text ];
    }
    return @"MissingTokenException";
}

@synthesize inserted;
@end
