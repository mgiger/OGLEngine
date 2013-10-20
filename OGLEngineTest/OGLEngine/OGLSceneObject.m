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
		_transform = identity4x4();
		
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

- (OGLFloat4x4)rotationlessTransform
{
	return _transform;
}

- (void)intersectBounds:(CGRect)touchArea withXForm:(OGLFloat4x4)xform intoArray:(NSMutableArray*)array
{
	OGLFloat4x4 sxform = mult([self rotationlessTransform], xform);
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

- (void)rayIntersect:(OGLRay)r hitList:(NSMutableArray*)hits xform:(OGLFloat4x4)xform
{
	// accumulate local transform
	OGLFloat4x4 exform = mult(_transform, xform);
	
	for(OGLSceneObject* obj in _children)
	{
		if(obj.visible)
		{
			if(obj.hasGeometry)
			{
				// get child local transform
				OGLFloat4x4 gxform = mult(obj.transform, exform);
				OGLFloat4x4 invgx = inverse(gxform);
				
				// inverse transform the ray and test for intersection
				OGLFloat3 objectPos;
				OGLRay hitRay = multRay(r, invgx);
				if(cubeRayInersect(obj.bbox, hitRay, &objectPos))
				{
					// transform the local hit point to world coords and determine distance
					OGLFloat3 wpos = multVec3(gxform, objectPos);
					CGFloat dist = length3(OGLFloat3Make(wpos.x - r.origin.x, wpos.y - r.origin.y, wpos.z - r.origin.z));
					
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

+ (OGLSceneObjectSelWrapper*)wrapperWithObject:(OGLSceneObject*)obj withXForm:(OGLFloat4x4)xform
{
	OGLSceneObjectSelWrapper* wrapper = [[OGLSceneObjectSelWrapper alloc] init];
	wrapper.object = obj;
	wrapper.transform = xform;
	return wrapper;
}

- (NSComparisonResult)compare:(OGLSceneObjectSelWrapper*)obj
{
	OGLFloat3 vec0 = multVec3(_transform, OGLFloat3Make(0, 0, 0));
	OGLFloat3 vec1 = multVec3(obj.transform, OGLFloat3Make(0, 0, 0));
	return (vec0.z > vec1.z) ? NSOrderedAscending : (vec0.z < vec1.z ? NSOrderedDescending : NSOrderedSame);
}

@end
