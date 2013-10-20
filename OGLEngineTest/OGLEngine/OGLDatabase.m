//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//


#import "OGLDatabase.h"
#include <sqlite3.h>

#define kBusyTimeout		1000

@interface OGLSQLStatement()
@property (nonatomic, assign)	sqlite3_stmt*	statement;
- (id)initWithStatement:(sqlite3_stmt*)inStatement;
@end


#define kDefaultCacheName	@"datastore.db"
#define kCacheCreateSQL		@"create table if not exists datacache (id text primary key, age text, data blob)"
#define kCacheTestSQL		@"select id from datacache where id=?"
#define kCacheLoadSQL		@"select data from datacache where id=?"
#define kCacheStoreSQL		@"replace into datacache (id, age, data) VALUES(?, julianday('now') - 2440587.5 + %0.5g, ?)"
#define kCacheDeleteSQL		@"delete from datacache where id=?"
#define kCachePurgeSQL		@"delete from datacache where age < julianday('now') - 2440587.5"

@interface OGLDatabase()
{
	sqlite3*	_db;
}

+ (OGLDatabase*)threadCache;

- (BOOL)testData:(NSString*)dataID;
- (BOOL)cacheData:(NSData*)data withID:(NSString*)dataID purgeAge:(double)days;
- (BOOL)removeDataWithID:(NSString*)dataID;
- (NSData*)loadData:(NSString*)dataID;

@end


@implementation OGLDatabase

+ (OGLDatabase*)threadCache
{
	OGLDatabase* db = [[[NSThread currentThread] threadDictionary] objectForKey:@"Database"];
	if (!db)
	{
		db = [[OGLDatabase alloc] init];
		[[[NSThread currentThread] threadDictionary] setObject:db forKey:@"Database"];
	}
	return db;
}

+ (BOOL)dataPresent:(NSString*)dataID
{
	return [[OGLDatabase threadCache] testData:dataID];
}

+ (void)saveData:(NSData*)data withID:(NSString*)dataID purgeAge:(double)days
{
	[[OGLDatabase threadCache] cacheData:data withID:dataID purgeAge:days];
}

+ (void)removeData:(NSString*)dataID
{
	[[OGLDatabase threadCache] removeDataWithID:dataID];
}

+ (NSData*)dataWithID:(NSString*)dataID
{
	return [[OGLDatabase threadCache] loadData:dataID];
}

+ (UIImage*)imageFromCache:(NSString*)dataID
{
	return [UIImage imageWithData:[[OGLDatabase threadCache] loadData:dataID]];
}


- (id)init
{
	if(self = [super init])
	{
		// open and initialize the cache
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
		NSString* mcpath = [[paths objectAtIndex:0] stringByAppendingPathComponent:kDefaultCacheName];
		if(sqlite3_open([mcpath UTF8String], &_db) == SQLITE_OK)
		{
			sqlite3_busy_timeout(_db, kBusyTimeout);
			sqlite3_exec(_db, [kCacheCreateSQL UTF8String], 0, 0, NULL);
			sqlite3_exec(_db, [kCachePurgeSQL UTF8String], 0, 0, NULL);
		}
	}
	return self;
}

- (id)initWithName:(NSString*)name
{
	if(self = [super init])
	{
		NSString* fileName = [[name lastPathComponent] stringByDeletingPathExtension];
		NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:[name pathExtension]];
		if(sqlite3_open([path UTF8String], &_db) == SQLITE_OK)
		{
			sqlite3_busy_timeout(_db, kBusyTimeout);
		}
	}
	return self;
}

- (id)initWithPath:(NSString*)path
{
	if(self = [super init])
	{
		if(sqlite3_open([path UTF8String], &_db) == SQLITE_OK)
		{
			sqlite3_busy_timeout(_db, kBusyTimeout);
		}
	}
	return self;
}

- (void)dealloc
{
	if(_db)
		sqlite3_close(_db);
	sqlite3_thread_cleanup();
}

