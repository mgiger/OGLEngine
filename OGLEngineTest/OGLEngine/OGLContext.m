//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLContext.h"
#import "OGLTexture.h"

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



@implementation OGLBuffer

- (id)initArrayBuffer
{
	if(self = [super init])
	{
		_arrayBuffer = YES;
		glGenBuffers(1, &_bufferID);
	}
	return self;
}

- (id)initIndexBuffer
{
	if(self = [super init])
	{
		_arrayBuffer = NO;
		glGenBuffers(1, &_bufferID);
	}
	return self;
}

- (void)dealloc
{
	if(_bufferID)
		glDeleteBuffers(1, &_bufferID);
}

- (void)uploadData:(NSData*)data
{
	glBindBuffer(_arrayBuffer ? GL_ARRAY_BUFFER : GL_ELEMENT_ARRAY_BUFFER, _bufferID);
    glBufferData(_arrayBuffer ? GL_ARRAY_BUFFER : GL_ELEMENT_ARRAY_BUFFER, [data length], [data bytes], GL_STATIC_DRAW);
	glBindBuffer(_arrayBuffer ? GL_ARRAY_BUFFER : GL_ELEMENT_ARRAY_BUFFER, 0);
}

- (void)bind
{
	if(_available)
		glBindBuffer(_arrayBuffer ? GL_ARRAY_BUFFER : GL_ELEMENT_ARRAY_BUFFER, _bufferID);
}

- (void)unbind
{
	glBindBuffer(_arrayBuffer ? GL_ARRAY_BUFFER : GL_ELEMENT_ARRAY_BUFFER, 0);
}

@end



@interface OGLVertexArray()
{
	NSUInteger	_bufferID;
}

@end


@implementation OGLVertexArray

- (id)init
{
	if(self = [super init])
	{
		glGenVertexArraysOES(1, &_bufferID);
	}
	return self;
}

- (void)dealloc
{
	if(_bufferID)
		glDeleteVertexArraysOES(1, &_bufferID);
}

- (void)bind
{
	if(_bufferID)
		glBindVertexArrayOES(_bufferID);
}

- (void)unbind
{
	glBindVertexArrayOES(0);
}

@end




@implementation OGLFramebuffer

- (id)init
{
	if(self = [super init])
	{
		glGenFramebuffers(1, &_framebufferID);
	}
	return self;
}

- (void)dealloc
{
	if(_framebufferID)
		glDeleteFramebuffers(1, &_framebufferID);
}

- (void)bind
{
	glBindFramebuffer(GL_FRAMEBUFFER, _framebufferID);
}

- (void)unbind
{
	glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (BOOL)attachTexture:(OGLTexture*)texture
{
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture.textureID, 0);
	uint status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
	return status == GL_FRAMEBUFFER_COMPLETE;
}

//			Camera* cam = [[[Camera alloc] init] autorelease];
//			cam.ortho = YES;
//			[cam setPosition:float3(0, 0, 10.1f)];
//			[cam setForward:float3(0, 0, -1)];
//			[cam setNearFar:float2(10.0f, -10.0f)];
//
//			RenderInfo* info = [[[RenderInfo alloc] initWithCamera:cam withSpriteLayer:nil] autorelease];
//
//			glViewport(0, 0, 512, 512);
//			glClearColor (1.0f, 0.0f, 0.0f, 0.5f);
//			glClear (GL_COLOR_BUFFER_BIT);
//			glFlush();
//
//			[cam render:info];
//
//			TextShader* shader = [TextShader shader];
//			shader.color = float4(0,1,0,1);
//			[shader bindShader:info];
//
//			float quadbuf[] = {
//				0,			0,			0, 0,
//				0,			.3,	0, 1,
//				.3,	0,			1, 0,
//				.3,	0,			1, 0,
//				0,			.3,	0, 1,
//				.3,	.3,	1, 1
//			};
//
//
//			const void* bufptr = (const void*)&quadbuf[0];
//			glEnableVertexAttribArray(info.vcoordBinding);
//			glEnableVertexAttribArray(info.tcoordBinding);
//			glVertexAttribPointer(info.vcoordBinding, 2, GL_FLOAT, GL_FALSE, sizeof(float4), bufptr);
//			glVertexAttribPointer(info.tcoordBinding, 2, GL_FLOAT, GL_FALSE, sizeof(float4), (char*)bufptr + sizeof(float2));
//
//			glDrawArrays(GL_TRIANGLES, 0, 6);
//
//			glDisableVertexAttribArray(info.vcoordBinding);
//			glDisableVertexAttribArray(info.tcoordBinding);
//
//			TextureBuffer* tdata = [[TextureBuffer alloc] init];
//			[tdata createEmptyImage:CGSizeMake(512, 512)];
//			glReadPixels(0, 0, 512, 512, GL_RGBA, GL_UNSIGNED_BYTE, (void*)[tdata.data bytes]);
//			[tdata saveToFile:@"/Users/mgiger/Desktop/test.png"];

@end
