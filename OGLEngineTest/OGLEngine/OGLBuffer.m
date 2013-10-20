///
/// OGLBuffer
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
