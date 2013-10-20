//
//  OGLWorkQueue.m
//  EarthBrowser
//
//  Created by Matthew Giger on 8/3/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
//

#import "OGLWorkQueue.h"

static const NSInteger	cMaxQueueThreads		= 16;


@interface OGLWorkQueue()

@property (nonatomic, strong)	NSOperationQueue*	queue;

- (void)addOperation:(NSOperation*)operation;

@end

@implementation OGLWorkQueue

+ (OGLWorkQueue*)queue
{
	static dispatch_once_t pred;
	static OGLWorkQueue* shared = nil;
	dispatch_once(&pred, ^{ shared = [[self alloc] init]; });
	return shared;
}

+ (BOOL)processing
{
	return [[OGLWorkQueue queue].queue operationCount] > 0;
}

+ (void)addBlock:(void (^)(void))block
{
	if(block)
		[[OGLWorkQueue queue] addOperation:[NSBlockOperation blockOperationWithBlock:^{ block(); }]];
}

+ (void)addBlock:(void (^)(void))block withCompletion:(void (^)(void))completion
{
	if(block)
	{
		NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^
		{
			block();
			
			if(completion)
				dispatch_async(dispatch_get_main_queue(), ^{ completion(); });
		}];
		[[OGLWorkQueue queue] addOperation:operation];
	}
}

+ (void)addBlock:(id (^)(void))block withParameterizedCompletion:(void (^)(id value))completion
{
	if(block)
	{
		NSBlockOperation* operation = [NSBlockOperation blockOperationWithBlock:^
		{
			id value = block();
			if(completion)
				dispatch_async(dispatch_get_main_queue(), ^{ completion(value); });
		}];
		[[OGLWorkQueue queue] addOperation:operation];
	}
}

- (id)init
{
	if(self = [super init])
	{
		_queue = [[NSOperationQueue alloc] init];
		[_queue setMaxConcurrentOperationCount:cMaxQueueThreads];
	}
	return self;
}


- (void)addOperation:(NSOperation*)operation
{
	[_queue addOperation:operation];
}

@end
