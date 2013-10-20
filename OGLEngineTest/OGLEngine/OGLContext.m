///
/// OGLContext
///
/// Created by Matt Giger
/// Copyright (c) 2013 EarthBrowser LLC. All rights reserved.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
/// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
/// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
/// permit persons to whom the Software is furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
/// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
/// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
/// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///


#import "OGLContext.h"
#import "OGLTexture.h"
#import "OGLBuffer.h"

#include <OpenGLES/ES2/gl.h>

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
