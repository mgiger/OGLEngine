///
/// OGLSprite
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
