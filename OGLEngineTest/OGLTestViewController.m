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

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	_engine.backColor = CGFloat4Make(1,1,1,1);
	
	__weak OGLTestViewController* weak_self = self;
	
	_featureButton = [[OGLSprite alloc] init];
	[_featureButton setImageName:@"gearIcon" centered:NO];
	_featureButton.alpha = 0.65f;
//	_featureButton.offset = CGFloat3Make(10, 10, 20);
	[_engine.userInterface addChild:_featureButton];
	_featureButton.tapEventHandler = ^(UITapGestureRecognizer* gesture)
	{
		return weak_self.featureButton;
	};
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
