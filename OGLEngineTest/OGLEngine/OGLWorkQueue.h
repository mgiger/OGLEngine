//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

@interface OGLWorkQueue : NSObject

+ (BOOL)processing;
+ (void)addBlock:(void (^)(void))block;
+ (void)addBlock:(void (^)(void))block withCompletion:(void (^)(void))completion;
+ (void)addBlock:(id (^)(void))block withParameterizedCompletion:(void (^)(id))completion;

@end
