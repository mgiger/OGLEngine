//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLSprite.h"
#import "OGLRenderInfo.h"
#import "OGLBuffer.h"
#import "OGLCamera.h"
#import "OGLContext.h"
#import "OGLTexture.h"
#import "OGLVertexArray.h"
#import "OGLShader.h"
#import "OGLNetRequest.h"
#import "OGLDatabase.h"
#import "OGLWorkQueue.h"

static NSMutableDictionary*		_iconTextures;

@interface OGLSprite()

@property (nonatomic, assign)	CGSize			texsize;
@property (nonatomic, assign)	CGFloat4		texbounds;
@property (nonatomic, strong)	OGLBuffer*		vertexBuf;
@property (nonatomic, strong)	OGLVertexArray*	varray;

@end

@implementation OGLSprite

+ (void)loadDBImage:(NSString*)url withCompletion:(void (^)(OGLTextureData* data))completion
{
	if([url length])
	{
		NSData* data = [OGLDatabase dataWithID:url];
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
			OGLNetRequest* request = [OGLNetRequest request:url];
			[request.headers setObject:@"image/*" forKey:@"Accept"];
			request.parseHandler = ^(OGLNetRequest* req)
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
							[OGLDatabase saveData:req.responseBody withID:url purgeAge:7];
						}];
					}
				}
			};
			request.completionHandler = ^(OGLNetRequest* req)
			{
				if(completion)
					completion(req.userData);
			};
			[OGLNetQueue add:request];
		}
	}
}

- (id)init
{
	if(self = [super init])
	{
		_color = CGFloat4Make(1, 1, 1, 1);
		_scale = CGFloat3Make(1, 1, 1);
		_texbounds = CGFloat4Make(0, 0, 1, 1);
	}
	return self;
}

- (void)updateTransform
{
	if(_rotation != 0)
	{
		CGFloat4x4 xform = mult(translation4x4(-_size.width*0.5, -_size.height*0.5, 0), rotation4x4(_rotation, CGFloat3Make(0,0,1)));
		xform = mult(xform, translation4x4(_size.width*0.5, _size.height*0.5, 0));
		self.transform = mult(xform, mult(scale4x4(_scale.x, _scale.y, _scale.z), translation4x4(_position.x + _offset.x, _position.y + _offset.y, _position.z + _offset.z)));
	}
	else
		self.transform = mult(scale4x4(_scale.x, _scale.y, _scale.z), translation4x4(_position.x + _offset.x, _position.y + _offset.y, _position.z + _offset.z));
}

- (CGFloat4x4)rotationlessTransform
{
	if(_rotation != 0)
		return mult(scale4x4(_scale.x, _scale.y, _scale.z), translation4x4(_position.x + _offset.x, _position.y + _offset.y, _position.z + _offset.z));
	return self.transform;
}

- (void)updateBounds
{
	self.bounds = multRect([self rotationlessTransform], CGRectMake(0,0,_size.width,_size.height));
}

- (void)setAlpha:(float)alpha
{
	_alpha = alpha;
	_color.w = alpha;
}

- (void)setSize:(CGSize)size
{
	_size = size;
	[self buildGeometry];
	[self updateTransform];
	[self updateBounds];
}

- (void)setOffset:(CGFloat3)offset
{
	_offset = offset;
	[self updateTransform];
	[self updateBounds];
}

- (void)setPosition:(CGFloat3)position
{
	_position = position;
	[self updateTransform];
	[self updateBounds];
}

- (void)setScale:(CGFloat3)scale
{
	_scale = scale;
	[self updateTransform];
	[self updateBounds];
}

- (void)setRotation:(float)rotation
{
	if(_rotation != rotation)
	{
		_rotation = rotation;
		[self updateTransform];
//		[self updateBounds];
	}
}

- (void)setGLTexture:(OGLTexture *)texture centered:(BOOL)centered
{
	_texture = texture;
	if(_texture)
	{
		_texsize = CGSizeMake(_texture.width, _texture.height);
		_size = CGSizeMake(_texsize.width / _ScreenScale, _texsize.height / _ScreenScale);
		[self buildGeometry];
		[self updateTransform];
		[self updateBounds];
	}
}

- (void)setImageName:(NSString*)imageName centered:(BOOL)centered
{
	@synchronized(_iconTextures)
	{
		OGLTexture* tex = [_iconTextures objectForKey:imageName];
		if(tex)
		{
			_size = _texsize = CGSizeMake(tex.width, tex.height);
			self.texture = tex;
			if(centered)
				_offset = CGFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);
			[self updateTransform];
			[self buildGeometry];
			[self updateBounds];
			return;
		}
	}
	
	UIImage* image = [UIImage imageNamed:imageName];
	if(image)
	{
		OGLTextureData* data = [[OGLTextureData alloc] init];
		[data loadCGImage:image.CGImage];
		
		_texsize = CGSizeMake(data.width, data.height);
		self.texture = [[OGLTexture alloc] init];
		[self.texture uploadData:data];
		self.texture.available = YES;
		
		_size = _texsize;
		if(centered)
			_offset = CGFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);
		[self updateTransform];
		[self buildGeometry];
		[self updateBounds];

		@synchronized(_iconTextures)
		{
			[_iconTextures setValue:_texture forKey:imageName];
		}
	}
}

