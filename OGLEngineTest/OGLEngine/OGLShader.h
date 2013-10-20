///
/// OGLShader
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


#import "OGLEngine.h"

#define STRINGIFY(x)	#x
#define NSSTRINGIFY(x)	@ STRINGIFY(x)

@class OGLRenderInfo;

///////////////////////////////////////////////////////////////////////////
///
/// @class OGLShader
///
/// Shader program object
///
///////////////////////////////////////////////////////////////////////////
@interface OGLShader : NSObject

@property (nonatomic, assign)	uint		program;
@property (nonatomic, assign)	float		alpha;
@property (nonatomic, assign)	CGFloat4	color;
@property (nonatomic, assign)	CGFloat4	bounds;
@property (nonatomic, copy)		NSString*	vertSource;
@property (nonatomic, copy)		NSString*	fragSource;

- (BOOL)loadShader;

- (int)uniformForName:(NSString*)name;
- (int)attributeForName:(NSString*)name;

- (BOOL)bindShader:(OGLRenderInfo*)info;
- (void)unbindShader:(OGLRenderInfo*)info;

@end
