///
/// EarthBrowser
///
/// Copyright (c) 2010 EarthBrowser LLC.
///

#import "OGLLabel.h"
#import "OGLTexture.h"
#import "OGLBuffer.h"
#import "OGLContext.h"
#import "OGLRenderInfo.h"

#import <OpenGLES/ES2/gl.h>

static UILabel*		_sharedLabel;

@implementation OGLLabel

- (id)init
{
	if(self = [super init])
	{
		self.hasGeometry = YES;
	}
	return self;
}

- (void)setText:(NSString*)text
{
	[self performSelectorOnMainThread:@selector(renderText:) withObject:text waitUntilDone:NO];
}

- (void)renderText:(NSString*)text
{
	if([text length])
	{
		CGSize lsize = [text sizeWithFont:[UIFont boldSystemFontOfSize:16]
						constrainedToSize:CGSizeMake(_maxWidth > 0 ? _maxWidth : 10000, 10000)];
		
		if(!_sharedLabel)
		{
			_sharedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lsize.width, lsize.height)];
			_sharedLabel.backgroundColor = [UIColor clearColor];
			_sharedLabel.opaque = NO;
			_sharedLabel.textAlignment = NSTextAlignmentCenter;
			_sharedLabel.font = [UIFont boldSystemFontOfSize:16];
			_sharedLabel.numberOfLines = 0;
			_sharedLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.75];
			_sharedLabel.shadowOffset = CGSizeMake(1.5, 1.5);
		}
		else
			_sharedLabel.frame = CGRectMake(0, 0, lsize.width, lsize.height);
		
		_sharedLabel.textColor = [UIColor colorWithRed:_color.x green:_color.y blue:_color.z alpha:1.0];
		_sharedLabel.text = text;
		[_sharedLabel layoutIfNeeded];
		
		OGLTexture* texture = nil;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		if(colorSpace)
		{
			CGSize size = CGSizeMake(ceilf(lsize.width * _ScreenScale), ceilf(lsize.height * _ScreenScale));
			NSData* data = [NSMutableData dataWithLength:size.height * size.width * 4];
			CGContextRef context = CGBitmapContextCreate((char*)[data bytes], size.width, size.height, 8, 4 * size.width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			if(context)
			{
				CGContextTranslateCTM(context, 0, size.height);
				CGContextScaleCTM(context, _ScreenScale, -_ScreenScale);
				
				texture = [[OGLTexture alloc] init];
				texture.width = size.width;
				texture.height = size.height;
				
				[_sharedLabel.layer renderInContext:context];
				
				if([[NSThread currentThread] isMainThread])
				{
					[texture uploadData:[OGLTextureData dataWithData:data size:size depth:4]];
					texture.available = YES;
				}
				else
				{
					[[OGLContext worker] uploadData:[OGLTextureData dataWithData:data size:size depth:4] intoTexture:texture];
				}
				
				CGContextRelease(context);
			}
			CGColorSpaceRelease(colorSpace);
		}
		
		if(texture)
		{
			[self setGLTexture:texture centered:NO];
		}
		
		self.visible = YES;
	}
	else
	{
		self.visible = NO;
	}
}

@end
