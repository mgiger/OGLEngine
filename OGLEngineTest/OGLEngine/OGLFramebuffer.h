//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLEngine.h"

@interface OGLFramebuffer : NSObject

@property (nonatomic, assign)	unsigned int	framebufferID;

- (void)bind;
- (void)unbind;
- (BOOL)attachTexture:(OGLTexture*)texture;

@end
