//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//



#import <Foundation/Foundation.h>

@interface OGLBuffer : NSObject

@property (nonatomic, assign)	BOOL			available;
@property (nonatomic, assign)	BOOL			arrayBuffer;
@property (nonatomic, assign)	unsigned int	bufferID;

- (id)initArrayBuffer;
- (id)initIndexBuffer;
- (void)uploadData:(NSData*)data;
- (void)bind;
- (void)unbind;

@end
