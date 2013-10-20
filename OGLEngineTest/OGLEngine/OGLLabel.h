///
/// EarthBrowser
///
/// Copyright (c) 2010 EarthBrowser LLC.
///

#import "OGLSprite.h"

@interface OGLLabel : OGLSprite

@property (nonatomic, assign)	int					maxWidth;

- (void)setText:(NSString*)text;

@end
