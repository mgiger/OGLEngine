///
/// OGLCamera
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

///////////////////////////////////////////////////////////////////////////
///
/// @class OGLCamera
///
/// Base camera implementation
///
///////////////////////////////////////////////////////////////////////////
@interface OGLCamera : NSObject

@property (nonatomic, assign)	BOOL		ortho;
@property (nonatomic, assign)	CGFloat		fov;
@property (nonatomic, assign)	CGFloat		aspect;
@property (nonatomic, assign)	CGSize		screenSize;
@property (nonatomic, assign)	CGFloat		near;
@property (nonatomic, assign)	CGFloat		far;
@property (nonatomic, assign)	CGFloat3	position;
@property (nonatomic, assign)	CGFloat3	forward;
@property (nonatomic, assign)	CGFloat3	up;
@property (nonatomic, assign)	CGFloat4x4	transform;
@property (nonatomic, readonly)	BOOL		active;
@property (nonatomic, readonly)	CGFloat4x4	projection;
@property (nonatomic, readonly)	CGFloat4x4	modelview;
@property (nonatomic, readonly)	CGFloat4x4	modelViewProjection;
@property (nonatomic, readonly)	CGFrustum	viewFrustum;

- (void)updateDirty;
- (void)render:(OGLRenderInfo*)info;
- (CGRay)calcRay:(CGPoint)pt;

- (void)handleTap;
- (void)doubleTapEvent:(CGPoint)point;
- (void)doubleTouchEvent:(CGPoint)point;
- (void)beginPan:(CGPoint)anchor;
- (void)panEvent:(CGPoint)position;
- (void)endPan;
- (void)beginPinchWithTouch:(CGPoint)anchor0 andTouch:(CGPoint)anchor2;
- (void)pinchEvent:(CGFloat)scale;

- (void)updateOrientation:(int)orientation withWidth:(CGFloat)width withHeight:(CGFloat)height;

@end
