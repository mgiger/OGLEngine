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

#ifndef _OGLEngine_
#define _OGLEngine_

struct OGLFloat3 {
	float x;
	float y;
	float z;
};
typedef struct OGLFloat3 OGLFloat3;

struct OGLFloat4 {
	float x;
	float y;
	float z;
	float w;
};
typedef struct OGLFloat4 OGLFloat4;

struct OGLFloat4x4 {
	float	mat[4][4];
};
typedef struct OGLFloat4x4 OGLFloat4x4;

struct OGLQuaternion {
	float	w;
	float	x;
	float	y;
	float	z;
};
typedef struct OGLQuaternion OGLQuaternion;

struct OGLCube {
	OGLFloat3	minc;
	OGLFloat3	maxc;
};
typedef struct OGLCube OGLCube;

struct OGLRay {
	OGLFloat3	origin;
	OGLFloat3	direction;
};
typedef struct OGLRay OGLRay;

struct OGLSphere {
	OGLFloat3	center;
	float		radius, radius_sq;
};
typedef struct OGLSphere OGLSphere;

struct OGLPlane {
	float	a;
	float	b;
	float	c;
	float	d;
};
typedef struct OGLPlane OGLPlane;

struct OGLFrustum {
	
	OGLPlane		plane[6];		///< Six frustum planes
	OGLSphere	bnd_sphere;		///< Bounding sphere
};
typedef struct OGLFrustum OGLFrustum;

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
@class OGLAnnotation;
@class OGLAnnotationView;

typedef void (^OGLSimpleBlock)(void);
typedef OGLSceneObject* (^TapGestureBlock)(UITapGestureRecognizer*);
typedef OGLSceneObject* (^PanGestureBlock)(UIPanGestureRecognizer*);
typedef OGLSceneObject* (^PinchGestureBlock)(UIPinchGestureRecognizer*);


OGLFloat3 OGLFloat3Make(float x, float y, float z);
OGLFloat3 OGLFloat3Mult(OGLFloat3 a, float v);
OGLFloat4 OGLFloat4Make(float x, float y, float z, float w);
OGLQuaternion OGLQuaternionMake(float angle, OGLFloat3 axis);
OGLFrustum OGLFrustumMake(OGLFloat4x4 mvp);
OGLRay OGLRayMake(OGLFloat3 origin, OGLFloat3 direction);

OGLFloat4x4 identity4x4();
OGLFloat4x4 scaleVec4x4(OGLFloat3 a);
OGLFloat4x4 scale4x4(float x, float y, float z);
OGLFloat4x4 translationVec4x4(OGLFloat3 a);
OGLFloat4x4 translation4x4(float x, float y, float z);
OGLFloat4x4 rotation4x4(float angle, OGLFloat3 axis);
OGLFloat4x4 orthographic4x4(float left, float right, float bottom, float top, float znear, float zfar);
OGLFloat4x4 perspective4x4(float fov, float aspect, float near, float far);
OGLFloat4x4 look_toward4x4(OGLFloat3 forward, OGLFloat3 up);

OGLFloat3 normalVec3(OGLFloat3 a);
OGLFloat3 cross(OGLFloat3 a, OGLFloat3 b);
OGLFloat3 multVec3(OGLFloat4x4 m, OGLFloat3 a);
OGLFloat4 multVec4(OGLFloat4x4 m, OGLFloat4 a);
float length3(OGLFloat3 a);

OGLFloat4x4 mult(OGLFloat4x4 a, OGLFloat4x4 b);
OGLFloat4x4 inverse(OGLFloat4x4 m);
CGRect multRect(OGLFloat4x4 m, CGRect r);

OGLRay multRay(OGLRay r, OGLFloat4x4 m);
BOOL cubeRayInersect(OGLCube cube, OGLRay ray, OGLFloat3* hitLocation);


extern float			_ScreenScale;

#endif
