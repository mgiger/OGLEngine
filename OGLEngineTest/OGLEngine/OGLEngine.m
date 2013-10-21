//
//	OGLEngine
//
//	Copyright (c) 2013 Matt Giger. All rights reserved.
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//	documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//	the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
//	to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO
//	THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//	TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "OGLEngine.h"

const float	c_pi						= 3.141592653589793238462643383279502884197f;
const float	c_pi_recip					= 1.0f / c_pi;
const float	c_quarter_pi				= c_pi * 0.25f;
const float	c_half_pi					= c_pi * 0.5f;
const float	c_deg						= 180.0f / c_pi;
const float	c_rad						= c_pi / 180.0f;

OGLFloat3 OGLFloat3Make(float x, float y, float z)
{
	OGLFloat3 value = {x, y, z};
	return value;
}

OGLFloat3 OGLFloat3Mult(OGLFloat3 a, float v)
{
	OGLFloat3 value = {a.x*v, a.y*v, a.z*v};
	return value;
}

OGLFloat4 OGLFloat4Make(float x, float y, float z, float w)
{
	OGLFloat4 value = {x, y, z, w};
	return value;
}

OGLPlane OGLPlaneMake(float a, float b, float c, float d)
{
	OGLPlane value = {a, b, c, d};
	return value;
}

OGLPlane OGLPlaneNormalize(OGLPlane p)
{
	float inv = 1 / sqrt(p.a*p.a + p.b*p.b + p.c*p.c);
	
	OGLPlane value;
	value.a = p.a * inv;
	value.b = p.b * inv;
	value.c = p.c * inv;
	value.d = p.d * inv;
	return value;
}

OGLFloat3 normalVec3(OGLFloat3 v)
{
	float inv = 1 / sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
	
	OGLFloat3 value;
	value.x = v.x * inv;
	value.y = v.y * inv;
	value.z = v.z * inv;
	return value;
}

OGLQuaternion OGLQuaternionMake(float angle, OGLFloat3 axis)
{
	OGLQuaternion value;
	float ang = angle * 0.5;
	float s = sin(ang);
	value.w = cos(ang);
	value.x = s * axis.x;
	value.y = s * axis.y;
	value.z = s * axis.z;
	return value;
}

OGLFrustum OGLFrustumMake(OGLFloat4x4 mvp)
{
	OGLFrustum value;
	
	// left & right planes
	value.plane[0] = OGLPlaneMake(mvp.mat[3][0] + mvp.mat[0][0], mvp.mat[3][1] + mvp.mat[0][1], mvp.mat[3][2] + mvp.mat[0][2], mvp.mat[3][3] - mvp.mat[0][3]);
	value.plane[1] = OGLPlaneMake(mvp.mat[3][0] - mvp.mat[0][0], mvp.mat[3][1] - mvp.mat[0][1], mvp.mat[3][2] - mvp.mat[0][2], mvp.mat[3][3] - mvp.mat[0][3]);
	value.plane[0] = OGLPlaneNormalize(value.plane[0]);
	value.plane[1] = OGLPlaneNormalize(value.plane[1]);
	
	// top & bottom planes
	value.plane[2] = OGLPlaneMake(mvp.mat[3][0] - mvp.mat[1][0], mvp.mat[3][1] - mvp.mat[1][1], mvp.mat[3][2] - mvp.mat[1][2], mvp.mat[3][3] - mvp.mat[1][3]);
	value.plane[3] = OGLPlaneMake(mvp.mat[3][0] + mvp.mat[1][0], mvp.mat[3][1] + mvp.mat[1][1], mvp.mat[3][2] + mvp.mat[1][2], mvp.mat[3][3] + mvp.mat[1][3]);
	value.plane[2] = OGLPlaneNormalize(value.plane[2]);
	value.plane[3] = OGLPlaneNormalize(value.plane[3]);
	
	// near & far planes
	value.plane[4] = OGLPlaneMake(mvp.mat[3][0] + mvp.mat[2][0], mvp.mat[3][1] + mvp.mat[2][1], mvp.mat[3][2] + mvp.mat[2][2], mvp.mat[3][3] + mvp.mat[2][3]);
	value.plane[5] = OGLPlaneMake(mvp.mat[3][0] - mvp.mat[2][0], mvp.mat[3][1] - mvp.mat[2][1], mvp.mat[3][2] - mvp.mat[2][2], mvp.mat[3][3] - mvp.mat[2][3]);
	value.plane[4] = OGLPlaneNormalize(value.plane[4]);
	value.plane[5] = OGLPlaneNormalize(value.plane[5]);
	
	return value;
}

