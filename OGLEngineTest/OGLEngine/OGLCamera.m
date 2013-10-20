//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLCamera.h"
#import "OGLRenderInfo.h"


@interface OGLCamera()
{
	BOOL	_dirty;
}

@end

@implementation OGLCamera

@synthesize ortho = _ortho;
@synthesize fov = _fov;
@synthesize aspect = _aspect;
@synthesize screenSize = _screenSize;
@synthesize near = _near;
@synthesize far = _far;
@synthesize position = _position;
@synthesize forward = _forward;
@synthesize up = _up;
@synthesize transform = _transform;
@synthesize projection = _projection;
@synthesize modelview = _modelview;
@synthesize modelViewProjection = _mvp;

- (id) init
{
	if(self = [super init])
	{
		_position = OGLFloat3Make(0, 0, 0);
		_forward = OGLFloat3Make(0, 0, -1);
		_up = OGLFloat3Make(0, 1, 0);
		_screenSize = CGSizeMake(1, 1);
		_transform = identity4x4();
		_modelview = identity4x4();
		_mvp = identity4x4();
	}
	return self;
}

- (BOOL)ortho									{ return _ortho; }
- (void)setOrtho:(BOOL)value					{ _ortho = value; _dirty = YES; }
- (CGFloat)fov									{ return _fov; }
- (void)setFov:(CGFloat)value					{ _fov = value; _ortho = NO; _dirty = YES; }
- (CGFloat)aspect								{ return _aspect; }
- (void)setAspect:(CGFloat)value					{ _aspect = value; _dirty = YES; }
- (CGSize)screenSize							{ return _screenSize; }
- (void)setScreenSize:(CGSize)value				{ _screenSize = value; _dirty = YES; }
- (CGFloat)near									{ return _near; }
- (void)setNear:(CGFloat)near					{ _near = near; _dirty = YES; }
- (CGFloat)far									{ return _far; }
- (void)setFar:(CGFloat)far						{ _far = far; _dirty = YES; }
- (OGLFloat3)position							{ return _position; }
- (void)setPosition:(OGLFloat3)value				{ _position = value; _dirty = YES; }
- (OGLFloat3)forward								{ return _forward; }
- (void)setForward:(OGLFloat3)value				{ _forward = value; _dirty = YES; }
- (OGLFloat3)up									{ return _up; }
- (void)setUp:(OGLFloat3)value					{ _up = value; _dirty = YES; }
- (OGLFloat4x4)transform							{ return _transform; }
- (void)setTransform:(OGLFloat4x4)value			{ _transform = value; _dirty = YES; }
- (OGLFloat4x4)projection						{ return _projection; }
- (OGLFloat4x4)modelview							{ return _modelview; }
- (OGLFloat4x4)modelViewProjection				{ return _mvp; }

- (void)updateDirty
{
	_dirty = NO;
	if(_ortho)
	{
		_projection = mult(orthographic4x4(0, _screenSize.width, _screenSize.height, 0, _near, _far), _transform);
		_modelview = look_toward4x4(_forward, _up);
	}
	else
	{
		_projection = mult(perspective4x4(_fov, _aspect, _near, _far), _transform);
		_modelview = mult(translation4x4(-_position.x, -_position.y, -_position.z), look_toward4x4(_forward, _up));
	}
	_mvp = mult(_projection, _modelview);
	_viewFrustum = OGLFrustumMake(_mvp);
}

- (void)render:(OGLRenderInfo*)info
{
	if(_dirty)
		[self updateDirty];
	
	[info setProjection:_projection];
	[info pushTransform:_modelview];
	[info setViewfrust:_viewFrustum];
}

- (OGLRay)calcRay:(CGPoint)pos
{	
	CGPoint vp_pt = CGPointMake(pos.x*2.0/_screenSize.width - 1.0, 1.0 - pos.y*2.0/_screenSize.height);
	OGLFloat4x4 mvinverse = inverse(_mvp);
//	float4x4 mvinverse = inverse(_modelview * _projection);
	OGLFloat4 onear = multVec4(mvinverse, OGLFloat4Make(vp_pt.x, vp_pt.y, 0, 1));
	OGLFloat4 ofar = multVec4(mvinverse, OGLFloat4Make(vp_pt.x, vp_pt.y, 1, 1));
	OGLFloat3 npos = {onear.x/onear.w, onear.y/onear.w, onear.z/onear.w};
	OGLFloat3 fpos = {ofar.x/ofar.w, ofar.y/ofar.w, ofar.z/ofar.w};
	return OGLRayMake(npos, normalVec3(OGLFloat3Make(fpos.x - npos.x, fpos.y - npos.y, fpos.z - npos.z)));
}

- (void)handleTap
{
}

- (void)doubleTapEvent:(CGPoint)point
{
}

- (void)doubleTouchEvent:(CGPoint)touchPoint
{
}

- (void)beginPan:(CGPoint)anchor
{
}

- (void)panEvent:(CGPoint)position
{
}

- (void)endPan
{
}

- (void)beginPinchWithTouch:(CGPoint)anchor0 andTouch:(CGPoint)anchor1
{
}

- (void)pinchEvent:(CGFloat)scale
{
}

- (void)updateOrientation:(int)orientation withWidth:(CGFloat)width withHeight:(CGFloat)height
{
	_screenSize = CGSizeMake(width, height);
	_aspect = (float)width/height;
	_dirty = YES;
}

@end

