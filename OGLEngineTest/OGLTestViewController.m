//
//  OGLTestViewController.m
//  OGLEngineTest
//
//  Created by Matt Giger on 10/20/13.
//  Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLTestViewController.h"
#import "OGLEngineView.h"

@interface OGLTestViewController ()

@property (nonatomic, strong)	IBOutlet	OGLEngineView*	engine;

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
	
	_engine.backColor = CGFloat4Make(1, 0, 0, 1);
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

@end
