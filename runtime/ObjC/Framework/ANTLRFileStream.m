/*
 [The "BSD license"]
 Copyright (c) 2005-2009 Terence Parr
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/** This is a char buffer stream that is loaded from a file
 *  all at once when you construct the object.  This looks very
 *  much like an ANTLReader or ANTLRInputStream, but it's a special case
 *  since we know the exact size of the object to load.  We can avoid lots
 *  of data copying. 
 */

#import "ANTLRFileStream.h"

@implementation ANTLRFileStream

@synthesize fileName;

+ (id) newANTLRFileStream:(NSString*)fileName
{
    return [[ANTLRFileStream alloc] init:fileName];
}

+ (id) newANTLRFileStream:(NSString *)aFileName encoding:(NSStringEncoding)encoding
{
    return [[ANTLRFileStream alloc] init:aFileName encoding:encoding];
}

- (id) init:(NSString *)aFileName
{
    self = [super init];
    if ( self != nil ) {
        fileName = aFileName;
        [self load:aFileName encoding:NSUTF8StringEncoding];
    }
    return self;
}

- (id) init:(NSString *) aFileName encoding:(NSStringEncoding)encoding
{
    self = [super init];
    if ( self != nil ) {
        fileName = aFileName;
        [self load:aFileName encoding:encoding];
    }
    return self;
}

- (NSString *) getSourceName
{
    return fileName;
}

- (void) load:(NSString *)aFileName encoding:(NSStringEncoding)encoding
{
    if ( aFileName==nil ) {
        return;
    }
    NSError *error;
    NSData *retData = nil;
    NSFileHandle *fh;
    @try {
        NSString *fn = [aFileName stringByStandardizingPath];
        NSURL *f = [NSURL fileURLWithPath:fn];
        fh = [NSFileHandle fileHandleForReadingFromURL:f error:&error];
        if ( fh==nil ) {
            return;
        }
        int numRead=0;
        int p1 = 0;
        retData = [fh readDataToEndOfFile];
        numRead = [retData length];
#pragma mark fix these NSLog calls
        NSLog( @"read %d chars; p was %d is now %d", n, p1, (p1+numRead) );
        p1 += numRead;
        n = p1;
        data = [[NSString alloc] initWithData:retData encoding:NSASCIIStringEncoding];
#pragma mark fix these NSLog calls
        NSLog( @"n=%d", n );
    }
    @finally {
        [fh closeFile];
    }
}

@end
