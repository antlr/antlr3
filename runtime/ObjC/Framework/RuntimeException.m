//
//  RuntimeException.m
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

#import "RuntimeException.h"


@implementation RuntimeException

+ (id) newException
{
    return [[RuntimeException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[RuntimeException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[RuntimeException alloc] init:aReason userInfo:aUserInfo];
}

+ (id) newException:(NSString *)aName reason:(NSString *)aReason;
{
    return [[RuntimeException alloc] initWithName:aName reason:aReason];
}

+ (id) newException:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;
{
    return [[RuntimeException alloc] initWithName:aName reason:aReason userInfo:aUserInfo];
}


- (id) init
{
    self = [super initWithName:@"RuntimeException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:(NSString *)@"RuntimeException" reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"RuntimeException" reason:aReason userInfo:aUserInfo];
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

@implementation CloneNotSupportedException

+ (id) newException
{
    return [[CloneNotSupportedException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[CloneNotSupportedException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[CloneNotSupportedException alloc] init:aReason userInfo:aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"CloneNotSupportedException" reason:@"Attempted to clone non-cloneable object" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"CloneNotSupportedException" reason:(NSString *)aReason userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"CloneNotSupportedException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation ConcurrentModificationException

+ (id) newException
{
    return [[ConcurrentModificationException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[ConcurrentModificationException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[ConcurrentModificationException alloc] init:aReason userInfo:aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"ConcurrentModificationException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"ConcurrentModificationException" reason:(NSString *)aReason userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"ConcurrentModificationException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation IllegalArgumentException

+ (id) newException
{
    return [[IllegalArgumentException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[IllegalArgumentException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[IllegalArgumentException alloc] init:aReason userInfo:aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"IllegalArgumentException" reason:@"IllegalStateException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"IllegalArgumentException" reason:(NSString *)aReason userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"IllegalArgumentException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation IllegalStateException

+ (id) newException
{
    return [[IllegalStateException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[IllegalStateException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[IllegalStateException alloc] init:aReason userInfo:aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"IllegalStateException" reason:@"IllegalStateException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"IllegalStateException" reason:(NSString *)aReason userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"IllegalStateException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation IndexOutOfBoundsException

+ (id) newException
{
    return [[IndexOutOfBoundsException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[IndexOutOfBoundsException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[IndexOutOfBoundsException alloc] init:aReason userInfo:aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"IndexOutOfBoundsException" reason:@"IndexOutOfBoundsException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"IndexOutOfBoundsException" reason:(NSString *)aReason userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"IndexOutOfBoundsException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation NoSuchElementException

+ (id) newException
{
    return [[NoSuchElementException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[NoSuchElementException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[NoSuchElementException alloc] init:aReason userInfo:(NSDictionary *)aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"NoSuchElementException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"NoSuchElementException" reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"NoSuchElementException" reason:aReason userInfo:aUserInfo];
    return(self);
}

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:aName reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation NullPointerException

+ (id) newException
{
    return [[NullPointerException alloc] init];
}

+ (id) newException:(NSString *)aReason
{
    return [[NullPointerException alloc] init:aReason];
}

+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    return [[NullPointerException alloc] init:aReason userInfo:(NSDictionary *)aUserInfo];
}

- (id) init
{
    self = [super initWithName:@"NullPointerException" reason:@"UnknownException" userInfo:nil];
    return(self);
}

- (id) init:(NSString *)aReason
{
    self = [super initWithName:@"NullPointerException" reason:(NSString *)aReason userInfo:(NSDictionary *)nil];
    return(self);
}

- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo
{
    self = [super initWithName:@"NullPointerException" reason:aReason userInfo:aUserInfo];
    return(self);
}

@end

@implementation RewriteEarlyExitException

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

@implementation UnsupportedOperationException

+ (id) newException:(NSString *)aReason
{
    return [[RuntimeException alloc] initWithName:@"Unsupported Operation Exception" reason:aReason userInfo:nil];
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

