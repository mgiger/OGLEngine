///
/// OGLRenderInfo
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

#import "OGLRenderInfo.h"
#import "OGLCamera.h"

#include <OpenGLES/ES2/gl.h>

float				_ScreenScale	= 1.0;

@interface OGLRenderInfo()
{
	NSMutableArray*		_modelViewStack;
	NSMutableArray*		_modelViewProjectionStack;
}

@end

///////////////////////////////////////////////////////////////////////////
///
/// @class OGLRenderInfo
///
/// Controls render state
///
///////////////////////////////////////////////////////////////////////////
@implementation OGLRenderInfo

- (id)initWithCamera:(OGLCamera*)cam withSpriteLayer:(OGLSpriteLayer*)slayer
{
	if(self = [super init])
	{
		_modelViewStack = [NSMutableArray array];
		_modelViewProjectionStack = [NSMutableArray array];
		
		self.camera = cam;
		self.spriteLayer = slayer;
		_screenWidth = cam.screenSize.width;
		_screenHeight = cam.screenSize.height;
	}
	return self;
}

- (void)popTransform
{
	if([_modelViewStack count] > 0)
	{
		NSValue* val;
		val = [_modelViewStack objectAtIndex:[_modelViewStack count] - 1];
		[val getValue:&_modelView];
		[_modelViewStack removeLastObject];
		
		val = [_modelViewProjectionStack objectAtIndex:[_modelViewProjectionStack count] - 1];
		[val getValue:&_modelView];
		[_modelViewProjectionStack removeLastObject];
	}
}

- (void)pushTransform:(CGFloat4x4)xform
{
	[_modelViewStack addObject:[NSValue valueWithBytes:&xform objCType:@encode(CGFloat4x4)]];
	_modelView = mult(xform, _modelView);
	
	[_modelViewStack addObject:[NSValue valueWithBytes:&_modelViewProjection objCType:@encode(CGFloat4x4)]];
	_modelViewProjection = mult(_modelView, _projection);
}

- (void)resetTransforms
{
	[_modelViewStack removeAllObjects];
	[_modelViewProjectionStack removeAllObjects];
	_modelView = identity4x4();
	_modelViewProjection = mult(_modelView, _projection);
}

@end




//////////////////////////////////////////////////////////////////////
///
/// @class HitInfo
///
/// Ray-geometry intersection information.
///
//////////////////////////////////////////////////////////////////////
@implementation HitInfo

@end

