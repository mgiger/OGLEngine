//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLTexture.h"

static NSMutableDictionary*		_cachedTextures = nil;


@implementation OGLTexture

+ (OGLTexture*)textureWithName:(NSString*)name
{
	if(!_cachedTextures)
		_cachedTextures = [[NSMutableDictionary alloc] init];
	
	if([name length] && ![_cachedTextures objectForKey:name])
	{
		OGLTextureData* data = [OGLTextureData dataWithImage:[UIImage imageNamed:name].CGImage];
		OGLTexture* texture = [[OGLTexture alloc] init];
		[texture uploadData:data];
		texture.available = YES;
		[_cachedTextures setValue:texture forKey:name];
	}
	return [_cachedTextures objectForKey:name];
}

- (id)init
{
	if(self = [super init])
	{
		glGenTextures(1, &_textureID);
	}
	return self;
}

- (void)dealloc
{
	if(_textureID)
		glDeleteTextures(1, &_textureID);
}

- (void)uploadData:(OGLTextureData*)data
{
	if(!data)
		return;
	
	_width = data.width;
	_height = data.height;
	GLuint format = (data.depth == 1) ? GL_LUMINANCE : GL_RGBA;
	
	glBindTexture(GL_TEXTURE_2D, _textureID);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexImage2D(GL_TEXTURE_2D, 0, format, data.width, data.height, 0, format, data.floatTexture ? GL_FLOAT : GL_UNSIGNED_BYTE, [data.data bytes]);
	glBindTexture(GL_TEXTURE_2D, 0);
}

- (void)bindTo:(int)binding unit:(int)unit
{
	if(_available)
	{
		_unit = unit;
		
		glActiveTexture(GL_TEXTURE0 + unit);
		glBindTexture(GL_TEXTURE_2D, _textureID);
		
		glUniform1i(binding, _unit);
	}
}

- (void)unbind
{
	if(_available)
	{
		glActiveTexture(GL_TEXTURE0 + _unit);
		glBindTexture(GL_TEXTURE_2D, 0);
	}
}

@end


@implementation OGLTextureData

+ (OGLTextureData*)dataWithPath:(NSString*)path
{
	OGLTextureData* data = [[OGLTextureData alloc] init];
	[data loadResourcePath:path];
	return data;
}

+ (OGLTextureData*)dataWithImage:(CGImageRef)imgRef
{
	OGLTextureData* data = [[OGLTextureData alloc] init];
	[data loadCGImage:imgRef];
	return data;
}

+ (OGLTextureData*)dataWithData:(NSData*)data size:(CGSize)size depth:(int)depth
{
	OGLTextureData* tdata = [[OGLTextureData alloc] init];
	tdata.data = data;
	tdata.width = size.width;
	tdata.height = size.height;
	tdata.depth = depth;
	return tdata;
}

+ (OGLTextureData*)dataWithUChar:(void*)ptr length:(int)length size:(CGSize)size noCopy:(BOOL)noCopy
{
	OGLTextureData* data = [[OGLTextureData alloc] init];
	data.data = noCopy ? [NSData dataWithBytesNoCopy:ptr length:length freeWhenDone:NO] : [NSData dataWithBytes:ptr length:length];
	data.width = size.width;
	data.height = size.height;
	data.depth = 1;
	return data;
}

+ (OGLTextureData*)dataWithFloat:(void*)ptr length:(int)length size:(CGSize)size noCopy:(BOOL)noCopy
{
	OGLTextureData* data = [[OGLTextureData alloc] init];
	data.data = noCopy ? [NSData dataWithBytesNoCopy:ptr length:length freeWhenDone:NO] : [NSData dataWithBytes:ptr length:length];
	data.width = size.width;
	data.height = size.height;
	data.depth = 1;
	data.floatTexture = YES;
	return data;
}