OGLRay OGLRayMake(OGLFloat3 origin, OGLFloat3 direction)
{
	OGLRay value;
	value.origin = origin;
	value.direction = direction;
	return value;
}

OGLFloat4x4 identity4x4()
{
	OGLFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(float));
	value.mat[0][0] = value.mat[1][1] = value.mat[2][2] = value.mat[3][3] = 1;
	return value;
}


OGLFloat4x4 scaleVec4x4(OGLFloat3 a)
{
	OGLFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(float));
	value.mat[0][0] = a.x;
	value.mat[1][1] = a.y;
	value.mat[2][2] = a.z;
	value.mat[3][3] = 1;
	return value;
}

OGLFloat4x4 scale4x4(float x, float y, float z)
{
	OGLFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(float));
	value.mat[0][0] = x;
	value.mat[1][1] = y;
	value.mat[2][2] = z;
	value.mat[3][3] = 1;
	return value;
}


OGLFloat4x4 translationVec4x4(OGLFloat3 a)
{
	OGLFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(float));
	value.mat[0][0] = value.mat[1][1] = value.mat[2][2] = value.mat[3][3] = 1;
	value.mat[3][0] = a.x;
	value.mat[3][1] = a.y;
	value.mat[3][2] = a.z;
	return value;
}

OGLFloat4x4 translation4x4(float x, float y, float z)
{
	OGLFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(float));
	value.mat[0][0] = value.mat[1][1] = value.mat[2][2] = value.mat[3][3] = 1;
	value.mat[3][0] = x;
	value.mat[3][1] = y;
	value.mat[3][2] = z;
	return value;
}

OGLFloat4x4 rotation4x4(float angle, OGLFloat3 axis)
{
	OGLQuaternion q = OGLQuaternionMake(angle, axis);
	float x2 = q.x + q.x, y2 = q.y + q.y, z2 = q.z + q.z;
	float xx = q.x * x2, xy = q.x * y2, xz = q.x * z2;
	float yy = q.y * y2, yz = q.y * z2, zz = q.z * z2;
	float wx = q.w * x2, wy = q.w * y2, wz = q.w * z2;
	
	OGLFloat4x4 value;
	value.mat[0][0] = 1-(yy+zz);	value.mat[1][0] = xy+wz;		value.mat[2][0] = xz-wy;		value.mat[3][0] = 0.0;
	value.mat[0][1] = xy-wz;		value.mat[1][1] = 1-(xx+zz);	value.mat[2][1] = yz+wx;		value.mat[3][1] = 0.0;
	value.mat[0][2] = xz+wy;		value.mat[1][2] = yz-wx;		value.mat[2][2] = 1-(xx+yy);	value.mat[3][2] = 0.0;
	value.mat[0][3] = 0.0;			value.mat[1][3] = 0.0;			value.mat[2][3] = 0.0;			value.mat[3][3] = 1.0;
	return value;
}

OGLFloat4x4 orthographic4x4(float left, float right, float bottom, float top, float znear, float zfar)
{
	OGLFloat4x4 value;
	
	float rml = right - left;
	float tmb = top - bottom;
	float fmn = zfar - znear;
	memset(value.mat, 0, 16 * sizeof(float));
	
	value.mat[0][0] = 2/rml;
	value.mat[1][1] = 2/tmb;
	value.mat[2][2] = 2/fmn;
	value.mat[3][0] = -(right + left)/rml;
	value.mat[3][1] = -(top + bottom)/tmb;
	value.mat[3][2] = -(zfar + znear)/fmn;
	value.mat[3][3] = 1;
	
	return value;
}

OGLFloat4x4 perspective4x4(float fov, float aspect, float near, float far)
{
	float f = 1.0 / tan(fov * 0.5 * c_rad);
	float n = 1.0 / (near - far);
	
	OGLFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(float));
	value.mat[0][0] = f/aspect;
	value.mat[1][1] = f;
	value.mat[2][2] = (far+near)*n;
	value.mat[2][3] = -1;
	value.mat[3][2] = 2*far*near*n;
	return value;
}

