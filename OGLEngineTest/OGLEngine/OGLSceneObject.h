//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLEngine.h"

@interface OGLSceneObject : NSObject

@property (nonatomic, assign)	BOOL				visible;
@property (nonatomic, assign)	BOOL				hasGeometry;
@property (nonatomic, assign)	OGLCube				bbox;
@property (nonatomic, assign)	OGLFloat4x4			transform;
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

- (void)intersectBounds:(CGRect)touchArea withXForm:(OGLFloat4x4)xform intoArray:(NSMutableArray*)array;
- (void)rayIntersect:(OGLRay)r hitList:(NSMutableArray*)hits xform:(OGLFloat4x4)xform;

- (OGLSceneObject*)handleTap:(UITapGestureRecognizer*)gesture;
- (OGLSceneObject*)handleDoubleTap:(UITapGestureRecognizer*)gesture;
- (OGLSceneObject*)handlePan:(UIPanGestureRecognizer*)gesture;
- (OGLSceneObject*)handlePinch:(UIPinchGestureRecognizer*)gesture;

- (OGLFloat4x4)rotationlessTransform;
- (void)render:(OGLRenderInfo*)info;

@end

@interface OGLSceneObjectSelWrapper : NSObject

@property (nonatomic, strong)	OGLSceneObject*	object;
@property (nonatomic, assign)	OGLFloat4x4		transform;

+ (OGLSceneObjectSelWrapper*)wrapperWithObject:(OGLSceneObject*)obj withXForm:(OGLFloat4x4)xform;

@end