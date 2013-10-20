//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//	documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
//	to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
//	THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#ifndef OGLEngineTest_OGLEngine_h
#define OGLEngineTest_OGLEngine_h

struct CGFloat3 {
	CGFloat x;
	CGFloat y;
	CGFloat z;
};
typedef struct CGFloat3 CGFloat3;

struct CGFloat4 {
	CGFloat x;
	CGFloat y;
	CGFloat z;
	CGFloat w;
};
typedef struct CGFloat4 CGFloat4;

struct CGFloat4x4 {
	CGFloat	mat[4][4];
};
typedef struct CGFloat4x4 CGFloat4x4;

struct CGQuaternion {
	CGFloat	w;
	CGFloat	x;
	CGFloat	y;
	CGFloat	z;
};
typedef struct CGQuaternion CGQuaternion;

struct CGCube {
	CGFloat3	minc;
	CGFloat3	maxc;
};
typedef struct CGCube CGCube;

struct CGRay {
	CGFloat3	origin;
	CGFloat3	direction;
};
typedef struct CGRay CGRay;

struct CGSphere {
	CGFloat3	center;
	CGFloat		radius, radius_sq;
};
typedef struct CGSphere CGSphere;

struct CGPlane {
	CGFloat	a;
	CGFloat	b;
	CGFloat	c;
	CGFloat	d;
};
typedef struct CGPlane CGPlane;

struct CGFrustum {
	
	CGPlane		plane[6];		///< Six frustum planes
	CGSphere	bnd_sphere;		///< Bounding sphere
};
typedef struct CGFrustum CGFrustum;

@class OGLBuffer;
@class OGLCamera;
@class OGLContext;
@class OGLFramebuffer;
@class OGLTexture;
@class OGLTextureData;
@class OGLVertexArray;
@class OGLEngineView;
@class OGLRenderInfo;
@class OGLSceneObject;
@class OGLShader;
@class OGLSpriteLayer;
@class OGLAnnotationView;

typedef void (^OGLSimpleBlock)(void);
typedef OGLSceneObject* (^TapGestureBlock)(UITapGestureRecognizer*);
typedef OGLSceneObject* (^PanGestureBlock)(UIPanGestureRecognizer*);
typedef OGLSceneObject* (^PinchGestureBlock)(UIPinchGestureRecognizer*);


CGFloat3 CGFloat3Make(CGFloat x, CGFloat y, CGFloat z);
CGFloat3 CGFloat3Mult(CGFloat3 a, CGFloat v);
CGFloat4 CGFloat4Make(CGFloat x, CGFloat y, CGFloat z, CGFloat w);
CGQuaternion CGQuaternionMake(CGFloat angle, CGFloat3 axis);
CGFrustum CGFrustumMake(CGFloat4x4 mvp);
CGRay CGRayMake(CGFloat3 origin, CGFloat3 direction);

CGFloat4x4 identity4x4();
CGFloat4x4 scaleVec4x4(CGFloat3 a);
CGFloat4x4 scale4x4(CGFloat x, CGFloat y, CGFloat z);
CGFloat4x4 translationVec4x4(CGFloat3 a);
CGFloat4x4 translation4x4(CGFloat x, CGFloat y, CGFloat z);
CGFloat4x4 rotation4x4(CGFloat angle, CGFloat3 axis);
CGFloat4x4 orthographic4x4(CGFloat left, CGFloat right, CGFloat bottom, CGFloat top, CGFloat znear, CGFloat zfar);
CGFloat4x4 perspective4x4(CGFloat fov, CGFloat aspect, CGFloat near, CGFloat far);
CGFloat4x4 look_toward4x4(CGFloat3 forward, CGFloat3 up);

CGFloat3 normalVec3(CGFloat3 a);
CGFloat3 cross(CGFloat3 a, CGFloat3 b);
CGFloat3 multVec3(CGFloat4x4 m, CGFloat3 a);
CGFloat4 multVec4(CGFloat4x4 m, CGFloat4 a);
CGFloat length3(CGFloat3 a);

CGFloat4x4 mult(CGFloat4x4 a, CGFloat4x4 b);
CGFloat4x4 inverse(CGFloat4x4 m);
CGRect multRect(CGFloat4x4 m, CGRect r);

CGRay multRay(CGRay r, CGFloat4x4 m);
BOOL cubeRayInersect(CGCube cube, CGRay ray, CGFloat3* hitLocation);


extern float			_ScreenScale;

#endif
