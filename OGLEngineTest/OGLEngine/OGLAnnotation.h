//
//  OGLAnnotation.h
//  EarthBrowser
//
//  Created by Matt Giger on 6/28/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
//

#import "OGLSprite.h"

@interface OGLAnnotation : OGLSprite

@property (nonatomic, copy)		OGLSimpleBlock		action;
@property (nonatomic, copy)		OGLSimpleBlock		close;
@property (nonatomic, assign)	CGFloat				scaleFactor;

+ (void)closeCurrentAnnotaion;

- (id)initWithAnnotationView:(OGLAnnotationView*)view action:(OGLSimpleBlock)action close:(OGLSimpleBlock)close;
- (void)setViewTexture:(OGLAnnotationView*)view;

@end
