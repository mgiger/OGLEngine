//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLLabel.h"
#import "OGLTexture.h"
#import "OGLBuffer.h"
#import "OGLContext.h"
#import "OGLRenderInfo.h"

static UILabel*		_sharedLabel;

@implementation OGLLabel

- (id)init
{
	if(self = [super init])
	{
		self.hasGeometry = YES;
		_font = [UIFont boldSystemFontOfSize:16];
	}
	return self;
}

- (void)setText:(NSString*)text
{
	_text = text;
	[self performSelectorOnMainThread:@selector(renderText) withObject:nil waitUntilDone:NO];
}

- (void)renderText
{
	if([_text length])
	{
		CGRect lbounds = [_text boundingRectWithSize:CGSizeMake(_maxWidth > 0 ? _maxWidth : 10000, 10000)
											 options:NSStringDrawingUsesLineFragmentOrigin
										  attributes:@{NSFontAttributeName:_font}
											 context:nil];
		
		if(!_sharedLabel)
		{
			_sharedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lbounds.size.width, lbounds.size.height)];
			_sharedLabel.backgroundColor = [UIColor clearColor];
			_sharedLabel.opaque = NO;
			_sharedLabel.textAlignment = NSTextAlignmentCenter;
			_sharedLabel.font = _font;
			_sharedLabel.numberOfLines = 0;
			_sharedLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.75];
			_sharedLabel.shadowOffset = CGSizeMake(1.5, 1.5);
		}
		else
			_sharedLabel.frame = CGRectMake(0, 0, lbounds.size.width, lbounds.size.height);
		
		_sharedLabel.textColor = [UIColor colorWithRed:self.color.x green:self.color.y blue:self.color.z alpha:1.0];
		_sharedLabel.text = _text;
		[_sharedLabel layoutIfNeeded];
		
		OGLTexture* texture = nil;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		if(colorSpace)
		{
			CGSize size = CGSizeMake(ceilf(lbounds.size.width * _ScreenScale), ceilf(lbounds.size.height * _ScreenScale));
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
