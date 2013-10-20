//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//


#import "OGLAnnotation.h"
#import "OGLAnnotationView.h"
#import "OGLTween.h"

static OGLAnnotation*	_current = nil;

@implementation OGLAnnotation

+ (void)closeCurrentAnnotaion
{
	if(_current)
	{
		if(_current.close)
			_current.close();
		_current = nil;
	}
}

@synthesize action = _action;
@synthesize close = _close;
@synthesize scaleFactor = _scaleFactor;

- (id)initWithAnnotationView:(OGLAnnotationView*)view action:(OGLSimpleBlock)action close:(OGLSimpleBlock)close
{
	if(self = [super init])
	{
		_scaleFactor = 1.0;
		_current = self;
		self.action = action;
		self.close = close;
		
		__weak OGLAnnotation* weak_self = self;
		[self setGLTexture:[view glTexture] centered:NO];
		if(_action)
		{
			self.tapEventHandler = ^(UITapGestureRecognizer* gesture)
			{
				weak_self.action();
				return weak_self;
			};
		}
		
		self.offset = CGFloat3Make(-view.bounds.size.width*0.5, -view.bounds.size.height, 20);
		[self updateTransform];
		
		[OGLTween tweenFrom:0 to:1 method:tweenOutElastic duration:.7 delay:0 identifier:nil
			animations:^(float value) {
				float v = value * _scaleFactor;
				self.transform = mult(scale4x4(v, v, v), translationVec4x4(CGFloat3Mult(self.offset, v)));
			}
			completion:^(BOOL finished) {
				self.scale = CGFloat3Make(_scaleFactor, _scaleFactor, _scaleFactor);
				self.offset = CGFloat3Mult(self.offset, _scaleFactor);
			}
		 ];
	}
	return self;
}

- (void)setViewTexture:(OGLAnnotationView*)view
{
	[self setGLTexture:[view glTexture] centered:NO];
}

@end
