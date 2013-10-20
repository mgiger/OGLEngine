//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLSceneObject.h"

@interface OGLSprite : OGLSceneObject

@property (nonatomic, strong)	OGLTexture*	texture;
@property (nonatomic, assign)	CGSize		size;
@property (nonatomic, assign)	CGFloat3	position;
@property (nonatomic, assign)	CGFloat3	scale;
@property (nonatomic, assign)	CGFloat3	offset;
@property (nonatomic, assign)	CGFloat4	color;
@property (nonatomic, assign)	CGFloat		rotation;
@property (nonatomic, assign)	CGFloat		autoRotation;
@property (nonatomic, assign)	CGFloat		alpha;

- (void)updateTransform;
- (void)updateBounds;
- (CGFloat4x4)rotationlessTransform;

- (void)setImageName:(NSString*)imageName centered:(BOOL)centered;
- (void)setImageURL:(NSString*)imageURL centered:(BOOL)centered;
- (void)setGLTexture:(OGLTexture *)texture centered:(BOOL)centered;

@end

@interface OGLSpriteLayer : OGLSceneObject

@property (nonatomic, strong)		NSMutableArray*		selectedSet;

- (NSMutableArray*)findSelected:(CGRect)bounds;
- (void)setScreenSize:(CGSize)ssize;
- (void)render:(OGLRenderInfo*)info;

@end


@interface OGLLabel : OGLSprite

@property (nonatomic, assign)	int				maxWidth;
@property (nonatomic, strong)	NSString*		text;
@property (nonatomic, strong)	UIFont*			font;

@end


@interface OGLAnnotation : OGLSprite

@property (nonatomic, copy)		OGLSimpleBlock		action;
@property (nonatomic, copy)		OGLSimpleBlock		close;
@property (nonatomic, assign)	CGFloat				scaleFactor;

+ (void)closeCurrentAnnotaion;

- (id)initWithAnnotationView:(OGLAnnotationView*)view action:(OGLSimpleBlock)action close:(OGLSimpleBlock)close;
- (void)setViewTexture:(OGLAnnotationView*)view;

@end


@interface OGLAnnotationView : UIView

+ (id)view;

- (OGLTexture*)glTexture;

@end
