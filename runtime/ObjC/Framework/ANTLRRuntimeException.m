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

+ (id) newException
{
    return [[ANTLRRuntimeException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[ANTLRRuntimeException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[ANTLRRuntimeException alloc] init:aReason userInfo:aUserInfo];
}

+ (id) newException:(NSString *)aName reason:(NSString *)aReason;
{
    return [[ANTLRRuntimeException alloc] initWithName:aName reason:aReason];
}

+ (id) newException:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;
{
    return [[ANTLRRuntimeException alloc] initWithName:aName reason:aReason userInfo:aUserInfo];
}


- (id) init
{
    self = [super initWithName:@"ANTLRRuntimeException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:(NSString *)@"ANTLRRuntimeException" reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"ANTLRRuntimeException" reason:aReason userInfo:aUserInfo];
    return(self);
}

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason
{
    self = [super initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    return(self);
}

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo];
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

@implementation ANTLRIllegalArgumentException

+ (id) newException
{
    return [[ANTLRIllegalArgumentException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[ANTLRIllegalArgumentException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[ANTLRIllegalArgumentException alloc] init:aReason userInfo:aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"ANTLRIllegalArgumentException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"ANTLRIllegalArgumentException" reason:(NSString *)aReason userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"ANTLRIllegalArgumentException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation ANTLRIllegalStateException

+ (id) newException
{
    return [[ANTLRIllegalStateException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[ANTLRIllegalStateException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[ANTLRIllegalStateException alloc] init:aReason userInfo:aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"ANTLRIllegalStateException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"ANTLRIllegalStateException" reason:(NSString *)aReason userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"ANTLRIllegalStateException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation ANTLRNoSuchElementException

+ (id) newException
{
    return [[ANTLRNoSuchElementException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[ANTLRNoSuchElementException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[ANTLRNoSuchElementException alloc] init:aReason userInfo:(NSDictionary *)aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"ANTLRNoSuchElementException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"ANTLRNoSuchElementException" reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"ANTLRNoSuchElementException" reason:aReason userInfo:aUserInfo];
    return(self);
}

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:aName reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation ANTLRRewriteEarlyExitException

+ (id) newException
{
	return [[self alloc] init];
}

- (id) init
{
	self = [super initWithName:@"RewriteEarlyExitException" reason:nil userInfo:nil];
	return self;
}

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:aName reason:aReason userInfo:aUserInfo];
    return(self);
}

- (NSString *) description
{
	return [self name];
}

@end

@implementation ANTLRUnsupportedOperationException

+ (id) newException:(NSString *)aReason
{
    return [[ANTLRRuntimeException alloc] initWithName:@"Unsupported Operation Exception" reason:aReason userInfo:nil];
}

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason
{
    self=[super initWithName:aName reason:aReason userInfo:nil];
    return self;
}

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)userInfo
{
    self=[super initWithName:aName reason:aReason userInfo:userInfo];
    return self;
}

@end

