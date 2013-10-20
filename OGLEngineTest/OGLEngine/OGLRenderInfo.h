//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLEngine.h"

static const int		c_texture_units		= 8;

@interface OGLRenderInfo : NSObject

@property (nonatomic, strong)	OGLCamera*		camera;
@property (nonatomic, strong)	OGLShader*		shader;
@property (nonatomic, strong)	OGLSpriteLayer*	spriteLayer;
@property (nonatomic, assign)	int				screenWidth;
@property (nonatomic, assign)	int				screenHeight;
@property (nonatomic, assign)	OGLFrustum		viewfrust;
@property (nonatomic, assign)	int				vcoordBinding;
@property (nonatomic, assign)	int				tcoordBinding;
@property (nonatomic, assign)	int				tex0Binding;
@property (nonatomic, assign)	int				tex1Binding;
@property (nonatomic, assign)	int				tex2Binding;
@property (nonatomic, assign)	OGLFloat4x4		projection;
@property (nonatomic, assign)	OGLFloat4x4		modelView;
@property (nonatomic, assign)	OGLFloat4x4		modelViewProjection;

- (id)initWithCamera:(OGLCamera*)cam withSpriteLayer:(OGLSpriteLayer*)slayer;

- (void)popTransform;
- (void)pushTransform:(OGLFloat4x4)xform;
- (void)resetTransforms;

@end


@interface OGLHitInfo : NSObject

@property (nonatomic, assign)	CGPoint			screenPos;		///< Screen location of mouse
@property (nonatomic, assign)	OGLRay			hitRay;			///< Ray being tested
@property (nonatomic, assign)	CGFloat			distance;		///< Distance from ray origin of hit
@property (nonatomic, assign)	OGLFloat3		objectPos;		///< Hit location in object space
@property (nonatomic, assign)	OGLFloat3		worldPos;		///< Hit location in world space
@property (nonatomic, strong)	OGLSceneObject*	hitObject;		///< Object containing hit geometry

@end
