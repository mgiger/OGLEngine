//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//


#import "OGLAnnotationView.h"
#import "OGLTexture.h"

static const CGFloat		cCornerRadius		= 8.0;
static const CGFloat		cTabLength			= 15;
static const CGFloat		cShadowXOffset		= 2;
static const CGFloat		cShadowYOffset		= 4;
static const CGFloat		cShadowBlur			= 8;
static const CGFloat		cStrokeWidth		= 1.0;


@implementation OGLAnnotationView

+ (id)view
{
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
	for (id object in objects)
	{
		NSAssert([object isKindOfClass:[self class]], @"View is of wrong type!");
		[object setNeedsLayout];
		return object;
	}
	return nil;
}

- (OGLTexture*)glTexture
{
	[self layoutIfNeeded];
	
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
//	[UIImagePNGRepresentation(img) writeToFile:@"/Users/mgiger/Desktop/test.png" atomically:YES];
	
	OGLTexture* texture = [[OGLTexture alloc] init];
	[texture uploadData:[OGLTextureData dataWithImage:img.CGImage]];
	texture.available = YES;
	return texture;
}

- (void)drawRect:(CGRect)rect
{
//    CGMutablePathRef path = CGPathCreateMutable();
//    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
//    CGContextRef context = UIGraphicsGetCurrentContext();
//	
//    //Determine Size
//    rect = self.bounds;
//    rect.size.width -= cStrokeWidth + cShadowXOffset;
//    rect.size.height -= cStrokeWidth + cBottomOffset;
//    rect.origin.x += cStrokeWidth / 2.0 + 1;
//    rect.origin.y += cStrokeWidth / 2.0;
//	
//	CGFloat	pointerXOffset = rect.size.width * 0.5 + 2;
//
//	
//    //Create Path For Callout Bubble
//    CGPathMoveToPoint(path, NULL, rect.origin.x, rect.origin.y + cCornerRadius);
//    CGPathAddLineToPoint(path, NULL, rect.origin.x, rect.origin.y + rect.size.height - cCornerRadius);
//    CGPathAddArc(path, NULL, rect.origin.x + cCornerRadius, rect.origin.y + rect.size.height - cCornerRadius, cCornerRadius, c_pi, c_half_pi, 1);
//    CGPathAddLineToPoint(path, NULL, pointerXOffset - cTabLength, rect.origin.y + rect.size.height);
//    CGPathAddLineToPoint(path, NULL, pointerXOffset, rect.origin.y + rect.size.height + cTabLength);
//    CGPathAddLineToPoint(path, NULL, pointerXOffset + cTabLength, rect.origin.y + rect.size.height);
//    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width - cCornerRadius, rect.origin.y + rect.size.height);
//    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - cCornerRadius, rect.origin.y + rect.size.height - cCornerRadius, cCornerRadius, c_half_pi, 0.0f, 1);
//    CGPathAddLineToPoint(path, NULL, rect.origin.x + rect.size.width, rect.origin.y + cCornerRadius);
//    CGPathAddArc(path, NULL, rect.origin.x + rect.size.width - cCornerRadius, rect.origin.y + cCornerRadius, cCornerRadius, 0.0f, -c_half_pi, 1);
//    CGPathAddLineToPoint(path, NULL, rect.origin.x + cCornerRadius, rect.origin.y);
//    CGPathAddArc(path, NULL, rect.origin.x + cCornerRadius, rect.origin.y + cCornerRadius, cCornerRadius, -c_half_pi, c_pi, 1);
//    CGPathCloseSubpath(path);
//	
//    //Fill Callout Bubble & Add Shadow
//    [[UIColor colorWithRed:.3 green:.3 blue:.3 alpha:.5] setFill];
//    CGContextAddPath(context, path);
//    CGContextSaveGState(context);
//    CGContextSetShadowWithColor(context, CGSizeMake (cShadowXOffset, cShadowYOffset), cShadowBlur, [UIColor colorWithWhite:0 alpha:.95].CGColor);
//    CGContextFillPath(context);
//    CGContextRestoreGState(context);
//	
//    //Stroke Callout Bubble
//    [[UIColor blackColor] setStroke];
//    CGContextSetLineWidth(context, cStrokeWidth);
//    CGContextSetLineCap(context, kCGLineCapSquare);
//    CGContextAddPath(context, path);
//    CGContextStrokePath(context);
//	
//    //Determine Size for Gloss
//    CGRect glossRect = self.bounds;
//    glossRect.size.width = rect.size.width - cStrokeWidth;
//    glossRect.size.height = (rect.size.height - cStrokeWidth) / 2;
//    glossRect.origin.x = rect.origin.x + cStrokeWidth / 2;
//    glossRect.origin.y += rect.origin.y + cStrokeWidth / 2;
//	
//    CGFloat glossTopRadius = cCornerRadius - cStrokeWidth / 2;
//    CGFloat glossBottomRadius = cCornerRadius / 1.5;
//	
//    //Create Path For Gloss
//    CGMutablePathRef glossPath = CGPathCreateMutable();
//    CGPathMoveToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossTopRadius);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x, glossRect.origin.y + glossRect.size.height - glossBottomRadius);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, c_pi, c_half_pi, 1);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossBottomRadius, glossRect.origin.y + glossRect.size.height - glossBottomRadius, glossBottomRadius, c_half_pi, 0.0f, 1);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossRect.size.width, glossRect.origin.y + glossTopRadius);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossRect.size.width - glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, 0.0f, -c_half_pi, 1);
//    CGPathAddLineToPoint(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y);
//    CGPathAddArc(glossPath, NULL, glossRect.origin.x + glossTopRadius, glossRect.origin.y + glossTopRadius, glossTopRadius, -c_half_pi, c_pi, 1);
//    CGPathCloseSubpath(glossPath);
//	
//    //Fill Gloss Path
//    CGContextAddPath(context, glossPath);
//    CGContextClip(context);
//    CGFloat colors[] =
//    {
//        1, 1, 1, .5,
//        1, 1, 1, .2,
//    };
//    CGFloat locations[] = { 0, 1.0 };
//    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, colors, locations, 2);
//    CGPoint startPoint = glossRect.origin;
//    CGPoint endPoint = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
//    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
//	
//    //Gradient Stroke Gloss Path
//    CGContextAddPath(context, glossPath);
//    CGContextSetLineWidth(context, 2);
//    CGContextReplacePathWithStrokedPath(context);
//    CGContextClip(context);
//    CGFloat colors2[] =
//    {
//        1, 1, 1, .3,
//        1, 1, 1, .1,
//        1, 1, 1, .0,
//    };
//    CGFloat locations2[] = { 0, .1, 1.0 };
//    CGGradientRef gradient2 = CGGradientCreateWithColorComponents(space, colors2, locations2, 3);
//    CGPoint startPoint2 = glossRect.origin;
//    CGPoint endPoint2 = CGPointMake(glossRect.origin.x, glossRect.origin.y + glossRect.size.height);
//    CGContextDrawLinearGradient(context, gradient2, startPoint2, endPoint2, 0);
//	
//    //Cleanup
//    CGPathRelease(path);
//    CGPathRelease(glossPath);
//    CGColorSpaceRelease(space);
//    CGGradientRelease(gradient);
//    CGGradientRelease(gradient2);
}

@end
