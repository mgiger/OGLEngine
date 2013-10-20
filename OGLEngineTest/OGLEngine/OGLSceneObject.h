///
/// OGLSceneObject
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

//////////////////////////////////////////////////////////////////////
///
/// @class SceneObject
///
/// Base Scene object.
///
//////////////////////////////////////////////////////////////////////
@interface OGLSceneObject : NSObject

@property (nonatomic, assign)	BOOL				visible;
@property (nonatomic, assign)	BOOL				hasGeometry;
@property (nonatomic, assign)	CGCube				bbox;
@property (nonatomic, assign)	CGFloat4x4			transform;
@property (nonatomic, assign)	CGRect				bounds;
@property (nonatomic, strong)	NSMutableArray*		children;
@property (nonatomic, copy)		TapGestureBlock		tapEventHandler;
@property (nonatomic, copy)		TapGestureBlock		doubleTapEventHandler;
@property (nonatomic, copy)		PanGestureBlock		panEventHandler;
@property (nonatomic, copy)		PinchGestureBlock	pinchEventHandler;

- (void)addChildren:(NSArray*)children;
- (void)addChild:(OGLSceneObject*)child;
- (void)removeChild:(OGLSceneObject*)child;
- (void)removeAllChildren;

- (void)intersectBounds:(CGRect)touchArea withXForm:(CGFloat4x4)xform intoArray:(NSMutableArray*)array;
- (void)rayIntersect:(CGRay)r hitList:(NSMutableArray*)hits xform:(CGFloat4x4)xform;

- (OGLSceneObject*)handleTap:(UITapGestureRecognizer*)gesture;
- (OGLSceneObject*)handleDoubleTap:(UITapGestureRecognizer*)gesture;
- (OGLSceneObject*)handlePan:(UIPanGestureRecognizer*)gesture;
- (OGLSceneObject*)handlePinch:(UIPinchGestureRecognizer*)gesture;

- (CGFloat4x4)rotationlessTransform;
- (void)render:(OGLRenderInfo*)info;

@end

@interface OGLSceneObjectSelWrapper : NSObject

@property (nonatomic, strong)	OGLSceneObject*	object;
@property (nonatomic, assign)	CGFloat4x4		transform;

+ (OGLSceneObjectSelWrapper*)wrapperWithObject:(OGLSceneObject*)obj withXForm:(CGFloat4x4)xform;

@end