//
//  OGLTestViewController.m
//  OGLEngineTest
//
//  Created by Matt Giger on 10/20/13.
//  Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLTestViewController.h"
#import "OGLEngineView.h"
#import "OGLSprite.h"

@interface OGLTestViewController ()

@property (nonatomic, strong)	IBOutlet	OGLEngineView*	engine;

@property (nonatomic, strong)				OGLSprite*		featureButton;

@end

@implementation OGLTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
	}
	return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_engine.backColor = OGLFloat4Make(0,0,0,1);
	
	__weak OGLTestViewController* weak_self = self;
	
	_featureButton = [[OGLSprite alloc] init];
	[_featureButton setImageName:@"gearIcon" centered:YES];
	_featureButton.alpha = 0.65f;
	_featureButton.offset = OGLFloat3Make(10 * _ScreenScale, 24 * _ScreenScale, 0);
	_featureButton.autoRotation = 0.1;
	_featureButton.tapEventHandler = ^(UITapGestureRecognizer* gesture)
	{
		return weak_self.featureButton;
	};
	[_engine.userInterface addChild:_featureButton];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
