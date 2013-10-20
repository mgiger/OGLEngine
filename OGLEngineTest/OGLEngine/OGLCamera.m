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
		_position = CGFloat3Make(0, 0, 0);
		_forward = CGFloat3Make(0, 0, -1);
		_up = CGFloat3Make(0, 1, 0);
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
- (void)setAspect:(float)value					{ _aspect = value; _dirty = YES; }
- (CGSize)screenSize							{ return _screenSize; }
- (void)setScreenSize:(CGSize)value				{ _screenSize = value; _dirty = YES; }
- (CGFloat)near									{ return _near; }
- (void)setNear:(CGFloat)near					{ _near = near; _dirty = YES; }
- (CGFloat)far									{ return _far; }
- (void)setFar:(CGFloat)far						{ _far = far; _dirty = YES; }
- (CGFloat3)position							{ return _position; }
- (void)setPosition:(CGFloat3)value				{ _position = value; _dirty = YES; }
- (CGFloat3)forward								{ return _forward; }
- (void)setForward:(CGFloat3)value				{ _forward = value; _dirty = YES; }
- (CGFloat3)up									{ return _up; }
- (void)setUp:(CGFloat3)value					{ _up = value; _dirty = YES; }
- (CGFloat4x4)transform							{ return _transform; }
- (void)setTransform:(CGFloat4x4)value			{ _transform = value; _dirty = YES; }
- (CGFloat4x4)projection						{ return _projection; }
- (CGFloat4x4)modelview							{ return _modelview; }
- (CGFloat4x4)modelViewProjection				{ return _mvp; }

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
	_viewFrustum = CGFrustumMake(_mvp);
}

- (void)render:(OGLRenderInfo*)info
{
	if(_dirty)
		[self updateDirty];
	
	[info setProjection:_projection];
	[info pushTransform:_modelview];
	[info setViewfrust:_viewFrustum];
}

- (CGRay)calcRay:(CGPoint)pos
{	
	CGPoint vp_pt = CGPointMake(pos.x*2.0/_screenSize.width - 1.0, 1.0 - pos.y*2.0/_screenSize.height);
	CGFloat4x4 mvinverse = inverse(_mvp);
//	float4x4 mvinverse = inverse(_modelview * _projection);
	CGFloat4 onear = multVec4(mvinverse, CGFloat4Make(vp_pt.x, vp_pt.y, 0, 1));
	CGFloat4 ofar = multVec4(mvinverse, CGFloat4Make(vp_pt.x, vp_pt.y, 1, 1));
	CGFloat3 npos = {onear.x/onear.w, onear.y/onear.w, onear.z/onear.w};
	CGFloat3 fpos = {ofar.x/ofar.w, ofar.y/ofar.w, ofar.z/ofar.w};
	return CGRayMake(npos, normalVec3(CGFloat3Make(fpos.x - npos.x, fpos.y - npos.y, fpos.z - npos.z)));
}

- (void)handleTap
{
//	[self resetMovement];
}

- (void)doubleTapEvent:(CGPoint)point
{
//	[self resetMovement];
//	
//	_anchorPos = _lastPos = point;
//	_autoRotation = 0;
//	_didDblClick = true;
//	
//	
//	ray r = [self calcRay:point];
//	r.origin = _position;
//	float dist = _sphere.intersect_ray(r);
//	if(dist > 0)
//	{
//		spherical sph(cartesian(r * dist));
//		float lvl = [EBCamera altitude_lvl:_damping.current.x - c_radius];
//		float alt = [EBCamera lvl_elev:std::max(0.0f, lvl-100)];
//		sph.x = c_radius + _min_altitude + std::max(_min_altitude, std::min(alt, c_max_cent_dist));
//		[self rotate_to:sph setElevation:YES withDamping:c_move_spring_damping];
//	}
//	else
//	{
//		// zoom straight in
//		spherical sph(_damping.current);
//		float lvl = [EBCamera altitude_lvl:_damping.current.x - c_radius];
//		float alt = [EBCamera lvl_elev:std::max(0.0f, lvl-100)];
//		sph.x = c_radius + _min_altitude + std::max(_min_altitude, std::min(alt, c_max_cent_dist));
//		[self rotate_to:sph setElevation:YES withDamping:c_move_spring_damping];
//	}
}

- (void)doubleTouchEvent:(CGPoint)touchPoint
{
//	[self resetMovement];
//	
//	_anchorPos = _lastPos = touchPoint;
//	_autoRotation = 0;
//	
//	EBLatLonAlt* point = self.currentCoordinate;
//	float alt = std::max(c_def_alt, (_damping.current.x - c_wgs_a) * 2.0f);
//	
//	point.altitude = alt;
//	[self animateToLatLonAlt:point speed:0.2];
}

- (void)beginPan:(CGPoint)anchor
{
//	[self resetMovement];
//	
//	_anchorPos = _lastPos = anchor;
}

- (void)panEvent:(CGPoint)position
{
//	_didDrag = true;
//	_lastRotTime = CFAbsoluteTimeGetCurrent();
//	[self rotate_globe:position isReverse:NO];
//	_lastPos = position;
}

- (void)endPan
{
//	_isZooming = NO;
//	_autoRotation = 0.0;
//	
//	if(_lastRotTime + c_drag_glide_timelimit > CFAbsoluteTimeGetCurrent())
//	{
//		for(int i=0;i<c_max_mouse_samples;i++)
//			_autoRotation += _mouseSamples[i];
//		_autoRotation /= c_max_mouse_samples;
//		
//		if(std::fabs(_mouseSamples[(_msampleIndex - 1) % c_max_mouse_samples]) < 0.01)
//			_autoRotation = 0;
//	}
//	
//	[[NSNotificationCenter defaultCenter] postNotificationName:kCameraActive object:nil];
}

- (void)beginPinchWithTouch:(CGPoint)anchor0 andTouch:(CGPoint)anchor1
{
//	_isZooming = YES;
//	[self resetMovement];
//	
//	_anchorPos = _lastPos = anchor0;
//	_zoomSpacing = (_anchorPos - anchor1).length();
}

- (void)pinchEvent:(CGFloat)scale
{
//	float spacing = _zoomSpacing * scale;
//	float alt = _damping.current.x - c_radius;
//	float sensitivity = std::pow(alt * c_zoom_sensitivity, 0.85f);
//	float delta = (_zoomSpacing - spacing) * sensitivity;
//	_damping.target.x = std::max(_min_cent_dist, std::min(_springAnchor.x + delta, c_max_cent_dist));
}


- (void)updateOrientation:(int)orientation withWidth:(CGFloat)width withHeight:(CGFloat)height
{
	_screenSize = CGSizeMake(width, height);
	_aspect = (float)width/height;
	_dirty = YES;
}

@end