- (BOOL)testData:(NSString*)dataID
{
	BOOL result = NO;
	sqlite3_stmt* stmt;
	int val;
	do {
		val = sqlite3_prepare_v2(_db, [kCacheTestSQL UTF8String], (int)[kCacheTestSQL length], &stmt, 0);
		if(val == SQLITE_OK)
		{
			sqlite3_bind_text(stmt, 1, [dataID UTF8String], (int)[dataID length], SQLITE_STATIC);
			val = sqlite3_step(stmt);
			if(val == SQLITE_ROW)
				result = YES;
			sqlite3_finalize(stmt);
		}
		
		if(val == SQLITE_BUSY)
			[NSThread sleepForTimeInterval:0.1];
	}
	while (val == SQLITE_BUSY);
	
	return result;
	
}

- (BOOL)cacheData:(NSData*)data withID:(NSString*)dataID purgeAge:(double)days
{
	BOOL result = NO;
	sqlite3_stmt* stmt;
	int val;
	do
	{
		NSString* storeSQL = [NSString stringWithFormat:kCacheStoreSQL, days];
		val = sqlite3_prepare_v2(_db, [storeSQL UTF8String], (int)[storeSQL length], &stmt, 0);
		if(val == SQLITE_OK)
		{
			sqlite3_bind_text(stmt, 1, [dataID UTF8String], (int)[dataID length], SQLITE_STATIC);
			sqlite3_bind_blob(stmt, 2, [data bytes], (int)[data length], SQLITE_STATIC);
			
			val = sqlite3_step(stmt);
			if(val == SQLITE_DONE) // success
			{
				result = YES;
			}
			sqlite3_finalize(stmt);
		}
		
		if(val == SQLITE_BUSY)
			[NSThread sleepForTimeInterval:0.1];
	}
	while (val == SQLITE_BUSY);
	
	return result;
}

- (BOOL)removeDataWithID:(NSString*)dataID
{
	BOOL result = NO;
	sqlite3_stmt* stmt;
	int val;
	do
	{
		val = sqlite3_prepare_v2(_db, [kCacheDeleteSQL UTF8String], (int)[kCacheDeleteSQL length], &stmt, 0);
		if(val == SQLITE_OK)
		{
			sqlite3_bind_text(stmt, 1, [dataID UTF8String], (int)[dataID length], SQLITE_STATIC);
			val = sqlite3_step(stmt);
			if(val == SQLITE_DONE)	// success
				result = YES;
			
			sqlite3_finalize(stmt);
		}
		
		if(val == SQLITE_BUSY)
			[NSThread sleepForTimeInterval:0.1];
	}
	while (val == SQLITE_BUSY);
	
	return result;
}

- (NSData*)loadData:(NSString*)dataID
{
	NSData* result = nil;
	sqlite3_stmt* stmt;
	int val;
	do
	{
		val = sqlite3_prepare_v2(_db, [kCacheLoadSQL UTF8String], (int)[kCacheLoadSQL length], &stmt, 0);
		if(val == SQLITE_OK)
		{
			sqlite3_bind_text(stmt, 1, [dataID UTF8String], (int)[dataID length], SQLITE_STATIC);
			val = sqlite3_step(stmt);
			if(val == SQLITE_ROW)
			{
				int bytes = sqlite3_column_bytes(stmt, 0);
				if(bytes > 0)
					result = (__bridge_transfer NSData*)CFDataCreate(kCFAllocatorDefault, (const UInt8*)sqlite3_column_blob(stmt, 0), bytes);
			}
			
			sqlite3_finalize(stmt);
		}
		
		if(val == SQLITE_BUSY)
			[NSThread sleepForTimeInterval:0.1];
	}
	while (val == SQLITE_BUSY);
	
	return result;
}

