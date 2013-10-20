//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//

#import "OGLSprite.h"
#import "OGLRenderInfo.h"
#import "OGLCamera.h"
#import "OGLContext.h"
#import "OGLTexture.h"
#import "OGLShader.h"
#import "OGLNetRequest.h"
#import "OGLDatabase.h"
#import "OGLWorkQueue.h"
#import "OGLTween.h"

static NSMutableDictionary*		_iconTextures;

@interface OGLSprite()

@property (nonatomic, assign)	CGSize			texsize;
@property (nonatomic, assign)	OGLFloat4		texbounds;
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
		_color = OGLFloat4Make(1, 1, 1, 1);
		_scale = OGLFloat3Make(1, 1, 1);
		_texbounds = OGLFloat4Make(0, 0, 1, 1);
	}
	return self;
}

- (void)updateTransform
{
	if(_rotation != 0)
	{
		OGLFloat4x4 xform = mult(translation4x4(-_size.width*0.5, -_size.height*0.5, 0), rotation4x4(_rotation, OGLFloat3Make(0,0,1)));
		xform = mult(xform, translation4x4(_size.width*0.5, _size.height*0.5, 0));
		self.transform = mult(xform, mult(scale4x4(_scale.x, _scale.y, _scale.z), translation4x4(_position.x + _offset.x, _position.y + _offset.y, _position.z + _offset.z)));
	}
	else
		self.transform = mult(scale4x4(_scale.x, _scale.y, _scale.z), translation4x4(_position.x + _offset.x, _position.y + _offset.y, _position.z + _offset.z));
}

- (OGLFloat4x4)rotationlessTransform
{
	if(_rotation != 0)
		return mult(scale4x4(_scale.x, _scale.y, _scale.z), translation4x4(_position.x + _offset.x, _position.y + _offset.y, _position.z + _offset.z));
	return self.transform;
}

- (void)updateBounds
{
	self.bounds = multRect([self rotationlessTransform], CGRectMake(0,0,_size.width,_size.height));
}

- (void)setAlpha:(CGFloat)alpha
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

- (void)setOffset:(OGLFloat3)offset
{
	_offset = offset;
	[self updateTransform];
	[self updateBounds];
}

- (void)setPosition:(OGLFloat3)position
{
	_position = position;
	[self updateTransform];
	[self updateBounds];
}

- (void)setScale:(OGLFloat3)scale
{
	_scale = scale;
	[self updateTransform];
	[self updateBounds];
}

- (void)setRotation:(CGFloat)rotation
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
				_offset = OGLFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);
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
			_offset = OGLFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);
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
				_offset = OGLFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);;
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
			_offset = OGLFloat3Make(-_size.width * 0.5, -_size.height * 0.5, 0);
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
	
	NSData* data = [NSData dataWithBytesNoCopy:quadbuf length:sizeof(quadbuf) freeWhenDone:NO];
	if([[NSThread currentThread] isMainThread])
	{
		[_vertexBuf uploadData:data];
		_vertexBuf.available = YES;
	}
	else
	{
		[[OGLContext worker] uploadData:data intoBuffer:_vertexBuf];
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
			
//			if(!_varray)
//			{
//				_varray = [[OGLVertexArray alloc] init];
//				[_varray bind];
//				[_vertexBuf bind];
//				glEnableVertexAttribArray(info.vcoordBinding);
//				glEnableVertexAttribArray(info.tcoordBinding);
//				glVertexAttribPointer(info.vcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), 0);
//				glVertexAttribPointer(info.tcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (char*)sizeof(CGPoint));
//				[_vertexBuf unbind];
//				[_varray unbind];
//			}
//			{
//				[_varray bind];
//				[_vertexBuf bind];
//				glDrawArrays(GL_TRIANGLES, 0, 6);
//				[_vertexBuf unbind];
//				[_varray unbind];
//			}

			
			[_vertexBuf bind];
			glEnableVertexAttribArray(info.vcoordBinding);
			glEnableVertexAttribArray(info.tcoordBinding);
			glVertexAttribPointer(info.vcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), 0);
			glVertexAttribPointer(info.tcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (char*)sizeof(CGPoint));
			glDrawArrays(GL_TRIANGLES, 0, 6);
			[_vertexBuf unbind];

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
		_camera.position = OGLFloat3Make(0, 0, 101.0f);
		_camera.forward = OGLFloat3Make(0, 0, -1);
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



static UILabel*		_sharedLabel;

@implementation OGLLabel

- (id)init
{
	if(self = [super init])
	{
		self.hasGeometry = YES;
		_font = [UIFont boldSystemFontOfSize:16];
	}
	return self;
}

- (void)setText:(NSString*)text
{
	_text = text;
	[self performSelectorOnMainThread:@selector(renderText) withObject:nil waitUntilDone:NO];
}

