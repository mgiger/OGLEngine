///
/// OGLShader
///
/// Created by Matt Giger
/// Copyright (c) 2013 EarthBrowser LLC. All rights reserved.
///


#import "OGLEngine.h"

#define OGLSTRINGIFY(x)	#x
#define OGLNSSTRINGIFY(x)	@ OGLSTRINGIFY(x)

@interface OGLShader : NSObject

@property (nonatomic, assign)	GLuint		program;
@property (nonatomic, copy)		NSString*	vertSource;
@property (nonatomic, copy)		NSString*	fragSource;

- (BOOL)loadShader;

- (int)uniformForName:(NSString*)name;
- (int)attributeForName:(NSString*)name;

- (BOOL)bindShader:(OGLRenderInfo*)info;
- (void)unbindShader:(OGLRenderInfo*)info;

@end


@interface OGLFlatShader : OGLShader

@property (nonatomic, assign)	OGLFloat4	color;

+ (OGLFlatShader*)shader;

@end
