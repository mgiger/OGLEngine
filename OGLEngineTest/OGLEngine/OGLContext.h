///
/// OGLContext
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

#import <Foundation/Foundation.h>

@class OGLBuffer;
@class OGLTexture;
@class OGLTextureData;

@interface OGLContext : NSObject

@property (nonatomic, strong)	EAGLContext*	context;

+ (OGLContext*)main;
+ (OGLContext*)worker;
+ (void)updateContexts;

- (id)initWithAPI:(EAGLRenderingAPI)api;
- (id)initWithAPI:(EAGLRenderingAPI)api withSharegroup:(EAGLSharegroup*)sharegroup;

- (void)setCurrent;
- (void)uploadData:(NSData*)data intoBuffer:(OGLBuffer*)buffer;
- (void)uploadData:(OGLTextureData*)data intoTexture:(OGLTexture*)texture;

@end
