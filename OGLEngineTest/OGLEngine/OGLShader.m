///
/// OGLShader
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

#import "OGLShader.h"
#import "OGLRenderInfo.h"

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@interface OGLShader()

+ (uint)compileShader:(NSString*)name ofType:(int)type;
+ (uint)compileShaderString:(NSString*)source ofType:(int)type;

@end

///////////////////////////////////////////////////////////////////////////
///
/// @class OGLShader
///
/// Shader program object
///
///////////////////////////////////////////////////////////////////////////
@implementation OGLShader

- (id)init
{
	if(self = [super init])
	{
		_alpha = 1.0f;
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
