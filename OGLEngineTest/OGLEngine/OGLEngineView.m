///
/// OGLEngineView
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


#import "OGLEngineView.h"
#import "OGLCamera.h"
#import "OGLSpriteLayer.h"
#import "OGLSprite.h"
#import "OGLCamera.h"
#import "OGLRenderInfo.h"
#import "OGLSceneObject.h"
#import "OGLContext.h"

#import <OpenGLES/ES2/gl.h>

const float				cScenePerspective			= 50.0f;
const float				cContentScaleFactor			= 2.0f;

static CGFloat			_screenScale;
static CGSize			_touchPixelRadius;


@interface OGLEngineView() <GLKViewDelegate>
{	
	int		_orientation;
    BOOL	_wasRendering;
	BOOL	_firstRender;
}

@property (nonatomic, assign)	BOOL				rendering;
@property (nonatomic, strong)	OGLContext*			mainContext;
@property (nonatomic, strong)	CADisplayLink*		displayLink;
@property (nonatomic, strong)	NSArray*			selectedObjects;
@property (nonatomic, strong)	OGLSceneObject*		gestureTarget;

@end



@implementation OGLEngineView

+ (void)initialize
{
	_screenScale = [UIScreen mainScreen].scale;
	_touchPixelRadius = CGSizeMake(5 * _screenScale, 5 * _screenScale);
}

