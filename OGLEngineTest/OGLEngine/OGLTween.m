///
/// OGLTween
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

#import "OGLTween.h"

static const double cAnimationGranularity		= 60.0;
static const float	c_pi						= 3.141592653589793238462643383279502884197f;

float easeLinear(float t, float b, float c, float d);
float easeInQuad(float t, float b, float c, float d);
float easeOutQuad(float t, float b, float c, float d);
float easeOutBounce(float t, float b, float c, float d);
float easeInBounce(float t, float b, float c, float d);
float easeInElastic(float t, float b, float c, float d);
float easeOutElastic(float t, float b, float c, float d);

static NSMutableDictionary*		_currentTweens;


@interface OGLTween()

@property (nonatomic, assign)	NSTimer*		timer;
@property (nonatomic, retain)	NSDate*			startDate;
@property (nonatomic, assign)	NSTimeInterval	delay;
@property (nonatomic, assign)	NSTimeInterval	duration;
@property (nonatomic, assign)	OGLTweenMethod	method;
@property (nonatomic, assign)	float			from;
@property (nonatomic, assign)	float			to;
@property (nonatomic, assign)	BOOL			canceled;
@property (nonatomic, copy)		NSString*		identifier;
@property (nonatomic, copy)		void			(^animations)(float value);
@property (nonatomic, copy)		void			(^completion)(BOOL finished);
@property (nonatomic, assign)	float			(*tweenMethod)(float,float,float,float);

- (id)initWithDuration:(NSTimeInterval)duration
				 delay:(NSTimeInterval)delay
			   method:(OGLTweenMethod)method
			identifier:(NSString*)identifier
			animations:(void (^)(float percentage))animations
			completion:(void (^)(BOOL finished))completion;

- (void)start;
- (void)cancel;
- (void)update:(NSTimer*)timer;

@end

@implementation OGLTween

+ (NSString*)guid
{
	CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
	NSString* uuidStr = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
	CFRelease(uuid);
	return uuidStr;
}

+ (void)initialize
{
	// don't retain OGLTween objects
	CFMutableDictionaryRef ref = CFDictionaryCreateMutable(nil, 0, &kCFCopyStringDictionaryKeyCallBacks, NULL);
	_currentTweens = (__bridge_transfer NSMutableDictionary*)ref;
}

+ (BOOL)tweensActive
{
	return [_currentTweens count];
}

+ (void)tweenFrom:(float)from
			   to:(float)to
		   method:(OGLTweenMethod)method
		 duration:(NSTimeInterval)duration
			delay:(NSTimeInterval)delay
	   identifier:(NSString*)identifier
	   animations:(void (^)(float value))animations
	   completion:(void (^)(BOOL finished))completion
{
	OGLTween* tween = nil;
	if([identifier length])
	{
		tween = [_currentTweens objectForKey:identifier];
		if(tween)
			[tween cancel];
	}
	else
	{
		identifier = [OGLTween guid];
	}
	
	// we do a [self release] inside of init (I know... bad)
	tween = [[OGLTween alloc] initWithDuration:duration delay:delay
										method:method identifier:identifier
									animations:animations completion:completion];
	tween.from = from;
	tween.to = to;
	[tween start];
	[_currentTweens setObject:tween forKey:identifier];
}

+ (void)tweenDelay:(NSTimeInterval)delay
		identifier:(NSString*)identifier
		completion:(void (^)(BOOL finished))completion
{
	OGLTween* tween = nil;
	if([identifier length])
	{
		tween = [_currentTweens objectForKey:identifier];
		if(tween)
			[tween cancel];
	}
	else
	{
		identifier = [OGLTween guid];
	}
	
	// we do a [self release] inside of init (I know... bad)
	tween = [[OGLTween alloc] initWithDuration:0.1 delay:delay
										method:tweenLinear identifier:identifier
									animations:nil completion:completion];
	tween.from = 0;
	tween.to = 1;
	[tween start];
	[_currentTweens setObject:tween forKey:identifier];
}

+ (void)cancel:(NSString*)identifier
{
	OGLTween* tween = [_currentTweens objectForKey:identifier];
	if(tween)
		[tween cancel];
}

