///
/// OGLFramebuffer
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


#import "OGLFramebuffer.h"
#import "OGLTexture.h"

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