- (void)setImageURL:(NSString*)imageURL centered:(BOOL)centered
{
	if(![imageURL length])
		return;
	
	@synchronized(_iconTextures)
	{
		OGLTexture* tex = [_iconTextures objectForKey:imageURL];
		if(tex)
		{
			_size = _texsize = CGSizeMake(tex.width, tex.height);
			self.texture = tex;
			if(centered)
				_offset = CGFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);;
			[self buildGeometry];
			[self updateTransform];
			[self updateBounds];
			return;
		}
	}
	
	[OGLSprite loadDBImage:imageURL withCompletion:^(OGLTextureData* data)
	{
		self.texture = [[OGLTexture alloc] init];
		[self.texture uploadData:data];
		self.texture.available = YES;
		
		_size = _texsize = CGSizeMake(data.width, data.height);
		if(centered)
			_offset = CGFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);
		[self buildGeometry];
		[self updateTransform];
		[self updateBounds];
		
		@synchronized(_iconTextures)
		{
			[_iconTextures setValue:_texture forKey:imageURL];
		}
	}];
}

- (void)buildGeometry
{
	float quadbuf[] = {
		0,				0,				_texbounds.x, _texbounds.y,
		0,				_size.height,	_texbounds.x, _texbounds.w,
		_size.width,	0,				_texbounds.z, _texbounds.y,
		_size.width,	0,				_texbounds.z, _texbounds.y,
		0,				_size.height,	_texbounds.x, _texbounds.w,
		_size.width,	_size.height,	_texbounds.z, _texbounds.w
	};
	
	self.hasGeometry = YES;

	if(!_vertexBuf)
		_vertexBuf = [[OGLBuffer alloc] initArrayBuffer];
	_vertexBuf.available = NO;
	
	if([[NSThread currentThread] isMainThread])
	{
		[_vertexBuf uploadData:[NSData dataWithBytesNoCopy:quadbuf length:sizeof(quadbuf) freeWhenDone:NO]];
		_vertexBuf.available = YES;
	}
	else
	{
		[[OGLContext worker] uploadData:[NSData dataWithBytesNoCopy:quadbuf length:sizeof(quadbuf) freeWhenDone:NO] intoBuffer:_vertexBuf];
	}
}

- (void)render:(OGLRenderInfo*)info
{
	if(self.visible)
	{
		if(_autoRotation)
			self.rotation = _rotation - _autoRotation;
		
		[info pushTransform:self.transform];
		
		if(self.hasGeometry && _texture.available && _vertexBuf.available)
		{
			OGLFlatShader* shader = [OGLFlatShader shader];
			[shader bindShader:info];
			shader.color = _color;
			[_texture bindTo:info.tex0Binding unit:0];
			
			if(!_varray)
			{
				_varray = [[OGLVertexArray alloc] init];
				[_varray bind];
				[_vertexBuf bind];
				glEnableVertexAttribArray(info.vcoordBinding);
				glEnableVertexAttribArray(info.tcoordBinding);
				glVertexAttribPointer(info.vcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), 0);
				glVertexAttribPointer(info.tcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (char*)sizeof(CGPoint));
				[_vertexBuf unbind];
				[_varray unbind];
			}
			{
				[_varray bind];
				[_vertexBuf bind];
				glDrawArrays(GL_TRIANGLES, 0, 6);
				[_vertexBuf unbind];
				[_varray unbind];
			}
			
			[_texture unbind];
		}
		
		for(OGLSceneObject* obj in self.children)
			[obj render:info];
		
		[info popTransform];
	}
}

@end



@interface OGLSpriteLayer()

@property (nonatomic, strong)	OGLCamera*	camera;
@property (nonatomic, assign)	CGFloat		touchPixelRadius;

@end


@implementation OGLSpriteLayer

- (id)init
{
	if(self = [super init])
	{
		_touchPixelRadius = 10 * [UIScreen mainScreen].scale;
		_selectedSet = [[NSMutableArray alloc] init];
		
		_camera = [[OGLCamera alloc] init];
		_camera.ortho = YES;
		_camera.position = CGFloat3Make(0, 0, 101.0f);
		_camera.forward = CGFloat3Make(0, 0, -1);
		_camera.near = 100;
		_camera.far = -100;
	}
	return self;
}

- (void)setScreenSize:(CGSize)ssize
{
	[_camera setScreenSize:ssize];
}

- (NSMutableArray*)findSelected:(CGRect)bounds
{
	NSMutableArray* array = [NSMutableArray array];
	for(OGLSceneObject* obj in self.children)
	{
		if(obj.visible)
			[obj intersectBounds:bounds withXForm:identity4x4() intoArray:array];
	}
	[array sortUsingSelector:@selector(compare:)];
	return array;
}

- (void)render:(OGLRenderInfo *)info
{
	[_camera render:info];
	[super render:info];
}


@end
