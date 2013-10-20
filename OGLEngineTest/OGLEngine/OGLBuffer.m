//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//


#import "OGLBuffer.h"
#import <OpenGLES/ES2/gl.h>

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
