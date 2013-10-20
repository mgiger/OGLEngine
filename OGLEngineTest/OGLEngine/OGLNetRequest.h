//
//  OGLNetRequest.h
//  EarthBrowser
//
//  Created by Matt Giger on 6/23/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
//

@interface OGLNetRequest : NSOperation

@property (nonatomic, copy)		NSString*				url;
@property (nonatomic, retain)	NSMutableDictionary*	headers;
@property (nonatomic, copy)		NSString*				method;
@property (nonatomic, retain)	NSData*					body;
@property (nonatomic, assign)	NSInteger				statusCode;
@property (nonatomic, assign)	double					timeout;
@property (nonatomic, retain)	NSMutableData*			responseBody;
@property (nonatomic, retain)	id						userData;
@property (nonatomic, retain)	NSError*				error;
@property (nonatomic, copy)		void					(^parseHandler)(OGLNetRequest* request);
@property (nonatomic, copy)		void					(^completionHandler)(OGLNetRequest* request);
@property (nonatomic, retain)	NSURLConnection*		connection;
@property (nonatomic, assign)	BOOL					isExecuting;
@property (nonatomic, assign)	BOOL					isFinished;

+ (OGLNetRequest*)request:(NSString*)url;
- (void)start;
- (void)cancel;

@end


@interface OGLNetQueue : NSObject

+ (void)add:(id)request;
+ (void)cancelURL:(NSString*)url;
+ (BOOL)urlQueued:(NSString*)url;
+ (void)cancelAllOperations;
+ (void)increment;
+ (void)decrement;
+ (BOOL)processing;

@end