OGLFloat4x4 look_toward4x4(OGLFloat3 forward, OGLFloat3 up)
{
	OGLFloat3 side = cross(forward, up);
	OGLFloat3 nup = cross(side, forward);
	
	OGLFloat4x4 value;
	value.mat[0][0] = side.x;
	value.mat[1][0] = side.y;
	value.mat[2][0] = side.z;
	value.mat[3][0] = 0;
	value.mat[0][1] = nup.x;
	value.mat[1][1] = nup.y;
	value.mat[2][1] = nup.z;
	value.mat[3][1] = 0;
	value.mat[0][2] = -forward.x;
	value.mat[1][2] = -forward.y;
	value.mat[2][2] = -forward.z;
	value.mat[3][2] = 0;
	value.mat[0][3] = 0;
	value.mat[1][3] = 0;
	value.mat[2][3] = 0;
	value.mat[3][3] = 1;
	return value;
}



float length3(OGLFloat3 a)
{
	return sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
}

OGLFloat3 cross(OGLFloat3 a, OGLFloat3 b)
{
	return OGLFloat3Make(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x);
}



OGLFloat4x4 mult(OGLFloat4x4 a, OGLFloat4x4 b)
{
	OGLFloat4x4 ret;
	
	ret.mat[0][0] = a.mat[0][0]*b.mat[0][0] + a.mat[0][1]*b.mat[1][0] + a.mat[0][2]*b.mat[2][0] + a.mat[0][3]*b.mat[3][0];
	ret.mat[0][1] = a.mat[0][0]*b.mat[0][1] + a.mat[0][1]*b.mat[1][1] + a.mat[0][2]*b.mat[2][1] + a.mat[0][3]*b.mat[3][1];
	ret.mat[0][2] = a.mat[0][0]*b.mat[0][2] + a.mat[0][1]*b.mat[1][2] + a.mat[0][2]*b.mat[2][2] + a.mat[0][3]*b.mat[3][2];
	ret.mat[0][3] = a.mat[0][0]*b.mat[0][3] + a.mat[0][1]*b.mat[1][3] + a.mat[0][2]*b.mat[2][3] + a.mat[0][3]*b.mat[3][3];
	
	ret.mat[1][0] = a.mat[1][0]*b.mat[0][0] + a.mat[1][1]*b.mat[1][0] + a.mat[1][2]*b.mat[2][0] + a.mat[1][3]*b.mat[3][0];
	ret.mat[1][1] = a.mat[1][0]*b.mat[0][1] + a.mat[1][1]*b.mat[1][1] + a.mat[1][2]*b.mat[2][1] + a.mat[1][3]*b.mat[3][1];
	ret.mat[1][2] = a.mat[1][0]*b.mat[0][2] + a.mat[1][1]*b.mat[1][2] + a.mat[1][2]*b.mat[2][2] + a.mat[1][3]*b.mat[3][2];
	ret.mat[1][3] = a.mat[1][0]*b.mat[0][3] + a.mat[1][1]*b.mat[1][3] + a.mat[1][2]*b.mat[2][3] + a.mat[1][3]*b.mat[3][3];
	
	ret.mat[2][0] = a.mat[2][0]*b.mat[0][0] + a.mat[2][1]*b.mat[1][0] + a.mat[2][2]*b.mat[2][0] + a.mat[2][3]*b.mat[3][0];
	ret.mat[2][1] = a.mat[2][0]*b.mat[0][1] + a.mat[2][1]*b.mat[1][1] + a.mat[2][2]*b.mat[2][1] + a.mat[2][3]*b.mat[3][1];
	ret.mat[2][2] = a.mat[2][0]*b.mat[0][2] + a.mat[2][1]*b.mat[1][2] + a.mat[2][2]*b.mat[2][2] + a.mat[2][3]*b.mat[3][2];
	ret.mat[2][3] = a.mat[2][0]*b.mat[0][3] + a.mat[2][1]*b.mat[1][3] + a.mat[2][2]*b.mat[2][3] + a.mat[2][3]*b.mat[3][3];
	
	ret.mat[3][0] = a.mat[3][0]*b.mat[0][0] + a.mat[3][1]*b.mat[1][0] + a.mat[3][2]*b.mat[2][0] + a.mat[3][3]*b.mat[3][0];
	ret.mat[3][1] = a.mat[3][0]*b.mat[0][1] + a.mat[3][1]*b.mat[1][1] + a.mat[3][2]*b.mat[2][1] + a.mat[3][3]*b.mat[3][1];
	ret.mat[3][2] = a.mat[3][0]*b.mat[0][2] + a.mat[3][1]*b.mat[1][2] + a.mat[3][2]*b.mat[2][2] + a.mat[3][3]*b.mat[3][2];
	ret.mat[3][3] = a.mat[3][0]*b.mat[0][3] + a.mat[3][1]*b.mat[1][3] + a.mat[3][2]*b.mat[2][3] + a.mat[3][3]*b.mat[3][3];
	
	return ret;
}

