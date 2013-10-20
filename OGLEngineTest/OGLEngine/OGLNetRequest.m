//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLNetRequest.h"
#import "OGLWorkQueue.h"

static const double	cDefaultTimeout		= 10.0;
static const int	_maxThreadCount		= 4;
static int			_operationCount		= 0;

@interface OGLNetQueue()
@property (nonatomic, retain)	NSOperationQueue*			operationQueue;
+ (OGLNetQueue*)sharedQueue;
@end


@implementation OGLNetRequest

+ (OGLNetRequest*)request:(NSString*)url
{
	OGLNetRequest* request = [[OGLNetRequest alloc] init];
	request.url = url;
	return request;
}

- (id)init
{
	if (self = [super init])
	{
		_timeout = cDefaultTimeout;
		self.responseBody = [NSMutableData data];
		self.headers = [NSMutableDictionary dictionary];
		[_headers setValue:@"deflate,gzip" forKey:@"Accept-Encoding"];
		
		NSString* uagent = [[NSUserDefaults standardUserDefaults] valueForKey:@"User-Agent"];
		if([uagent length])
			[_headers setValue:uagent forKey:@"User-Agent"];
	}
	return self;
}

- (BOOL)isConcurrent
{
	return YES;
}

- (void)start
{
	if(![NSThread isMainThread])
	{
		[self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
	}
	else
	{
		[OGLNetQueue increment];
		
		self.isExecuting = YES;
		
		if(self.isCancelled)
		{
			self.error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
			[self cleanup];
		}
		else if(!self.isFinished)
		{
			NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:_url]
																			cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
																		timeoutInterval:_timeout];
			for(NSString* key in _headers)
				[urlRequest setValue:[_headers objectForKey:key] forHTTPHeaderField:key];
			if (_body)
				[urlRequest setHTTPBody:_body];
			[urlRequest setHTTPMethod:_method ? _method : @"GET"];
			
			self.connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
			if(!_connection)
				[self cleanup];
		}
	}
}

- (void)cleanup
{
	if (_isExecuting)
	{
		if(!_isFinished)
			[OGLNetQueue decrement];
		
		[self willChangeValueForKey:@"isExecuting"];
		[self willChangeValueForKey:@"isFinished"];
		_isExecuting = NO;
		_isFinished = YES;
		[self didChangeValueForKey:@"isExecuting"];
		[self didChangeValueForKey:@"isFinished"];
	}
	
	self.connection = nil;
}

- (void)cancel
{
	[_connection cancel];
	self.connection = nil;
	
	if(_isExecuting && _completionHandler)
	{
		self.error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCancelled userInfo:nil];
		_completionHandler(self);
	}
	
	[self cleanup];
	
	[super cancel];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response
{
	if([response isKindOfClass:[NSHTTPURLResponse class]])
		self.statusCode = [((NSHTTPURLResponse*)response) statusCode];
	[self.responseBody setLength:0];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)aData
{
	[_responseBody appendData:aData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection
{
	if(_parseHandler)
	{
		if(_completionHandler)
			[OGLWorkQueue addBlock:^{ _parseHandler(self); }
					withCompletion:^{ _completionHandler(self); [self cleanup]; }];
		else
			[OGLWorkQueue addBlock:^{ _parseHandler(self); }
					withCompletion:^{ [self cleanup]; }];
	}
	else
	{
		if(_completionHandler)
			_completionHandler(self);
		[self cleanup];
	}
	
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error
{
	self.error = error;
	if(_completionHandler)
		_completionHandler(self);
	[self cleanup];
}

@end




@implementation OGLNetQueue

+ (OGLNetQueue*)sharedQueue
{
	static dispatch_once_t pred;
	static OGLNetQueue* shared = nil;
	dispatch_once(&pred, ^{ shared = [[self alloc] initWithNumConnections:_maxThreadCount]; });
	return shared;
}

+ (void)increment
{
	if ([NSThread isMainThread])
	{
		_operationCount++;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	}
	else
		[OGLNetQueue performSelectorOnMainThread:@selector(increment) withObject:nil waitUntilDone:NO];
	
}

+ (void)decrement
{
	if ([NSThread isMainThread])
	{
		if (--_operationCount == 0)
			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	}
	else
		[OGLNetQueue performSelectorOnMainThread:@selector(decrement) withObject:nil waitUntilDone:NO];
	
}

+ (BOOL)processing
{
	return _operationCount > 0;
}

+ (void)add:(OGLNetRequest*)request
{
	[[OGLNetQueue sharedQueue].operationQueue addOperation:request];
}

+ (void)cancelURL:(NSString*)url
{
	for (OGLNetRequest* request in [OGLNetQueue sharedQueue].operationQueue.operations)
	{
		if ([request.url isEqualToString:url])
			[request cancel];
	}
}

+ (BOOL)urlQueued:(NSString*)url
{
	for (OGLNetRequest* request in [OGLNetQueue sharedQueue].operationQueue.operations)
	{
		if ([request.url isEqualToString:url])
			return YES;
	}
	return NO;
}

+ (void)cancelAllOperations
{
	[[OGLNetQueue sharedQueue].operationQueue cancelAllOperations];
}

- (id)initWithNumConnections:(NSInteger)numConnections
{
	if(self = [super init])
	{
		_operationQueue = [[NSOperationQueue alloc] init];
		[_operationQueue setMaxConcurrentOperationCount:numConnections];
	}
	return self;
}

- (void)dealloc
{
	[_operationQueue cancelAllOperations];
}

@end