- (void)commonInit
{
	_firstRender = YES;

	_mainContext = [[OGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	self.context = _mainContext.context;
	if (!self.context)
	{
		NSLog(@"Failed to create OpenGLES context");
		return;
	}
	
	self.delegate = self;
	
	// build the worker contexts
	(void)[[OGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 withSharegroup:_mainContext.context.sharegroup];
	(void)[[OGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 withSharegroup:_mainContext.context.sharegroup];
	
	self.backgroundColor = [UIColor blackColor];
	
	self.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
	self.drawableDepthFormat = GLKViewDrawableDepthFormat16;
	self.drawableStencilFormat = GLKViewDrawableStencilFormatNone;
	self.drawableMultisample = GLKViewDrawableMultisampleNone;
	
	[[OGLContext main] setCurrent];
	
	
	[self startRendering];
	
	_orientation = UIDeviceOrientationPortrait;
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	
	_camera = [[OGLCamera alloc] init];
	_camera.fov = cScenePerspective;
	
	_camera.near = 2;
	_camera.far = 1000;
	
	_userInterface = [[OGLSpriteLayer alloc] init];
	
	glEnable(GL_CULL_FACE);
	glFrontFace(GL_CCW);
	glCullFace(GL_BACK);
	
	glDepthRangef(1, 0);
	glDepthFunc(GL_GEQUAL);
	glClearDepthf(0);
	
	
	glEnable(GL_DEPTH_TEST);
//	glDepthFunc(GL_LEQUAL);
	glDepthMask(GL_TRUE);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);		// best for transparency
	
}

- (id)init
{
	if(self = [super init])
	{
		[self commonInit];
	}
	return self;
}

- (id)initWithFrame:(CGRect)bounds
{
	if(self = [super initWithFrame:bounds])
	{
		[self commonInit];
	}
	return self;
}
- (id)initWithCoder:(NSCoder*)aDecoder
{
	if(self = [super initWithCoder:aDecoder])
	{
		[self commonInit];
	}
	return self;
}

- (void)initView
{
	NSUserDefaults* def = [NSUserDefaults standardUserDefaults];
	if(![def boolForKey:@"settingsSet"])
	{
		[def setBool:YES forKey:@"settingsSet"];
		
		[def setBool:YES forKey:@"stars"];
		[def setBool:YES forKey:@"shadows"];
		[def setBool:YES forKey:@"clouds"];
		[def setBool:YES forKey:@"weather"];
		[def setBool:YES forKey:@"storms"];
		[def setBool:YES forKey:@"quakes"];
		
		[def setBool:NO forKey:@"animating"];
		[def setFloat:3*24/24.0f forKey:@"clockStartOffset"];
		[def setFloat:1.5*24/24.0f forKey:@"clockEndOffset"];
		[def setFloat:5*60*60.0f forKey:@"animationSpeed"];
		[def synchronize];
	}
	
	
	UITapGestureRecognizer* touchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    touchGesture.numberOfTouchesRequired = 1;
	touchGesture.cancelsTouchesInView = NO;
    [self addGestureRecognizer:touchGesture];
	
	UITapGestureRecognizer* singleFingerDTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    singleFingerDTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:singleFingerDTap];
	
	UITapGestureRecognizer* doubleTouchGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTouch:)];
    doubleTouchGesture.numberOfTouchesRequired = 2;
    [self addGestureRecognizer:doubleTouchGesture];
	
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
	
    UIPinchGestureRecognizer* pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didEnterBackground:(id)sender
{
    _wasRendering = _rendering;
    [self stopRendering];
}

- (void)willEnterForeground:(id)sender
{
    if(_wasRendering)
        [self startRendering];
}

- (void)setupScene
{
	
}

- (void)startRendering
{
    if (!_rendering)
	{
		self.enableSetNeedsDisplay = NO;
		self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [self.displayLink setFrameInterval:0.0];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		
        _rendering = YES;
    }
}

- (void)stopRendering
{
    if (_rendering)
	{
        [self.displayLink invalidate];
        self.displayLink = nil;
        _rendering = NO;
    }
}

- (void)orientationChanged:(NSNotification*)note
{
	_orientation = [UIDevice currentDevice].orientation;
}

///////////////////////////////////////////////////////////
///
/// Render Context methods
///
///////////////////////////////////////////////////////////
#pragma mark Render Context methods

- (void)render:(CADisplayLink*)displayLink
{
    [self display];
}

- (void)glkView:(GLKView*)view drawInRect:(CGRect)rect
{
	if(_firstRender)
	{
		_firstRender = NO;
		[self setupScene];
	}
	
	// update frame stats
	[_camera updateOrientation:_orientation withWidth:self.drawableWidth withHeight:self.drawableHeight];
	[_userInterface setScreenSize:CGSizeMake(self.drawableWidth, self.drawableHeight)];
	
	[OGLContext updateContexts];
	
	
	OGLRenderInfo* info = [[OGLRenderInfo alloc] initWithCamera:_camera withSpriteLayer:_userInterface];
	[_camera render:info];
	
	// check to make sure we need to render
	static double lastTime = 0;
	static BOOL isBusy = NO;	// set to YES if updating values
	if(!isBusy && ![EBTween tweensActive] && !_camera.active)
	{
		double ftime = [EBClock sharedClock].frameTime;
		if(fabs(lastTime - ftime) < 0.5)
			return;
		lastTime = ftime;
	}
	
	glViewport(0, 0, self.drawableWidth, self.drawableHeight);
	glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// render the main scene
	[_rootObject render:info];
	
	// render the orthographic sprite layer first
	glClear(GL_DEPTH_BUFFER_BIT);
	[info resetTransforms];
	[_userInterface render:info];
}


///////////////////////////////////////////////////////////
///
/// Base UIView methods
///
///////////////////////////////////////////////////////////
#pragma mark Base UIView methods

- (IBAction)handleTap:(UITapGestureRecognizer*)sender
{
	switch (sender.state)
	{
		case UIGestureRecognizerStateBegan:
		case UIGestureRecognizerStateChanged:
			break;
			
		case UIGestureRecognizerStateEnded:
		{
			CGPoint tapPoint = [sender locationInView:sender.view];
			CGPoint pt = CGPointMake(tapPoint.x * _screenScale, tapPoint.y * _screenScale);
			CGRect rect = CGRectMake(pt.x -_touchPixelRadius.width, pt.y - _touchPixelRadius.height, _touchPixelRadius.width * 2, _touchPixelRadius.height * 2);
			self.selectedObjects = [[NSArray arrayWithArray:[_userInterface findSelected:rect]] arrayByAddingObjectsFromArray:[_userInterface findSelected:rect]];
			if([_selectedObjects count])
			{
				for(OGLSceneObjectSelWrapper* wrapper in _selectedObjects)
				{
					if([wrapper.object handleTap:sender])
						break;
				}
			}
			else
			{
				[_camera handleTap];
//				[EBAnnotation closeCurrentAnnotaion];
			}
			break;
		}
			
		default:
			break;
	}
}

- (IBAction)handleDoubleTouch:(UITapGestureRecognizer*)sender
{
	CGPoint tapPoint = [sender locationInView:sender.view];
	CGPoint pt = CGPointMake(tapPoint.x * _screenScale, tapPoint.y * _screenScale);
	[_camera doubleTouchEvent:pt];
	
	switch (sender.state)
	{
		case UIGestureRecognizerStateBegan:
		case UIGestureRecognizerStateChanged:
			break;
			
		case UIGestureRecognizerStateEnded:
		{
			break;
		}
			
		default:
			break;
	}
}

- (IBAction)handleDoubleTap:(UITapGestureRecognizer*)sender
{
    CGPoint tapPoint = [sender locationInView:sender.view];
	[_camera doubleTapEvent:CGPointMake(tapPoint.x * _screenScale, tapPoint.y * _screenScale)];
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer*)sender
{	
	switch (sender.state)
	{
		case UIGestureRecognizerStateBegan:
		{
			CGPoint p0 = [sender locationOfTouch:0 inView:self];
			CGPoint p1 = [sender locationOfTouch:1 inView:self];
			[_camera beginPinchWithTouch:CGPointMake(p0.x * _screenScale, p0.y * _screenScale) andTouch:CGPointMake(p1.x * _screenScale, p1.y * _screenScale)];
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		case UIGestureRecognizerStateEnded:
		{
			[_camera pinchEvent:sender.scale];
			break;
		}
			
		default:
			break;
	}
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer*)sender
{
	BOOL handled = NO;
	CGPoint tapPoint = [sender locationInView:sender.view];
	CGPoint pt = CGPointMake(tapPoint.x * _screenScale, tapPoint.y * _screenScale);
	
	switch (sender.state)
	{
		case UIGestureRecognizerStateBegan:
		{
			CGRect rect = CGRectMake(pt.x -_touchPixelRadius.width, pt.y - _touchPixelRadius.height, _touchPixelRadius.width * 2, _touchPixelRadius.height * 2);
			_selectedObjects = [[NSArray arrayWithArray:[_userInterface findSelected:rect]] arrayByAddingObjectsFromArray:[_userInterface findSelected:rect]];
			for(OGLSceneObjectSelWrapper* wrapper in _selectedObjects)
			{
				OGLSceneObject* interceptor = [wrapper.object handlePan:sender];
				if(interceptor)
				{
					handled = YES;
					self.gestureTarget = interceptor;
					break;
				}
			}
			
			if(!handled)
			{
//				_camera.targetFeature = nil;
				[_camera beginPan:pt];
			}
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			if(_gestureTarget)
			{
				[_gestureTarget handlePan:sender];
			}
			else
			{
//				_camera.targetFeature = nil;
				[_camera panEvent:pt];
			}
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
			if(_gestureTarget)
			{
				[_gestureTarget handlePan:sender];
			}
			else
			{
//				_camera.targetFeature = nil;
				[_camera endPan];
			}
			
			self.gestureTarget = nil;

			break;
		}
			
		default:
			break;
	}
}


- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{
//	float3 accel(acceleration.x, acceleration.y, acceleration.z);
//	EBEvent* evt = [EBEvent eventWithType:e_acceleration];
//	[evt setAcceleration:accel];
//	[_camera handleEvent:evt];
}

@end
