//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//


#import "OGLEngine.h"

static const CGFloat		cBottomOffset		= 20;

@interface OGLAnnotationView : UIView

+ (id)view;

- (OGLTexture*)glTexture;

@end
