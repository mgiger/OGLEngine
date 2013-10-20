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


#import "OGLTexture.h"

static NSMutableDictionary*		_cachedTextures = nil;

///////////////////////////////////////////////////////////////////////////
///
/// @class GLTexture
///
/// OpenGL texture object
///
///////////////////////////////////////////////////////////////////////////
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

@interface OGLTextureData()
//@property (nonatomic, strong)	MMapFile*	map;
@end


///////////////////////////////////////////////////////////////////////////
///
/// @class OGLTextureData
///
/// Raw texture data
///
///////////////////////////////////////////////////////////////////////////
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

+ (NSString*)rawPathForURL:(NSString*)url withBase:(NSString*)basePath
{
	NSError* error = nil;
	NSString* fileBase = [url lastPathComponent];
	NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:basePath error:&error];
	NSCharacterSet* cset = [NSCharacterSet characterSetWithCharactersInString:@"="];
	for(NSString* filePath in files)
	{
		NSArray* components = [[filePath lastPathComponent] componentsSeparatedByCharactersInSet:cset];
		if([components count] && [[components objectAtIndex:0] isEqualToString:fileBase])
			return [NSString stringWithFormat:@"%@%@", basePath, filePath];
	}
	return nil;
}

//+ (OGLTextureData*)dataWithRawMMapPath:(NSString*)rawPath
//{
//	// parse filename for <name>_<width>_<height>_<depth>_<floatTexture(bool)>
//	NSArray* pathComponents = [[rawPath lastPathComponent] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"="]];
//	if([pathComponents count] == 5)
//	{
//		OGLTextureData* texData = [[OGLTextureData alloc] init];
//		texData.map = [MMapFile fileWithPath:rawPath];	// hold a reference until we're done
//		texData.data = [NSData dataWithBytesNoCopy:texData.map.data length:texData.map.size freeWhenDone:NO];
//		texData.width = [[pathComponents objectAtIndex:1] integerValue];
//		texData.height = [[pathComponents objectAtIndex:2] integerValue];
//		texData.depth = [[pathComponents objectAtIndex:3] integerValue];
//		texData.floatTexture = [[pathComponents objectAtIndex:4] integerValue];
//		return texData;
//	}
//	return nil;
//}

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
	_width = CGImageGetWidth(imageRef);
	_height = CGImageGetHeight(imageRef);
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
