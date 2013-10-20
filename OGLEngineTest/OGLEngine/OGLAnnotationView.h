//
//  AnnotationView.h
//  EarthBrowser
//
//  Created by Matt Giger on 9/9/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
//

#import "OGLEngine.h"

static const CGFloat		cBottomOffset		= 20;

@interface OGLAnnotationView : UIView

+ (id)view;

- (OGLTexture*)glTexture;

@end
