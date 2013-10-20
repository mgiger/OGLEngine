//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

@class OGLSQLStatement;

@interface OGLDatabase : NSObject

+ (BOOL)dataPresent:(NSString*)dataID;
+ (void)saveData:(NSData*)data withID:(NSString*)dataID purgeAge:(double)days;
+ (void)removeData:(NSString*)dataID;
+ (NSData*)dataWithID:(NSString*)dataID;
+ (UIImage*)imageFromCache:(NSString*)dataID;

- (id)initWithName:(NSString*)name;
- (id)initWithPath:(NSString*)path;
- (BOOL)exec:(NSString*)sql;
- (OGLSQLStatement*)execSQL:(id)firstObject, ...;

@end

@interface OGLSQLStatement : NSObject

- (BOOL)next;
- (void)reset;

- (BOOL)boolAtIndex:(int)index;
- (NSInteger)integerAtIndex:(int)index;
- (long)longAtIndex:(int)index;
- (float)floatAtIndex:(int)index;
- (double)doubleAtIndex:(int)index;
- (NSString*)stringAtIndex:(int)index;
- (NSData*)dataAtIndex:(int)index;

@end