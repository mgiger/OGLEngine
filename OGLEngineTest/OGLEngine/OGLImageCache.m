//
//  ImageCache.m
//  EarthBrowser
//
//  Created by Matt Giger on 8/12/12.
//  Copyright (c) 2012 EarthBrowser LLC. All rights reserved.
//

#import "OGLImageCache.h"
#import "OGLWorkQueue.h"
#import "OGLNetRequest.h"
#import "MMapCache.h"
#import "OGLTexture.h"
#import "OGLDatabase.h"

@implementation OGLImageCache

+ (void)loadImage:(NSString*)url tempPath:(NSString*)basePath withCompletion:(void (^)(OGLTextureData* data))completion
{
	if([url length])
	{
		NSString* rawPath = [OGLTextureData rawPathForURL:url withBase:basePath];
		if([rawPath length])
		{
			[OGLWorkQueue addBlock:^id{
				[MMapCache access:rawPath];
				return [OGLTextureData dataWithRawPath:rawPath];
			} withParameterizedCompletion:^(id data) {
				completion(data);
			}];
		}
		else
		{
			NetRequest* request = [NetRequest request:url];
			[request.headers setObject:@"image/*" forKey:@"Accept"];
			request.parseHandler = ^(NetRequest* req)
			{
				if(req.statusCode == 200 && !req.error)
				{
					UIImage* image = [UIImage imageWithData:req.responseBody];
					if(image)
					{
						OGLTextureData* texData = [[OGLTextureData alloc] init];
						[texData loadCGImage:image.CGImage];
						req.userData = texData;
						
						// save raw data to mem mapped file
						[OGLWorkQueue addBlock:^{
							NSString* path = [texData saveRawURL:url withBase:basePath];
							[MMapCache access:path];
						}];
					}
				}
			};
			request.completionHandler = ^(NetRequest* req)
			{
				if(completion)
					completion(req.userData);
				
//				if(req.error)
//				{
//					[[LocalyticsSession sharedLocalyticsSession] tagEvent:@"API Error"
//															   attributes:[NSDictionary dictionaryWithObjectsAndKeys:
//																		   req.url, @"url",
//																		   [req.error description], @"error",
//																		   nil]];
//				}
			};
			[NetQueue add:request];
		}
	}
}

+ (void)loadDBImage:(NSString*)url withCompletion:(void (^)(OGLTextureData* data))completion
{
	if([url length])
	{
		NSData* data = [Database dataWithID:url];
		if([data length])
		{
			[OGLWorkQueue addBlock:^OGLTextureData*
			{
				OGLTextureData* texData = nil;
				UIImage* image = [UIImage imageWithData:data];
				if(image)
				{
					texData = [[OGLTextureData alloc] init];
					[texData loadCGImage:image.CGImage];
				}
				return texData;
			}
			withParameterizedCompletion:^(OGLTextureData* texData)
			{
				completion(texData);
			}];
		}
		else
		{
			NetRequest* request = [NetRequest request:url];
			[request.headers setObject:@"image/*" forKey:@"Accept"];
			request.parseHandler = ^(NetRequest* req)
			{
				if(req.statusCode == 200 && !req.error)
				{
					UIImage* image = [UIImage imageWithData:req.responseBody];
					if(image)
					{
						OGLTextureData* texData = [[OGLTextureData alloc] init];
						[texData loadCGImage:image.CGImage];
						req.userData = texData;
						
						// save raw data
						[OGLWorkQueue addBlock:^{
							[Database saveData:req.responseBody withID:url purgeAge:7];
						}];
					}
				}
			};
			request.completionHandler = ^(NetRequest* req)
			{
				if(completion)
					completion(req.userData);
			};
			[NetQueue add:request];
		}
	}
}
@end
