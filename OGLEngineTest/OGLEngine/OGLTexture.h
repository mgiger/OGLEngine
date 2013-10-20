//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLEngine.h"

@interface OGLTexture : NSObject

@property (nonatomic, assign)	BOOL	available;
@property (nonatomic, assign)	uint	textureID;
@property (nonatomic, assign)	uint	unit;
@property (nonatomic, assign)	int		width;
@property (nonatomic, assign)	int		height;

+ (OGLTexture*)textureWithName:(NSString*)name;

- (void)uploadData:(OGLTextureData*)data;
- (void)bindTo:(int)binding unit:(int)unit;
- (void)unbind;

@end


@interface OGLTextureData : NSObject

@property (nonatomic, assign)	int		width;
@property (nonatomic, assign)	int		height;
@property (nonatomic, assign)	int		depth;
@property (nonatomic, assign)	BOOL	floatTexture;
@property (nonatomic, strong)	NSData*	data;

+ (OGLTextureData*)dataWithPath:(NSString*)path;
+ (OGLTextureData*)dataWithImage:(CGImageRef)imgRef;
+ (OGLTextureData*)dataWithData:(NSData*)data size:(CGSize)size depth:(int)depth;
+ (OGLTextureData*)dataWithUChar:(void*)ptr length:(int)length size:(CGSize)size noCopy:(BOOL)noCopy;
+ (OGLTextureData*)dataWithFloat:(void*)ptr length:(int)length size:(CGSize)size noCopy:(BOOL)noCopy;
+ (OGLTextureData*)blankData:(CGSize)size;

- (void)loadResourcePath:(NSString*)path;
- (void)loadCGImage:(CGImageRef)imageRef;
- (void)drawImage:(UIImage*)image atOffset:(CGPoint)offset;
- (NSString*)saveRawURL:(NSString*)url withBase:(NSString*)basePath;
- (UIImage*)extractImage;
- (void)saveToDiskPNG:(NSString*)filePath;
- (void)saveToDiskJPG:(NSString*)filePath;

@end
