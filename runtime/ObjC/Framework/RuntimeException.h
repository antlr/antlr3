//
//  RuntimeException.h
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

#import <Foundation/Foundation.h>

@interface RuntimeException : NSException {
}

+ (RuntimeException *) newException;
+ (RuntimeException *) newException:(NSString *)aReason;
+ (RuntimeException *) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

+ (RuntimeException *) newException:(NSString *)aName reason:(NSString *)aReason;
+ (RuntimeException *) newException:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (id) init;
- (id) init:(NSString *)aReason;
- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;
- (id) initWithName:(NSString *)aName reason:(NSString *)aReason;
- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (NSString *) Description;
- (id) stackTrace:(NSException *)e;

@end

@interface CloneNotSupportedException : RuntimeException {
}

+ (id) newException;
+ (id) newException:(NSString *)aReason;
+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (id) init;
- (id) init:(NSString *)aReason;
- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

@end

@interface ConcurrentModificationException : RuntimeException {
}

+ (id) newException:(NSString *)aReason;

- (id) init;
- (id) init:(NSString *)aReason;
- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;
@end

@interface IllegalArgumentException : RuntimeException {
}

+ (id) newException;
+ (id) newException:(NSString *)aReason;
+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (id) init;
- (id) init:(NSString *)aReason;
- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

@end

@interface IllegalStateException : RuntimeException {
}

+ (id) newException;
+ (id) newException:(NSString *)aReason;
+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (id) init;
- (id)init:(NSString *)aReason;
- (id)init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

@end

@interface IndexOutOfBoundsException : RuntimeException {
}

+ (id) newException;
+ (id) newException:(NSString *)aReason;
+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (id) init;
- (id)init:(NSString *)aReason;
- (id)init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

@end

@interface NoSuchElementException : RuntimeException {
}

+ (id) newException;
+ (id) newException:(NSString *)aReason;
+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (id) init;
- (id) init:(NSString *)aReason;
- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

@end

@interface NullPointerException : RuntimeException {
}

+ (id) newException;
+ (id) newException:(NSString *)aReason;
+ (id) newException:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

- (id) init;
- (id) init:(NSString *)aReason;
- (id) init:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

@end

@interface RewriteEarlyExitException : RuntimeException {
}

+ (id) newException;
- (id) initWithName:(NSString *)aName reason:(NSString *)aReason userInfo:(NSDictionary *)aUserInfo;

@end

@interface UnsupportedOperationException : RuntimeException {
}

+ (id) newException:(NSString *)aReason;

- (id) initWithName:(NSString *)aName reason:(NSString *)aReason;
- (id) initWithName:(NSString *)aMsg reason:(NSString *)aCause userInfo:(NSDictionary *)userInfo;

@end