OGLFloat3 multVec3(OGLFloat4x4 m, OGLFloat3 a)
{
	OGLFloat3 value;
	value.x = m.mat[0][0]*a.x + m.mat[1][0]*a.y + m.mat[2][0]*a.z + m.mat[3][0];
	value.y = m.mat[0][1]*a.x + m.mat[1][1]*a.y + m.mat[2][1]*a.z + m.mat[3][1];
	value.z = m.mat[0][2]*a.x + m.mat[1][2]*a.y + m.mat[2][2]*a.z + m.mat[3][2];
	return value;
}

OGLFloat4 multVec4(OGLFloat4x4 m, OGLFloat4 v)
{
	OGLFloat4 value;
	value.x = m.mat[0][0]*v.x + m.mat[1][0]*v.y + m.mat[2][0]*v.z + m.mat[3][0]*v.w;
	value.y = m.mat[0][1]*v.x + m.mat[1][1]*v.y + m.mat[2][1]*v.z + m.mat[3][1]*v.w;
	value.z = m.mat[0][2]*v.x + m.mat[1][2]*v.y + m.mat[2][2]*v.z + m.mat[3][2]*v.w;
	value.w = m.mat[0][3]*v.x + m.mat[1][3]*v.y + m.mat[2][3]*v.z + m.mat[3][3]*v.w;
	return value;
}

CGRect multRect(OGLFloat4x4 m, CGRect r)
{
	CGRect value;
	value.origin.x = m.mat[0][0]*r.origin.x + m.mat[1][0]*r.origin.y + m.mat[3][0];
	value.origin.y = m.mat[0][1]*r.origin.x + m.mat[1][1]*r.origin.y + m.mat[3][1];
	value.size.width = m.mat[0][0]*r.size.width + m.mat[1][0]*r.size.height;
	value.size.height = m.mat[0][1]*r.size.width + m.mat[1][1]*r.size.height;
	return value;
}



void ludcmp(OGLFloat4x4* m, float** a, int indx[], float *d, int size)
{
	int	i, imax, j, k;
	float	big, dum, sum, temp, vv[8];
	
	*d = 1.0;
	for(i=0;i<size;i++) {
		big = 0.0;
		for(j=0;j<size;j++)
			if((temp = fabs(a[i][j])) > big)
				big = temp;
		
		vv[i] = 1.0/big;
	}
	for(j=0;j<size;j++) {
		for(i=0;i<j;i++) {
			sum = a[i][j];
			for(k=0;k<i;k++)
				sum -= a[i][k]*a[k][j];
			a[i][j] = sum;
		}
		
		imax=j;
		big=0.0;
		for(i=j;i<size;i++) {
			sum = a[i][j];
			for(k=0;k<j;k++)
				sum -= a[i][k]*a[k][j];
			a[i][j] = sum;
			if( (dum=vv[i]*fabs(sum)) >= big) {
				big = dum;
				imax = i;
			}
		}
		
		if(j != imax) {
			for(k=0;k<size;k++) {
				dum = a[imax][k];
				a[imax][k] = a[j][k];
				a[j][k] = dum;
			}
			*d = -(*d);
			vv[imax] = vv[j];
		}
		
		indx[j] = imax;
		if(a[j][j] == 0.0)
			a[j][j] = 1.0e-20;
		
		if(j != size-1) {
			dum = 1.0/(a[j][j]);
			for(i=j+1;i<size;i++)
				a[i][j] *= dum;
		}
	}
}

