//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLEngine.h"

@interface OGLContext : NSObject

@property (nonatomic, strong)	EAGLContext*	context;

+ (OGLContext*)main;
+ (OGLContext*)worker;
+ (void)updateContexts;

- (id)initWithAPI:(EAGLRenderingAPI)api;
- (id)initWithAPI:(EAGLRenderingAPI)api withSharegroup:(EAGLSharegroup*)sharegroup;

- (void)setCurrent;
- (void)uploadData:(NSData*)data intoBuffer:(OGLBuffer*)buffer;
- (void)uploadData:(OGLTextureData*)data intoTexture:(OGLTexture*)texture;

@end
