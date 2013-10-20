//
//  ImageCache.h
//  EarthBrowser
//
//  Created by Matt Giger on 8/12/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
//

#import "OGLEngine.h"

@interface OGLImageCache : NSObject

+ (void)loadImage:(NSString*)url tempPath:(NSString*)basePath withCompletion:(void (^)(OGLTextureData* data))completion;
+ (void)loadDBImage:(NSString*)url withCompletion:(void (^)(OGLTextureData* data))completion;

@end
