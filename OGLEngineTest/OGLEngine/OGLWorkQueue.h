//
//  OGLWorkQueue.h
//  EarthBrowser
//
//  Created by Matthew Giger on 8/3/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
//

@interface OGLWorkQueue : NSObject

+ (BOOL)processing;
+ (void)addBlock:(void (^)(void))block;
+ (void)addBlock:(void (^)(void))block withCompletion:(void (^)(void))completion;
+ (void)addBlock:(id (^)(void))block withParameterizedCompletion:(void (^)(id))completion;

@end
