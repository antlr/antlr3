//
//  ANTLRRuntimeException.m
//  ANTLR
//
//  Created by Alan Condit on 6/5/10.
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

#import "ANTLRRuntimeException.h"


@implementation ANTLRRuntimeException

+ (ANTLRRuntimeException *) newANTLRNoSuchElementException:(NSString *)aReason
{
    return [[ANTLRRuntimeException alloc] initWithName:@"ANTLRNoSuchElementException" reason:aReason];
}

+ (ANTLRRuntimeException *) newANTLRIllegalArgumentException:(NSString *)aReason
{
    return [[ANTLRRuntimeException alloc] initWithName:@"ANTLRIllegalArgumentException" reason:aReason];
}

+ (ANTLRRuntimeException *) newANTLRRuntimeException:(NSString *)aReason
{
    return [[ANTLRRuntimeException alloc] initWithRuntime:aReason];
}

+ (ANTLRRuntimeException *) newException:(NSString *)aName reason:(NSString *)aReason
{
    return [[ANTLRRuntimeException alloc] initWithName:aName reason:aReason];
}

+ (ANTLRRuntimeException *) newException:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[ANTLRRuntimeException alloc] initWithName:aName reason:aReason userInfo:aUserInfo];
}

- init
{
    if ((self = [super initWithName:@"ANTLRRuntimeException" reason:@"UnknownException" userInfo:nil]) != nil) {
    }
    return(self);
}

- (id)initWithRuntime:(NSString *)aReason
{
    self = [super initWithName:(NSString *)@"RuntimeException" reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    if (self) {
    }
    return(self);
}

- (id)initWithReason:(NSString *)aReason
{
    self = [super initWithName:(NSString *)@"NoNameGiven" reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    if (self) {
    }
    return(self);
}

- (id)initWithName:(NSString *)aName reason:(NSString *)aReason
{
    self = [super initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    if (self) {
    }
    return(self);
}

- (id)initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:aName reason:aReason userInfo:aUserInfo];
    if (self) {
    }
    return(self);
}

- (NSString *) Description
{
    return [super reason];
}

- (id) stackTrace:(NSException *)e
{
    NSArray *addrs = [e callStackReturnAddresses];
    NSArray *trace = [e callStackSymbols];
    
    for (NSString *traceStr in trace) {
        NSLog( @"%@", traceStr);
        // TODO: remove special after testing
        if ([traceStr hasPrefix:@"main("] > 0)
            return traceStr;
        if (![traceStr hasPrefix:@"org.stringtemplate"])
            return traceStr;
    }
    return trace;    
}

@end