+ (OGLTextureData*)blankData:(CGSize)size
{
	OGLTextureData* data = [[OGLTextureData alloc] init];
	data.width = size.width;
	data.height = size.height;
	data.depth = 4;
	data.data = [NSMutableData dataWithLength:data.width*data.height*4];
	return data;
}

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)loadResourcePath:(NSString*)path
{
	NSData* data = [NSData dataWithContentsOfFile:path];
	UIImage* image = [UIImage imageWithData:data];
	[self loadCGImage:image.CGImage];
}

- (void)loadCGImage:(CGImageRef)imageRef
{
	if(!imageRef)
		return;
	
	uint bminfo;
	CGColorSpaceRef colorSpace;
	_width = (int)CGImageGetWidth(imageRef);
	_height = (int)CGImageGetHeight(imageRef);
	if(CGImageGetBitsPerPixel(imageRef) > 8)
	{
		_depth = 4;
		bminfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	else
	{
		_depth = 1;
		bminfo = kCGImageAlphaNone;
		colorSpace = CGColorSpaceCreateDeviceGray();
	}
	
	self.data = [NSMutableData dataWithLength:_height*_width*_depth];
	CGContextRef context = CGBitmapContextCreate((void*)[_data bytes], _width, _height, 8, _depth * _width, colorSpace, bminfo);
	if(context)
	{
		CGContextDrawImage(context, CGRectMake(0, 0, _width, _height), imageRef);
		CGContextRelease(context);
	}
	CGColorSpaceRelease(colorSpace);
}

- (void)drawImage:(UIImage*)image atOffset:(CGPoint)offset
{
	if(!image || !_data)
		return;
	
	CGImageRef imageRef = image.CGImage;
	uint bminfo;
	CGColorSpaceRef colorSpace;
	if(CGImageGetBitsPerPixel(imageRef) > 8)
	{
		bminfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	else
	{
		bminfo = kCGImageAlphaNone;
		colorSpace = CGColorSpaceCreateDeviceGray();
	}
	
	CGContextRef context = CGBitmapContextCreate((void*)[_data bytes], _width, _height, 8, _depth * _width, colorSpace, bminfo);
	if(context)
	{
		CGContextDrawImage(context, CGRectMake(offset.x, offset.y, image.size.width * image.scale, image.size.height * image.scale), imageRef);
		CGContextRelease(context);
	}
	CGColorSpaceRelease(colorSpace);
}

- (NSString*)saveRawURL:(NSString*)url withBase:(NSString*)basePath
{
	NSString* fileBase = [url lastPathComponent];
	NSString* path = [NSString stringWithFormat:@"%@%@=%d=%d=%d=%d", basePath, fileBase, _width, _height, _depth, _floatTexture ? 1 : 0];
	[_data writeToFile:path atomically:YES];
	return path;
}

- (UIImage*)extractImage
{
	if(!_data)
		return 0;
	
	uint bminfo;
	CGColorSpaceRef colorSpace;
	if(_depth > 1)
	{
		bminfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	else
	{
		bminfo = kCGImageAlphaNone;
		colorSpace = CGColorSpaceCreateDeviceGray();
	}
	
	CGDataProviderRef imgDataProvider = CGDataProviderCreateWithCFData((CFDataRef)_data);
	CGImageRef imageRef = CGImageCreate(_width, _height, 8, _depth * 8, _width * _depth, colorSpace,
											  bminfo, imgDataProvider, NULL, NO, kCGRenderingIntentDefault);
	CGDataProviderRelease(imgDataProvider);
	CGColorSpaceRelease(colorSpace);
	
	UIImage* newImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	return newImage;
}

- (void)saveToDiskPNG:(NSString*)filePath
{
	[UIImagePNGRepresentation([self extractImage]) writeToFile:filePath atomically:YES];
}

- (void)saveToDiskJPG:(NSString*)filePath
{
	[UIImageJPEGRepresentation([self extractImage], .7) writeToFile:filePath atomically:YES];
}

@end
