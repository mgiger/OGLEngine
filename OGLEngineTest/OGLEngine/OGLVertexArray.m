//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLVertexArray.h"
#import <OpenGLES/ES2/gl.h>

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
