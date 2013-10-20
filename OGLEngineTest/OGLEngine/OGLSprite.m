///
/// OGLSprite
///
/// Created by Matt Giger
/// Copyright (c) 2013 EarthBrowser LLC. All rights reserved.
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
/// documentation files (the "Software"), to deal in the Software without restriction, including without limitation
/// the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
/// permit persons to whom the Software is furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
/// OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
/// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
/// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
///


#import "OGLSprite.h"
#import "OGLRenderInfo.h"
#import "OGLBuffer.h"
#import "OGLContext.h"
#import "OGLTexture.h"
#import "OGLVertexArray.h"

static NSMutableDictionary*		_iconTextures;

@interface OGLSprite()

@property (nonatomic, assign)	CGSize			texsize;
@property (nonatomic, assign)	CGFloat4		texbounds;
@property (nonatomic, strong)	OGLBuffer*		vertexBuf;
@property (nonatomic, strong)	OGLVertexArray*	varray;

@end

@implementation OGLSprite

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
	
	[ImageCache loadDBImage:imageURL withCompletion:^(OGLTextureData* data)
	{
		self.texture = [[OGLTexture alloc] init];
		[self.texture uploadData:data];
		self.texture.available = YES;
		
		_size = _texsize = float2(data.width, data.height);
		if(centered)
			_offset = float3(_size.x, _size.y, 0) * -0.5f;
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
			TextShader* shader = [TextShader shader];
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
			
//			[_vertexBuf bind];
//			glEnableVertexAttribArray(info.vcoordBinding);
//			glEnableVertexAttribArray(info.tcoordBinding);
//			glVertexAttribPointer(info.vcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), 0);
//			glVertexAttribPointer(info.tcoordBinding, 2, GL_FLOAT, GL_FALSE, 4*sizeof(float), (char*)sizeof(float2));
//			glDrawArrays(GL_TRIANGLES, 0, 6);
//			[_vertexBuf unbind];
			
			[_texture unbind];
		}
		
		for(OGLSceneObject* obj in self.children)
			[obj render:info];
		
		[info popTransform];
	}
}

@end
