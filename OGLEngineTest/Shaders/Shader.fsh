//
//  Shader.fsh
//  OGLEngineTest
//
//  Created by Matt Giger on 10/19/13.
//  Copyright (c) 2013 Matt Giger. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