+ (void)bind:(id)obj toStatement:(sqlite3_stmt*)stmt atIndex:(int)idx
{
	if([obj isKindOfClass:[NSString class]])
	{
		sqlite3_bind_text(stmt, idx, [obj UTF8String], (int)[obj length], SQLITE_TRANSIENT);
	}
	else if ([obj isKindOfClass:[NSData class]])
	{
		sqlite3_bind_blob(stmt, idx, [obj bytes], (int)[obj length], SQLITE_TRANSIENT);
	}
	else if ([obj isKindOfClass:[NSDate class]])
	{
		sqlite3_bind_double(stmt, idx, [obj timeIntervalSince1970]);
	}
	else if (!obj || [obj isKindOfClass:[NSNull class]])
	{
		sqlite3_bind_null(stmt, idx);
	}
	else if ([obj isKindOfClass:[NSNumber class]])
	{
		if (strcmp([obj objCType], @encode(BOOL)) == 0)
			sqlite3_bind_int(stmt, idx, ([obj boolValue] ? 1 : 0));
		else if (strcmp([obj objCType], @encode(int)) == 0)
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		else if (strcmp([obj objCType], @encode(long)) == 0)
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		else if (strcmp([obj objCType], @encode(long long)) == 0)
			sqlite3_bind_int64(stmt, idx, [obj longLongValue]);
		else if (strcmp([obj objCType], @encode(float)) == 0)
			sqlite3_bind_double(stmt, idx, [obj floatValue]);
		else if (strcmp([obj objCType], @encode(double)) == 0)
			sqlite3_bind_double(stmt, idx, [obj doubleValue]);
		else
			sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_TRANSIENT);
	}
	else
	{
		sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_TRANSIENT);
	}
}

- (BOOL)exec:(NSString *)sql
{
	char* err_msg;
	const char* sqlStatement = [sql UTF8String];
	if(sqlite3_exec(_db, sqlStatement, 0, 0, &err_msg) != SQLITE_OK)
		return NO;
	return YES;
}

- (OGLSQLStatement*)execSQL:(id)firstObject, ...
{
	if([firstObject isKindOfClass:[NSString class]])
	{
		sqlite3_stmt* stmt;
		if(sqlite3_prepare_v2(_db, [firstObject UTF8String], (int)[firstObject length], &stmt, 0) == SQLITE_OK)
		{
			va_list argumentList;
			va_start(argumentList, firstObject);
			int count = sqlite3_bind_parameter_count(stmt);
			if(count > 0)
			{
				id eachObject;
				int index = 1;
				while(index <= count && (eachObject = va_arg(argumentList, id)) != nil)
					[OGLDatabase bind:eachObject toStatement:stmt atIndex:index++];
			}
			va_end(argumentList);
			
			return [[OGLSQLStatement alloc] initWithStatement:stmt];
		}
		else {
			NSLog(@"Error while creating statement. '%s'", sqlite3_errmsg(_db));
		}
	}
	return nil;
}

@end


@implementation OGLSQLStatement

- (id)initWithStatement:(sqlite3_stmt*)inStatement
{
	if(self = [super init])
	{
		_statement = inStatement;
	}
	return self;
}

- (void)dealloc
{
	sqlite3_finalize(_statement);
}

- (BOOL)next
{
	int result = sqlite3_step(_statement);
	return /*result == SQLITE_DONE ||*/ result == SQLITE_ROW;
}

- (void)reset
{
	sqlite3_reset(_statement);
}

- (BOOL)boolAtIndex:(int)index
{
    return sqlite3_column_int(_statement, index) != 0;
}

- (NSInteger)integerAtIndex:(int)index
{
    return sqlite3_column_int(_statement, index);
}

- (long)longAtIndex:(int)index
{
	return (long)sqlite3_column_int64(_statement, index);
}

- (float)floatAtIndex:(int)index
{
    return sqlite3_column_double(_statement, index);
}

- (double)doubleAtIndex:(int)index
{
    return sqlite3_column_double(_statement, index);
}

- (NSString*)stringAtIndex:(int)index
{
	const char *c = (const char *)sqlite3_column_text(_statement, index);
	return c ? [NSString stringWithUTF8String:c] : nil;
}

- (NSData*)dataAtIndex:(int)index
{
	NSData* result = nil;
	int bytes = sqlite3_column_bytes(_statement, 0);
	if(bytes > 0)
		result = (__bridge_transfer NSData*)CFDataCreate(kCFAllocatorDefault, (const UInt8*)sqlite3_column_blob(_statement, 0), bytes);
	return result;
}

@end
