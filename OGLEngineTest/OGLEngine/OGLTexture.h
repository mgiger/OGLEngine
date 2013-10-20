///
/// OGLTexture
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


#import <UIKit/UIKit.h>

@class OGLTextureData;

///////////////////////////////////////////////////////////////////////////
///
/// @class OGLTexture
///
/// OpenGL texture object
///
///////////////////////////////////////////////////////////////////////////
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


///////////////////////////////////////////////////////////////////////////
///
/// @class OGLTextureData
///
/// Raw texture data
///
///////////////////////////////////////////////////////////////////////////
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
+ (NSString*)rawPathForURL:(NSString*)url withBase:(NSString*)basePath;
//+ (OGLTextureData*)dataWithRawMMapPath:(NSString*)rawPath;

- (void)loadResourcePath:(NSString*)path;
- (void)loadCGImage:(CGImageRef)imageRef;
- (void)drawImage:(UIImage*)image atOffset:(CGPoint)offset;
- (NSString*)saveRawURL:(NSString*)url withBase:(NSString*)basePath;
- (UIImage*)extractImage;
- (void)saveToDiskPNG:(NSString*)filePath;
- (void)saveToDiskJPG:(NSString*)filePath;

@end
