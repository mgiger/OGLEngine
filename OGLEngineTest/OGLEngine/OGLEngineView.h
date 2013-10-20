//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "OGLEngine.h"

@interface OGLEngineView : GLKView

@property (nonatomic, assign)	OGLFloat4			backColor;
@property (nonatomic, strong)	OGLCamera*			camera;
@property (nonatomic, strong)	OGLSceneObject*		rootObject;
@property (nonatomic, strong)	OGLSpriteLayer*		userInterface;

- (void)startRendering;
- (void)stopRendering;
- (void)setupScene;

@end
