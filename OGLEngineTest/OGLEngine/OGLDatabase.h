//
//  Database.h
//  EarthBrowser
//
//  Created by Matt Giger on 7/26/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
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

- (BOOL)boolAtIndex:(NSInteger)index;
- (NSInteger)integerAtIndex:(NSInteger)index;
- (long)longAtIndex:(NSInteger)index;
- (float)floatAtIndex:(NSInteger)index;
- (double)doubleAtIndex:(NSInteger)index;
- (NSString*)stringAtIndex:(NSInteger)index;
- (NSData*)dataAtIndex:(NSInteger)index;

@end