///
/// OGLRenderInfo
///
/// Created by Matt Giger
/// Copyright (c) 2013 EarthBrowser LLC. All rights reserved.
///

#import "OGLRenderInfo.h"
#import "OGLCamera.h"

#include <OpenGLES/ES2/gl.h>

@interface OGLRenderInfo()
{
	NSMutableArray*		_modelViewStack;
	NSMutableArray*		_modelViewProjectionStack;
}

@end


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
		
		_projection = identity4x4();
		_modelView = identity4x4();
		_modelViewProjection = identity4x4();
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
		[val getValue:&_modelViewProjection];
		[_modelViewProjectionStack removeLastObject];
	}
}

- (void)pushTransform:(CGFloat4x4)xform
{
	[_modelViewStack addObject:[NSValue valueWithBytes:&xform objCType:@encode(CGFloat4x4)]];
	_modelView = mult(xform, _modelView);
	
	[_modelViewProjectionStack addObject:[NSValue valueWithBytes:&_modelViewProjection objCType:@encode(CGFloat4x4)]];
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




@implementation OGLHitInfo

@end