- (void)renderText
{
	if([_text length])
	{
		CGRect lbounds = [_text boundingRectWithSize:CGSizeMake(_maxWidth > 0 ? _maxWidth : 10000, 10000)
											 options:NSStringDrawingUsesLineFragmentOrigin
										  attributes:@{NSFontAttributeName:_font}
											 context:nil];
		
		if(!_sharedLabel)
		{
			_sharedLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lbounds.size.width, lbounds.size.height)];
			_sharedLabel.backgroundColor = [UIColor clearColor];
			_sharedLabel.opaque = NO;
			_sharedLabel.textAlignment = NSTextAlignmentCenter;
			_sharedLabel.font = _font;
			_sharedLabel.numberOfLines = 0;
			_sharedLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.75];
			_sharedLabel.shadowOffset = CGSizeMake(1.5, 1.5);
		}
		else
			_sharedLabel.frame = CGRectMake(0, 0, lbounds.size.width, lbounds.size.height);
		
		_sharedLabel.textColor = [UIColor colorWithRed:self.color.x green:self.color.y blue:self.color.z alpha:1.0];
		_sharedLabel.text = _text;
		[_sharedLabel layoutIfNeeded];
		
		OGLTexture* texture = nil;
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		if(colorSpace)
		{
			CGSize size = CGSizeMake(ceilf(lbounds.size.width * _ScreenScale), ceilf(lbounds.size.height * _ScreenScale));
			NSData* data = [NSMutableData dataWithLength:size.height * size.width * 4];
			CGContextRef context = CGBitmapContextCreate((char*)[data bytes], size.width, size.height, 8, 4 * size.width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
			if(context)
			{
				CGContextTranslateCTM(context, 0, size.height);
				CGContextScaleCTM(context, _ScreenScale, -_ScreenScale);
				
				texture = [[OGLTexture alloc] init];
				texture.width = size.width;
				texture.height = size.height;
				
				[_sharedLabel.layer renderInContext:context];
				
				if([[NSThread currentThread] isMainThread])
				{
					[texture uploadData:[OGLTextureData dataWithData:data size:size depth:4]];
					texture.available = YES;
				}
				else
				{
					[[OGLContext worker] uploadData:[OGLTextureData dataWithData:data size:size depth:4] intoTexture:texture];
				}
				
				CGContextRelease(context);
			}
			CGColorSpaceRelease(colorSpace);
		}
		
		if(texture)
		{
			[self setGLTexture:texture centered:NO];
		}
		
		self.visible = YES;
	}
	else
	{
		self.visible = NO;
	}
}

@end


static OGLAnnotation*	_current = nil;

@implementation OGLAnnotation

+ (void)closeCurrentAnnotaion
{
	if(_current)
	{
		if(_current.close)
			_current.close();
		_current = nil;
	}
}

- (id)initWithAnnotationView:(OGLAnnotationView*)view action:(OGLSimpleBlock)action close:(OGLSimpleBlock)close
{
	if(self = [super init])
	{
		_scaleFactor = 1.0;
		_current = self;
		self.action = action;
		self.close = close;
		
		__weak OGLAnnotation* weak_self = self;
		[self setGLTexture:[view glTexture] centered:NO];
		if(_action)
		{
			self.tapEventHandler = ^(UITapGestureRecognizer* gesture)
			{
				weak_self.action();
				return weak_self;
			};
		}
		
		self.offset = OGLFloat3Make(-view.bounds.size.width*0.5, -view.bounds.size.height, 20);
		[self updateTransform];
		
		[OGLTween tweenFrom:0 to:1 method:tweenOutElastic duration:.7 delay:0 identifier:nil
				 animations:^(float value) {
					 float v = value * _scaleFactor;
					 self.transform = mult(scale4x4(v, v, v), translationVec4x4(OGLFloat3Mult(self.offset, v)));
				 }
				 completion:^(BOOL finished) {
					 self.scale = OGLFloat3Make(_scaleFactor, _scaleFactor, _scaleFactor);
					 self.offset = OGLFloat3Mult(self.offset, _scaleFactor);
				 }
		 ];
	}
	return self;
}

- (void)setViewTexture:(OGLAnnotationView*)view
{
	[self setGLTexture:[view glTexture] centered:NO];
}

@end


@implementation OGLAnnotationView

+ (id)view
{
	NSArray *objects = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
	for (id object in objects)
	{
		NSAssert([object isKindOfClass:[self class]], @"View is of wrong type!");
		[object setNeedsLayout];
		return object;
	}
	return nil;
}

- (OGLTexture*)glTexture
{
	[self layoutIfNeeded];
	
	UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	OGLTexture* texture = [[OGLTexture alloc] init];
	[texture uploadData:[OGLTextureData dataWithImage:img.CGImage]];
	texture.available = YES;
	return texture;
}

@end
