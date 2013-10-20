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

#import "OGLEngine.h"

extern float			_ScreenScale;
static const int		c_texture_units		= 8;

///////////////////////////////////////////////////////////////////////////
///
/// @class OGLRenderInfo
///
/// Controls render state
///
///////////////////////////////////////////////////////////////////////////
@interface OGLRenderInfo : NSObject

@property (nonatomic, strong)	OGLCamera*		camera;
@property (nonatomic, strong)	OGLShader*		shader;
@property (nonatomic, strong)	OGLSpriteLayer*	spriteLayer;
@property (nonatomic, assign)	int				screenWidth;
@property (nonatomic, assign)	int				screenHeight;
@property (nonatomic, assign)	CGFrustum		viewfrust;
@property (nonatomic, assign)	int				vcoordBinding;
@property (nonatomic, assign)	int				tcoordBinding;
@property (nonatomic, assign)	int				tex0Binding;
@property (nonatomic, assign)	int				tex1Binding;
@property (nonatomic, assign)	int				tex2Binding;
@property (nonatomic, assign)	CGFloat4x4		projection;
@property (nonatomic, assign)	CGFloat4x4		modelView;
@property (nonatomic, assign)	CGFloat4x4		modelViewProjection;

- (id)initWithCamera:(OGLCamera*)cam withSpriteLayer:(OGLSpriteLayer*)slayer;

- (void)popTransform;
- (void)pushTransform:(CGFloat4x4)xform;
- (void)resetTransforms;

@end


//////////////////////////////////////////////////////////////////////
///
/// @class HitInfo
///
/// Ray-geometry intersection information.
///
//////////////////////////////////////////////////////////////////////
@interface HitInfo : NSObject

@property (nonatomic, assign)	CGPoint			screenPos;		///< Screen location of mouse
@property (nonatomic, assign)	CGRay			hitRay;			///< Ray being tested
@property (nonatomic, assign)	CGFloat			distance;		///< Distance from ray origin of hit
@property (nonatomic, assign)	CGFloat3		objectPos;		///< Hit location in object space
@property (nonatomic, assign)	CGFloat3		worldPos;		///< Hit location in world space
@property (nonatomic, strong)	OGLSceneObject*	hitObject;		///< Object containing hit geometry

@end
