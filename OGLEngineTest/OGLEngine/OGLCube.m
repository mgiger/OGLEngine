//
//  OGLCube.m
//  OGLEngineTest
//
//  Created by Matt Giger on 10/20/13.
//  Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLCube.h"
#import "OGLShader.h"
#import "OGLContext.h"
#import "OGLTexture.h"
#import "OGLRenderInfo.h"

@interface OGLCube()
{
	OGLBuffer*		_vertexBuf;
	OGLTexture*		_texture;
}

@end

@implementation OGLCube

- (void)buildGeometry
{
	OGLFloat3 cubebuf[] = {
		{ 1,  1,  1 },
		{ -1,  1,  1 },
		{ -1, -1,  1 },
		{ 1, -1,  1 },
		{ 1, -1, -1 },
		{ -1, -1, -1 },
		{ -1,  1, -1 },
		{ 1,  1, -1 },
	};
	
	self.hasGeometry = YES;
	
	if(!_vertexBuf)
		_vertexBuf = [[OGLBuffer alloc] initArrayBuffer];
	_vertexBuf.available = NO;
	
	NSData* data = [NSData dataWithBytesNoCopy:cubebuf length:sizeof(cubebuf) freeWhenDone:NO];
	if([[NSThread currentThread] isMainThread])
	{
		[_vertexBuf uploadData:data];
		_vertexBuf.available = YES;
	}
	else
	{
		[[OGLContext worker] uploadData:data intoBuffer:_vertexBuf];
	}
}

- (void)render:(OGLRenderInfo*)info
{
	if(self.visible)
	{
		[info pushTransform:self.transform];
		
		if(self.hasGeometry && _texture.available && _vertexBuf.available)
		{
			OGLFlatShader* shader = [OGLFlatShader shader];
			[shader bindShader:info];
			[_texture bindTo:info.tex0Binding unit:0];
			
			
			[_vertexBuf bind];
			glEnableVertexAttribArray(info.vcoordBinding);
			glEnableVertexAttribArray(info.tcoordBinding);
			glVertexAttribPointer(info.vcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), 0);
			glVertexAttribPointer(info.tcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (char*)sizeof(CGPoint));
			glDrawArrays(GL_TRIANGLES, 0, 6);
			[_vertexBuf unbind];
			
			[_texture unbind];
		}
		
		for(OGLSceneObject* obj in self.children)
			[obj render:info];
		
		[info popTransform];
	}
}
@end
