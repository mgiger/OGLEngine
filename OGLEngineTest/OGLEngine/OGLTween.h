//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

typedef enum {
	tweenLinear,
	tweenInQuad,
	tweenOutQuad,
	tweenInBounce,
	tweenOutBounce,
	tweenInElastic,
	tweenOutElastic
} OGLTweenMethod;

@interface OGLTween : NSObject

+ (BOOL)tweensActive;

+ (void)tweenFrom:(float)from
			   to:(float)to
		   method:(OGLTweenMethod)method
		 duration:(NSTimeInterval)duration
			delay:(NSTimeInterval)delay
	   identifier:(NSString*)identifier
	   animations:(void (^)(float value))animations
	   completion:(void (^)(BOOL finished))completion;

+ (void)tweenDelay:(NSTimeInterval)delay
		identifier:(NSString*)identifier
		completion:(void (^)(BOOL finished))completion;


+ (void)cancel:(NSString*)identifier;

@end
