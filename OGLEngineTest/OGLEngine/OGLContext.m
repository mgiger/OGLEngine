//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLContext.h"
#import "OGLTexture.h"
#import "OGLBuffer.h"

static OGLContext*		_main = nil;
static NSMutableArray*	_workers = nil;
static int				_workerIndex = 0;

@interface OGLContext()

@property (nonatomic, strong)	NSMutableArray*		buffers;
@property (nonatomic, strong)	NSMutableArray*		textures;
@property (nonatomic, strong)	NSOperationQueue*	workQueue;

- (void)update;

@end

@implementation OGLContext

+ (OGLContext*)main
{
	return _main;
}

+ (OGLContext*)worker
{
	if([_workers count])
		return [_workers objectAtIndex:++_workerIndex % [_workers count]];
	return _main;
}

+ (void)updateContexts
{
	[_main setCurrent];
//	glFlush();
	
	for(OGLContext* worker in _workers)
		[worker update];
}

- (id)initWithAPI:(EAGLRenderingAPI)api
{
	if(self = [super init])
	{
		_main = self;
		_context = [[EAGLContext alloc] initWithAPI:api];
	}
	return self;
}

- (id)initWithAPI:(EAGLRenderingAPI)api withSharegroup:(EAGLSharegroup*)sharegroup
{
	if(self = [super init])
	{
		if(!_workers)
			_workers = [[NSMutableArray alloc] init];
		[_workers addObject:self];
		
		_context = [[EAGLContext alloc] initWithAPI:api sharegroup:sharegroup];
		_buffers = [[NSMutableArray alloc] init];
		_textures = [[NSMutableArray alloc] init];
		_workQueue = [[NSOperationQueue alloc] init];
		[_workQueue setMaxConcurrentOperationCount:1];
	}
	return self;
}

- (void)setCurrent
{
	[EAGLContext setCurrentContext:_context];
}

- (void)uploadData:(NSData*)data intoBuffer:(OGLBuffer*)buffer
{
	if(data && buffer)
	{
		buffer.available = NO;
		if(_workQueue)
		{
			@synchronized(_workQueue)
			{
				[_workQueue addOperation:[NSBlockOperation blockOperationWithBlock:^
				{
					[EAGLContext setCurrentContext:_context];
					[buffer uploadData:data];
					glFlush();
					@synchronized(_buffers)
					{
						[_buffers addObject:buffer];
					}
				}]];
			}
		}
		else
		{
			[buffer uploadData:data];
			buffer.available = YES;
		}
	}
}

- (void)uploadData:(OGLTextureData*)data intoTexture:(OGLTexture*)texture
{
	if(data && texture)
	{
		texture.available = NO;
		
		if(_workQueue)
		{
			@synchronized(_workQueue)
			{
				[_workQueue addOperation:[NSBlockOperation blockOperationWithBlock:^
				{
					[EAGLContext setCurrentContext:_context];
					[texture uploadData:data];
					glFlush();
					@synchronized(_textures)
					{
						[_textures addObject:texture];	// add texture only when we are done uploading
					}
				}]];
			}
		}
		else
		{
			[texture uploadData:data];
			texture.available = YES;
		}
	}
}

- (void)update
{
	@synchronized(_buffers)
	{
		for(OGLBuffer* buffer in _buffers)
			buffer.available = YES;
		[_buffers removeAllObjects];
	}
	
	@synchronized(_textures)
	{
		for(OGLTexture* texture in _textures)
			texture.available = YES;
		[_textures removeAllObjects];
	}
}

@end
