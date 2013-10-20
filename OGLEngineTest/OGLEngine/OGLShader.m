///
/// OGLShader
///
/// Created by Matt Giger
/// Copyright (c) 2013 EarthBrowser LLC. All rights reserved.
///

#import "OGLShader.h"
#import "OGLRenderInfo.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@implementation OGLShader

- (id)init
{
	if(self = [super init])
	{
	}
	return self;
}

- (void)dealloc
{
	if(_program)
		glDeleteProgram(_program);
}

- (BOOL)loadShader
{
	uint vshader = [OGLShader compileShaderString:self.vertSource ofType:GL_VERTEX_SHADER];
	uint fshader = [OGLShader compileShaderString:self.fragSource ofType:GL_FRAGMENT_SHADER];
	if(vshader && fshader)
	{
		_program = glCreateProgram();
		glAttachShader(_program, vshader);
		glAttachShader(_program, fshader);
	}
	
	if(vshader)		glDeleteShader(vshader);
	if(fshader)		glDeleteShader(fshader);
	
	GLint status;
	glLinkProgram(_program);
	glGetProgramiv(_program, GL_LINK_STATUS, &status);
	return (status != 0);
}

- (int)uniformForName:(NSString*)name
{
	int uid = (_program && name) ? glGetUniformLocation(_program, [name UTF8String]) : -1;
	return uid;
}

- (int)attributeForName:(NSString*)name
{
	int uid = (_program && name) ? glGetAttribLocation(_program, [name UTF8String]) : -1;
	return uid;
}

- (BOOL)bindShader:(OGLRenderInfo*)info
{
	if(info.shader != self)
	{
		info.shader = self;
		glUseProgram(_program);
		return YES;
	}
	return NO;
}

- (void)unbindShader:(OGLRenderInfo*)info
{
	info.shader = nil;
}

+ (uint)compileShaderString:(NSString*)source ofType:(int)type
{
	if (!source)
	{
		NSLog(@"Failed to load vertex shader");
		return 0;
	}
	
	// create shader
	uint shader = glCreateShader(type);
	GLchar *sourceStr = (GLchar *)[source UTF8String];
	glShaderSource(shader, 1, (const GLchar**)&sourceStr, NULL);	// set source code in the shader
	glCompileShader(shader);
	
	// error detection
	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (status == GL_FALSE)
	{
		GLsizei length = 511;
		GLchar errlog[512];
		glGetShaderInfoLog(shader, 511, &length, errlog);
		if(length < 512)
			errlog[length] = 0;
		NSLog(@"Failed to compile shader:%@", [NSString stringWithCString:errlog encoding:NSUTF8StringEncoding]);
		
		shader = 0;
	}
	
	return shader;
}

+ (uint)compileShader:(NSString*)name ofType:(int)type
{
	GLchar *sources = (GLchar *)[[NSString stringWithContentsOfFile:name encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!sources)
	{
		NSLog(@"Failed to load vertex shader");
		return 0;
	}
	
	uint shader = glCreateShader(type);			// create shader
	glShaderSource(shader, 1, (const GLchar**)&sources, NULL);	// set source code in the shader
	glCompileShader(shader);					// compile shader
	
	GLint status;
	glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
	if (status == GL_FALSE)
	{
		GLsizei length = 511;
		GLchar errlog[512];
		glGetShaderInfoLog(shader, 511, &length, errlog);
		if(length < 512)
			errlog[length] = 0;
		NSLog(@"Failed to compile shader:%@", [NSString stringWithCString:errlog encoding:NSUTF8StringEncoding]);
		
		shader = 0;
	}
	
	return shader;
}


@end


@interface OGLFlatShader()
{
	int		_vcoordBinding;
	int		_tcoordBinding;
	int		_texBinding;
	int		_mvpBinding;
	int		_colorBinding;
}

@end

static OGLFlatShader*	_instance;

@implementation OGLFlatShader

+ (OGLFlatShader*)shader
{
	if(!_instance)
		_instance = [[OGLFlatShader alloc] init];
	return _instance;
}

- (id)init
{
	if(self = [super init])
	{
		_color = OGLFloat4Make(1, 1, 1, 1);
		
		self.vertSource = OGLNSSTRINGIFY
		(
		 attribute vec4			position;
		 attribute vec2			texcoord;
		 uniform mat4			modelViewProjMat;
		 varying vec2			v_texcoord;
		 
		 void main()
		 {
			 v_texcoord = texcoord;
			 gl_Position = modelViewProjMat * position;
		 }
		 );
		
		self.fragSource = OGLNSSTRINGIFY
		(
		 precision mediump float;
		 uniform sampler2D		s_texture;
		 uniform vec4			color;
		 varying vec2			v_texcoord;
		 
		 void main()
		 {
			 gl_FragColor = texture2D(s_texture, v_texcoord) * color;
		 }
		 );
		
		[self loadShader];
		
		_vcoordBinding = [self attributeForName:@"position"];
		_tcoordBinding = [self attributeForName:@"texcoord"];
		_texBinding = [self uniformForName:@"s_texture"];
		
		_mvpBinding = [self uniformForName:@"modelViewProjMat"];
		_colorBinding = [self uniformForName:@"color"];
	}
	return self;
}

- (void)setColor:(OGLFloat4)color
{
	_color = color;
	glUniform4fv(_colorBinding, 1, &_color.x);
}

- (BOOL)bindShader:(OGLRenderInfo*)info
{
	if([super bindShader:info])
	{
		info.vcoordBinding = _vcoordBinding;
		info.tcoordBinding = _tcoordBinding;
		info.tex0Binding = _texBinding;
	}
	
	OGLFloat4x4 mvp = info.modelViewProjection;
	glUniformMatrix4fv(_mvpBinding, 1, false, &mvp.mat[0][0]);
	glUniform4fv(_colorBinding, 1, &_color.x);
	
	return YES;
}

@end