- (id)initWithDuration:(NSTimeInterval)duration
				 delay:(NSTimeInterval)delay
			   method:(OGLTweenMethod)method
			identifier:(NSString*)identifier
			animations:(void (^)(float percentage))animations
			completion:(void (^)(BOOL finished))completion
{
	if(self = [super init])
	{
		_delay = delay;
		_duration = duration;
		_method = method;
		self.identifier = identifier;
		self.animations = animations;
		self.completion = completion;
		
		switch (_method)
		{
			case tweenLinear:		_tweenMethod = easeLinear;		break;
			case tweenInQuad:		_tweenMethod = easeInQuad;		break;
			case tweenOutQuad:		_tweenMethod = easeOutQuad;		break;
			case tweenInBounce:		_tweenMethod = easeInBounce;	break;
			case tweenOutBounce:	_tweenMethod = easeOutBounce;	break;
			case tweenInElastic:	_tweenMethod = easeInElastic;	break;
			case tweenOutElastic:	_tweenMethod = easeOutElastic;	break;
		}
		
		// NSTimer retains the target (us), have it release us when the animation is done
		NSDate* fireDate = [NSDate dateWithTimeIntervalSinceNow:delay];

		NSTimer* t = [[NSTimer alloc] initWithFireDate:fireDate interval:duration / cAnimationGranularity
												target:self selector:@selector(update:)
											  userInfo:nil repeats:YES];
		_timer = t;
	}
	return self;
}

- (void)dealloc
{
	if([_identifier length])
		[_currentTweens removeObjectForKey:_identifier];
}

- (void)start
{
	if(_timer)
	{
		self.startDate = [NSDate date];
		[[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
	}
}

- (void)cancel
{
	_canceled = YES;
	if(_identifier)
		[_currentTweens removeObjectForKey:_identifier];
	if([_timer isValid])
		[_timer invalidate];
	_timer = nil;
}

- (void)update:(NSTimer*)timer
{
	if(_canceled)
		return;
	
	NSTimeInterval elapsed = -[_startDate timeIntervalSinceNow];
	if(elapsed < _duration + _delay)
	{
		if(_animations)
		{
			float value = _tweenMethod(elapsed - _delay, _from, _to - _from, _duration);
			_animations(value);
		}
	}
	else
	{
		if(_completion)
			_completion(YES);
		
		if([_timer isValid])
			[_timer invalidate];
		_timer = nil;
	}
}


@end


float easeLinear(float t, float b, float c, float d)
{
	return c*t/d + b;
}

float easeInQuad(float t, float b, float c, float d)
{
	t = t / d;
	return c*t*t + b;
}

float easeOutQuad(float t, float b, float c, float d)
{
	t = t / d;
	return -c *t*(t-2) + b;
}

float easeOutBounce(float t, float b, float c, float d)
{
	t = t / d;
	if (t < 1/2.75)
		return c*(7.5625*t*t) + b;
	else if (t < 2/2.75) {
		t = t - 1.5/2.75;
		return c*(7.5625*t*t + .75) + b;
	}
	else if (t < 2.5/2.75)  {
		t = t - 2.25/2.75;
		return c*(7.5625*t*t + .9375) + b;
	}
	else {
		t = t - 2.625/2.75;
		return c*(7.5625*t*t + .984375) + b;
	}
}

float easeInBounce(float t, float b, float c, float d)
{
	return c - easeOutBounce(d-t, 0, c, d) + b;
}

float easeInElastic(float t, float b, float c, float d)
{
	float s=1.70158;
	float p=0;
	float a=c;
	if (t==0) return b;
	t = t / d;
	if(t==1) return b+c;
	if(p==0) p=d*.3;
	if (a < fabs(c))
	{
		a=c;
		s=p/4;	
	}
	else
		s = p/(2*c_pi) * asin(c/a);
	t = t - 1;
	return -(a*powf(2,10*t) * sin( (t*d-s)*(2*c_pi)/p )) + b;
}

float easeOutElastic(float t, float b, float c, float d)
{
	float s=1.70158;
	float p=0;
	float a=c;
	if(t==0) return b;
	t = t / d;
	if(t==1) return b+c;
	if(p == 0) p=d*.3;
	if (a < fabs(c))
	{
		a=c;
		s=p/4;	
	}
	else
		s = p/(2*c_pi) * asin(c/a);
	return a*pow(2,-10*t) * sin( (t*d-s)*(2*c_pi)/p ) + c + b;
}
