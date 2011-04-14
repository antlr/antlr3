//
//  ANTLRReaderStream.m
//  ANTLR
//
//  Created by Alan Condit on 2/21/11.
//  Copyright 2011 Alan's MachineWorks. All rights reserved.
//

#import "ANTLRReaderStream.h"


@implementation ANTLRReaderStream

@synthesize fh;
@synthesize size;
@synthesize rbSize;

static NSInteger READ_BUFFER_SIZE = 1024;
static NSInteger INITIAL_BUFFER_SIZE = 1024;

+ (NSInteger) READ_BUFFER_SIZE
{
    return READ_BUFFER_SIZE;
}

+ (NSInteger) INITIAL_BUFFER_SIZE
{
    return INITIAL_BUFFER_SIZE;
}

+ (id) newANTLRReaderStream
{
    return [[ANTLRReaderStream alloc] init];
}

+ (id) newANTLRReaderStream:(NSFileHandle *)r
{
    return [[ANTLRReaderStream alloc] initWithReader:r size:INITIAL_BUFFER_SIZE readBufferSize:READ_BUFFER_SIZE];
}

+ (id) newANTLRReaderStream:(NSFileHandle *)r size:(NSInteger)aSize
{
    return [[ANTLRReaderStream alloc] initWithReader:r size:aSize readBufferSize:READ_BUFFER_SIZE];
}

+ (id) newANTLRReaderStream:(NSFileHandle *)r size:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize
{
//    load(r, aSize, aReadChunkSize);
    return [[ANTLRReaderStream alloc] initWithReader:r size:aSize readBufferSize:aReadChunkSize];
}

- (id) init
{
	self = [super init];
	if ( self != nil ) {
        fh = nil;
        rbSize = READ_BUFFER_SIZE;
        size = INITIAL_BUFFER_SIZE;
    }
    return self;
}

- (id) initWithReader:(NSFileHandle *)r size:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize
{
	self = [super init];
	if ( self != nil ) {
        fh = r;
        rbSize = aSize;
        size = aReadChunkSize;
        [self load:aSize readBufferSize:aReadChunkSize];
    }
    return self;
}

- (void) load:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize
{
    NSData *retData = nil;
    if ( fh==nil ) {
        return;
    }
    if ( aSize<=0 ) {
        aSize = INITIAL_BUFFER_SIZE;
    }
    if ( aReadChunkSize<=0 ) {
        aReadChunkSize = READ_BUFFER_SIZE;
    }
#pragma mark fix these NSLog calls
    @try {
        int numRead=0;
        int p1 = 0;
        retData = [fh readDataToEndOfFile];
        numRead = [retData length];
        NSLog( @"read %d chars; p was %d is now %d", n, p1, (p1+numRead) );
        p1 += numRead;
        n = p1;
        data = [[NSString alloc] initWithData:retData encoding:NSASCIIStringEncoding];
        NSLog( @"n=%d", n );
    }
    @finally {
        [fh closeFile];
    }
}

- (void)setUpStreamForFile:(NSString *)path {
    // iStream is NSInputStream instance variable
    NSInputStream *iStream = [[NSInputStream alloc] initWithFileAtPath:path];
//    [iStream setDelegate:self];
    [iStream scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [iStream open];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSMutableData *myData = nil;
    NSNumber *bytesRead = [NSNumber numberWithInteger:0];
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            if(!myData) {
                myData = [[NSMutableData data] retain];
            }
            uint8_t buf[1024];
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) {
                [myData appendBytes:(const void *)buf length:len];
                // bytesRead is an instance variable of type NSNumber.
                bytesRead = [NSNumber numberWithInteger:[bytesRead intValue]+len];
            } else {
                NSLog(@"no buffer!");
            }
            break;
        }
        case NSStreamEventEndEncountered:
        {
            [stream close];
            [stream removeFromRunLoop:[NSRunLoop currentRunLoop]
                              forMode:NSDefaultRunLoopMode];
            [stream release];
            stream = nil; // stream is ivar, so reinit it
            break;
        }
            // continued
    }
}

- (void) close
{
    [fh closeFile];
}

@end