OGLFloat4x4 inverse(OGLFloat4x4 m)
{
	float	tmp[12];
	float	src[16];
	float	dst[16];
	
	for (int i = 0; i < 4; ++i) {
		src[i]		= m.mat[i][0];
		src[i+4]	= m.mat[i][1];
		src[i+8]	= m.mat[i][2];
		src[i+12]	= m.mat[i][3];
	}
	
	// calculate pairs for first 8 elements (cofactors)
	tmp[0] = src[10] * src[15];
	tmp[1] = src[11] * src[14];
	tmp[2] = src[9] * src[15];
	tmp[3] = src[11] * src[13];
	tmp[4] = src[9] * src[14];
	tmp[5] = src[10] * src[13];
	tmp[6] = src[8] * src[15];
	tmp[7] = src[11] * src[12];
	tmp[8] = src[8] * src[14];
	tmp[9] = src[10] * src[12];
	tmp[10] = src[8] * src[13];
	tmp[11] = src[9] * src[12];
	
	// calculate first 8 elements (cofactors)
	dst[0] = tmp[0]*src[5] + tmp[3]*src[6] + tmp[4]*src[7];
	dst[0] -= tmp[1]*src[5] + tmp[2]*src[6] + tmp[5]*src[7];
	dst[1] = tmp[1]*src[4] + tmp[6]*src[6] + tmp[9]*src[7];
	dst[1] -= tmp[0]*src[4] + tmp[7]*src[6] + tmp[8]*src[7];
	dst[2] = tmp[2]*src[4] + tmp[7]*src[5] + tmp[10]*src[7];
	dst[2] -= tmp[3]*src[4] + tmp[6]*src[5] + tmp[11]*src[7];
	dst[3] = tmp[5]*src[4] + tmp[8]*src[5] + tmp[11]*src[6];
	dst[3] -= tmp[4]*src[4] + tmp[9]*src[5] + tmp[10]*src[6];
	dst[4] = tmp[1]*src[1] + tmp[2]*src[2] + tmp[5]*src[3];
	dst[4] -= tmp[0]*src[1] + tmp[3]*src[2] + tmp[4]*src[3];
	dst[5] = tmp[0]*src[0] + tmp[7]*src[2] + tmp[8]*src[3];
	dst[5] -= tmp[1]*src[0] + tmp[6]*src[2] + tmp[9]*src[3];
	dst[6] = tmp[3]*src[0] + tmp[6]*src[1] + tmp[11]*src[3];
	dst[6] -= tmp[2]*src[0] + tmp[7]*src[1] + tmp[10]*src[3];
	dst[7] = tmp[4]*src[0] + tmp[9]*src[1] + tmp[10]*src[2];
	dst[7] -= tmp[5]*src[0] + tmp[8]*src[1] + tmp[11]*src[2];
	
	// calculate pairs for second 8 elements (cofactors)
	tmp[0] = src[2]*src[7];
	tmp[1] = src[3]*src[6];
	tmp[2] = src[1]*src[7];
	tmp[3] = src[3]*src[5];
	tmp[4] = src[1]*src[6];
	tmp[5] = src[2]*src[5];
	tmp[6] = src[0]*src[7];
	tmp[7] = src[3]*src[4];
	tmp[8] = src[0]*src[6];
	tmp[9] = src[2]*src[4];
	tmp[10] = src[0]*src[5];
	tmp[11] = src[1]*src[4];
	
	// calculate second 8 elements (cofactors)
	dst[8] = tmp[0]*src[13] + tmp[3]*src[14] + tmp[4]*src[15];
	dst[8] -= tmp[1]*src[13] + tmp[2]*src[14] + tmp[5]*src[15];
	dst[9] = tmp[1]*src[12] + tmp[6]*src[14] + tmp[9]*src[15];
	dst[9] -= tmp[0]*src[12] + tmp[7]*src[14] + tmp[8]*src[15];
	dst[10] = tmp[2]*src[12] + tmp[7]*src[13] + tmp[10]*src[15];
	dst[10]-= tmp[3]*src[12] + tmp[6]*src[13] + tmp[11]*src[15];
	dst[11] = tmp[5]*src[12] + tmp[8]*src[13] + tmp[11]*src[14];
	dst[11]-= tmp[4]*src[12] + tmp[9]*src[13] + tmp[10]*src[14];
	dst[12] = tmp[2]*src[10] + tmp[5]*src[11] + tmp[1]*src[9];
	dst[12]-= tmp[4]*src[11] + tmp[0]*src[9] + tmp[3]*src[10];
	dst[13] = tmp[8]*src[11] + tmp[0]*src[8] + tmp[7]*src[10];
	dst[13]-= tmp[6]*src[10] + tmp[9]*src[11] + tmp[1]*src[8];
	dst[14] = tmp[6]*src[9] + tmp[11]*src[11] + tmp[3]*src[8];
	dst[14]-= tmp[10]*src[11] + tmp[2]*src[8] + tmp[7]*src[9];
	dst[15] = tmp[10]*src[10] + tmp[4]*src[8] + tmp[9]*src[9];
	dst[15]-= tmp[8]*src[9] + tmp[11]*src[10] + tmp[5]*src[8];
	
	// calculate determinant
	float det=src[0]*dst[0]+src[1]*dst[1]+src[2]*dst[2]+src[3]*dst[3];
	
	// calculate matrix inverse
	det = 1/det;
	for (int j = 0; j < 16; j++)
		dst[j] *= det;
	
	OGLFloat4x4 r;
	for (int i = 0; i < 4; ++i) {
		r.mat[i][0] = dst[i];
		r.mat[i][1] = dst[i+4];
		r.mat[i][2] = dst[i+8];
		r.mat[i][3] = dst[i+12];
	}
	
	return r;
}

