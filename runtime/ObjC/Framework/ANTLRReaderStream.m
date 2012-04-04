//
//  ANTLRReaderStream.m
//  ANTLR
//
//  Created by Alan Condit on 2/21/11.
//  Copyright 2011 Alan's MachineWorks. All rights reserved.
//

#import "ANTLRReaderStream.h"
#import "ACNumber.h"

@implementation ANTLRReaderStream

@synthesize is;
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

+ (id) newANTLRReaderStream:(NSInputStream *)r
{
    return [[ANTLRReaderStream alloc] initWithReader:r size:INITIAL_BUFFER_SIZE readBufferSize:READ_BUFFER_SIZE];
}

+ (id) newANTLRReaderStream:(NSInputStream *)r size:(NSInteger)aSize
{
    return [[ANTLRReaderStream alloc] initWithReader:r size:aSize readBufferSize:READ_BUFFER_SIZE];
}

+ (id) newANTLRReaderStream:(NSInputStream *)r size:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize
{
//    load(r, aSize, aReadChunkSize);
    return [[ANTLRReaderStream alloc] initWithReader:r size:aSize readBufferSize:aReadChunkSize];
}

- (id) init
{
	self = [super init];
	if ( self != nil ) {
        int p1 = n;  // init from ANTLRStringStream val
        is = nil;
        rbSize = READ_BUFFER_SIZE;
        size = INITIAL_BUFFER_SIZE;
    }
    return self;
}

- (id) initWithReader:(NSInputStream *)r size:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize
{
	self = [super init];
	if ( self != nil ) {
        int p1 = n;  // init from ANTLRStringStream val
        is = r;
        rbSize = aSize;
        size = aReadChunkSize;
        [is open];
//        [self setUpStreamForFile];
        if ( [is hasBytesAvailable] ) {
            [self load:aSize readBufferSize:aReadChunkSize];
        }
    }
    return self;
}

- (void) load:(NSInteger)aSize readBufferSize:(NSInteger)aReadChunkSize
{
    NSMutableData *retData = nil;
    uint8_t buf[1024];
    if ( is==nil ) {
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
        numRead = [is read:buf maxLength:aReadChunkSize];
        retData = [NSMutableData dataWithCapacity:numRead];
        [retData appendBytes:(const void *)buf length:numRead];
        NSLog( @"read %d chars; p was %d is now %d", n, p1, (p1+numRead) );
        p1 += numRead;
        n = p1;
        data = [[NSString alloc] initWithData:retData encoding:NSASCIIStringEncoding];
        NSLog( @"n=%d\n", n );
    }
    @finally {
        [self close];
    }
}

- (void)setUpStreamForFile
{
    // iStream is NSInputStream instance variable
//    if ( is == nil )
//        is = [[NSInputStream alloc] initWithFileAtPath:path];
    [is setDelegate:self];
    [is scheduleInRunLoop:[NSRunLoop currentRunLoop]
                       forMode:NSDefaultRunLoopMode];
    [is open];
}

- (void)stream:(NSStream *)stream handleEvent:(NSStreamEvent)eventCode
{
    NSMutableData *myData = nil;
    ACNumber *bytesRead = [ACNumber numberWithInteger:0];
    uint8_t buf[1024];
    switch(eventCode) {
        case NSStreamEventHasBytesAvailable:
        {
            if(!myData) {
                myData = [[NSMutableData data] retain];
            }
            unsigned int len = 0;
            len = [(NSInputStream *)stream read:buf maxLength:1024];
            if(len) {
                [myData appendBytes:(const void *)buf length:len];
                // bytesRead is an instance variable of type ACNumber.
                bytesRead = [ACNumber numberWithInteger:[bytesRead integerValue]+len];
                data = [[NSString alloc] initWithData:myData encoding:NSASCIIStringEncoding];
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
    [is close];
    is = nil;
}

@end
