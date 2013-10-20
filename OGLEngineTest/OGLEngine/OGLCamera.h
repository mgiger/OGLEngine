//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLEngine.h"

@interface OGLCamera : NSObject

@property (nonatomic, assign)	BOOL		ortho;
@property (nonatomic, assign)	CGFloat		fov;
@property (nonatomic, assign)	CGFloat		aspect;
@property (nonatomic, assign)	CGSize		screenSize;
@property (nonatomic, assign)	CGFloat		near;
@property (nonatomic, assign)	CGFloat		far;
@property (nonatomic, assign)	OGLFloat3	position;
@property (nonatomic, assign)	OGLFloat3	forward;
@property (nonatomic, assign)	OGLFloat3	up;
@property (nonatomic, assign)	OGLFloat4x4	transform;
@property (nonatomic, readonly)	BOOL		active;
@property (nonatomic, readonly)	OGLFloat4x4	projection;
@property (nonatomic, readonly)	OGLFloat4x4	modelview;
@property (nonatomic, readonly)	OGLFloat4x4	modelViewProjection;
@property (nonatomic, readonly)	OGLFrustum	viewFrustum;

- (void)updateDirty;
- (void)render:(OGLRenderInfo*)info;
- (OGLRay)calcRay:(CGPoint)pt;

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
