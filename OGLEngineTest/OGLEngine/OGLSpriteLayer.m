///
/// OGLSpriteLayer
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

#import "OGLSpriteLayer.h"
#import "OGLCamera.h"

@interface OGLSpriteLayer()

@property (nonatomic, strong)	OGLCamera*	camera;
@property (nonatomic, assign)	CGFloat		touchPixelRadius;

@end


@implementation OGLSpriteLayer

- (id)init
{
	if(self = [super init])
	{	
		_touchPixelRadius = 10 * [UIScreen mainScreen].scale;
		_selectedSet = [[NSMutableArray alloc] init];
		
		_camera = [[OGLCamera alloc] init];
		_camera.ortho = YES;
		_camera.position = CGFloat3Make(0, 0, 101.0f);
		_camera.forward = CGFloat3Make(0, 0, -1);
		_camera.near = 100;
		_camera.far = -100;
	}
	return self;
}

- (void)setScreenSize:(CGSize)ssize
{
	[_camera setScreenSize:ssize];
}

- (NSMutableArray*)findSelected:(CGRect)bounds
{
	NSMutableArray* array = [NSMutableArray array];
	for(OGLSceneObject* obj in self.children)
	{
		if(obj.visible)
			[obj intersectBounds:bounds withXForm:identity4x4() intoArray:array];
	}
	[array sortUsingSelector:@selector(compare:)];
	return array;
}

- (void)render:(OGLRenderInfo *)info
{
	[_camera render:info];
	[super render:info];
}


@end
