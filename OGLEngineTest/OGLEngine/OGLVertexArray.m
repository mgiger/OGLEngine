///
/// OGLVertexArray
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


#import "OGLVertexArray.h"

#import <OpenGLES/ES2/gl.h>

@interface OGLVertexArray()

@property (nonatomic, assign)	BOOL			available;
@property (nonatomic, assign)	unsigned int	bufferID;

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
