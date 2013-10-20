//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLSceneObject.h"
#import "OGLRenderInfo.h"

@implementation OGLSceneObject

- (id)init
{
	if(self = [super init])
	{
		_visible = YES;
		_hasGeometry = NO;
		
		_children = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)addChildren:(NSArray*)children
{
	[_children addObjectsFromArray:children];
}

- (void)addChild:(OGLSceneObject*)child
{
	[_children addObject:child];
}

- (void)removeChild:(OGLSceneObject*)child
{
	[_children removeObject:child];
}

- (void)removeAllChildren
{
	[_children removeAllObjects];
}

- (void)render:(OGLRenderInfo*)info
{
	if(_visible)
	{
		[info pushTransform:_transform];
		
		for(OGLSceneObject* obj in _children)
			[obj render:info];
		
		[info popTransform];
	}
}

- (OGLSceneObject*)handleTap:(UITapGestureRecognizer*)gesture
{
	return _tapEventHandler ? _tapEventHandler(gesture) : nil;
}

- (OGLSceneObject*)handleDoubleTap:(UITapGestureRecognizer*)gesture
{
	return _doubleTapEventHandler ? _doubleTapEventHandler(gesture) : nil;
}

- (OGLSceneObject*)handlePan:(UIPanGestureRecognizer*)gesture
{
	return _panEventHandler ? _panEventHandler(gesture) : nil;
}

- (OGLSceneObject*)handlePinch:(UIPinchGestureRecognizer*)gesture
{
	return _pinchEventHandler ? _pinchEventHandler(gesture) : nil;
}

- (CGFloat4x4)rotationlessTransform
{
	return _transform;
}

- (void)intersectBounds:(CGRect)touchArea withXForm:(CGFloat4x4)xform intoArray:(NSMutableArray*)array
{
	CGFloat4x4 sxform = mult([self rotationlessTransform], xform);
	if(_hasGeometry)
	{
		CGRect sbounds = multRect(xform, _bounds);
		if(CGRectIntersectsRect(touchArea, sbounds))
			[array addObject:[OGLSceneObjectSelWrapper wrapperWithObject:self withXForm:sxform]];
	}
	
	if([_children count])
	{
		for(OGLSceneObject* obj in _children)
		{
			if(obj.visible)
				[obj intersectBounds:touchArea withXForm:sxform intoArray:array];
		}
	}
}

- (void)rayIntersect:(CGRay)r hitList:(NSMutableArray*)hits xform:(CGFloat4x4)xform
{
	// accumulate local transform
	CGFloat4x4 exform = mult(_transform, xform);
	
	for(OGLSceneObject* obj in _children)
	{
		if(obj.visible)
		{
			if(obj.hasGeometry)
			{
				// get child local transform
				CGFloat4x4 gxform = mult(obj.transform, exform);
				CGFloat4x4 invgx = inverse(gxform);
				
				// inverse transform the ray and test for intersection
				CGFloat3 objectPos;
				CGRay hitRay = multRay(r, invgx);
				if(cubeRayInersect(obj.bbox, hitRay, &objectPos))
				{
					// transform the local hit point to world coords and determine distance
					CGFloat3 wpos = multVec3(gxform, objectPos);
					CGFloat dist = length3(CGFloat3Make(wpos.x - r.origin.x, wpos.y - r.origin.y, wpos.z - r.origin.z));
					
					OGLHitInfo* hit = [[OGLHitInfo alloc] init];
					hit.hitRay = hitRay;
					hit.hitObject = obj;
					hit.objectPos = objectPos;
					hit.worldPos = wpos;
					hit.distance = dist;
					[hits addObject:hit];
				}
			}
			
			// test children
			if([obj.children count])
				[obj rayIntersect:r hitList:hits xform:exform];
		}
	}
}


@end


@implementation OGLSceneObjectSelWrapper

+ (OGLSceneObjectSelWrapper*)wrapperWithObject:(OGLSceneObject*)obj withXForm:(CGFloat4x4)xform
{
	OGLSceneObjectSelWrapper* wrapper = [[OGLSceneObjectSelWrapper alloc] init];
	wrapper.object = obj;
	wrapper.transform = xform;
	return wrapper;
}

- (NSComparisonResult)compare:(OGLSceneObjectSelWrapper*)obj
{
	CGFloat3 vec0 = multVec3(_transform, CGFloat3Make(0, 0, 0));
	CGFloat3 vec1 = multVec3(obj.transform, CGFloat3Make(0, 0, 0));
	return (vec0.z > vec1.z) ? NSOrderedAscending : (vec0.z < vec1.z ? NSOrderedDescending : NSOrderedSame);
}

@end
