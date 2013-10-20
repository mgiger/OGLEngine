//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLSprite.h"

@interface OGLLabel : OGLSprite

@property (nonatomic, assign)	int				maxWidth;
@property (nonatomic, strong)	NSString*		text;
@property (nonatomic, strong)	UIFont*			font;

@end
