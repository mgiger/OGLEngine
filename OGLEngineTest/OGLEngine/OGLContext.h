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

@interface OGLBuffer : NSObject

@property (nonatomic, assign)	BOOL		available;
@property (nonatomic, assign)	BOOL		arrayBuffer;
@property (nonatomic, assign)	NSUInteger	bufferID;

- (id)initArrayBuffer;
- (id)initIndexBuffer;
- (void)uploadData:(NSData*)data;
- (void)bind;
- (void)unbind;

@end

@interface OGLVertexArray : NSObject

- (void)bind;
- (void)unbind;

@end

@interface OGLFramebuffer : NSObject

@property (nonatomic, assign)	unsigned int	framebufferID;

- (void)bind;
- (void)unbind;
- (BOOL)attachTexture:(OGLTexture*)texture;

@end