OGLRay multRay(OGLRay r, OGLFloat4x4 m)
{
	OGLFloat3 o = multVec3(m, r.origin);
	OGLFloat4 d = multVec4(m, OGLFloat4Make(r.direction.x, r.direction.y, r.direction.z, 0));
	return OGLRayMake(o, normalVec3(OGLFloat3Make(d.x, d.y, d.z)));
}

BOOL cubeRayInersect(OGLBox cube, OGLRay ray, OGLFloat3* hitLocation)
{
	enum { q_left = -1, q_middle = 0, q_right };
	
	float rorig[3] = {ray.origin.x, ray.origin.y, ray.origin.z};
	float rdir[3] = {ray.direction.x, ray.direction.y, ray.direction.z};
	float maxc[3] = {cube.maxc.x, cube.maxc.y, cube.maxc.z};
	float minc[3] = {cube.minc.x, cube.minc.y, cube.minc.z};
	
	int quad[3];
	float cplane[3];
	BOOL inside = YES;
	for(int i=0;i<3;++i)
	{
		if(rorig[i] < minc[i])
		{
			quad[i] = q_left;
			cplane[i] = minc[i];
			inside = NO;
		}
		else if(rorig[i] > maxc[i])
		{
			quad[i] = q_right;
			cplane[i] = maxc[i];
			inside = NO;
		}
		else
		{
			quad[i] = q_middle;
		}
	}
	
	if(inside)
	{
		*hitLocation = ray.origin;
		return YES;
	}
	
	float max_t[3];
	for(int i=0;i<3;++i)
	{
		if(quad[i] != q_middle && rdir[i] != 0.)
			max_t[i] = (cplane[i] - rorig[i]) / rdir[i];
		else
			max_t[i] = -1;
	}
	
	int which_plane = 0;
	for(int i=1;i<3;++i)
		if(max_t[which_plane] < max_t[i])
			which_plane = i;
	
	if(max_t[which_plane] < 0.)
		return NO;
	
	float coord[3];
	for(int i=0;i<3;++i)
	{
		if(which_plane != i)
		{
			coord[i] = rorig[i] + max_t[which_plane] * rdir[i];
			if(coord[i] < minc[i] || coord[i] > maxc[i])
				return NO;
		}
		else
			coord[i] = cplane[i];
	}
	
	*hitLocation = OGLFloat3Make(coord[0], coord[1], coord[2]);
	
	return YES;
}
