///
///  OGLEngine
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

#import "OGLEngine.h"

const float	c_pi						= 3.141592653589793238462643383279502884197f;
const float	c_pi_recip					= 1.0f / c_pi;
const float	c_quarter_pi				= c_pi * 0.25f;
const float	c_half_pi					= c_pi * 0.5f;
const float	c_deg						= 180.0f / c_pi;
const float	c_rad						= c_pi / 180.0f;

CGFloat3 CGFloat3Make(CGFloat x, CGFloat y, CGFloat z)
{
	CGFloat3 value = {x, y, z};
	return value;
}

CGFloat4 CGFloat4Make(CGFloat x, CGFloat y, CGFloat z, CGFloat w)
{
	CGFloat4 value = {x, y, z, w};
	return value;
}

CGPlane CGPlaneMake(CGFloat a, CGFloat b, CGFloat c, CGFloat d)
{
	CGPlane value = {a, b, c, d};
	return value;
}

CGPlane CGPlaneNormalize(CGPlane p)
{
	CGFloat inv = 1 / sqrt(p.a*p.a + p.b*p.b + p.c*p.c);
	
	CGPlane value;
	value.a = p.a * inv;
	value.b = p.b * inv;
	value.c = p.c * inv;
	value.d = p.d * inv;
	return value;
}

CGFloat3 normalVec3(CGFloat3 v)
{
	CGFloat inv = 1 / sqrt(v.x*v.x + v.y*v.y + v.z*v.z);
	
	CGFloat3 value;
	value.x = v.x * inv;
	value.y = v.y * inv;
	value.z = v.z * inv;
	return value;
}

CGQuaternion CGQuaternionMake(CGFloat angle, CGFloat3 axis)
{
	CGQuaternion value;
	CGFloat ang = angle * 0.5;
	CGFloat s = sin(ang);
	value.w = cos(ang);
	value.x = s * axis.x;
	value.y = s * axis.y;
	value.z = s * axis.z;
	return value;
}

CGFrustum CGFrustumMake(CGFloat4x4 mvp)
{
	CGFrustum value;
	
	// left & right planes
	value.plane[0] = CGPlaneMake(mvp.mat[3][0] + mvp.mat[0][0], mvp.mat[3][1] + mvp.mat[0][1], mvp.mat[3][2] + mvp.mat[0][2], mvp.mat[3][3] - mvp.mat[0][3]);
	value.plane[1] = CGPlaneMake(mvp.mat[3][0] - mvp.mat[0][0], mvp.mat[3][1] - mvp.mat[0][1], mvp.mat[3][2] - mvp.mat[0][2], mvp.mat[3][3] - mvp.mat[0][3]);
	value.plane[0] = CGPlaneNormalize(value.plane[0]);
	value.plane[1] = CGPlaneNormalize(value.plane[1]);
	
	// top & bottom planes
	value.plane[2] = CGPlaneMake(mvp.mat[3][0] - mvp.mat[1][0], mvp.mat[3][1] - mvp.mat[1][1], mvp.mat[3][2] - mvp.mat[1][2], mvp.mat[3][3] - mvp.mat[1][3]);
	value.plane[3] = CGPlaneMake(mvp.mat[3][0] + mvp.mat[1][0], mvp.mat[3][1] + mvp.mat[1][1], mvp.mat[3][2] + mvp.mat[1][2], mvp.mat[3][3] + mvp.mat[1][3]);
	value.plane[2] = CGPlaneNormalize(value.plane[2]);
	value.plane[3] = CGPlaneNormalize(value.plane[3]);
	
	// near & far planes
	value.plane[4] = CGPlaneMake(mvp.mat[3][0] + mvp.mat[2][0], mvp.mat[3][1] + mvp.mat[2][1], mvp.mat[3][2] + mvp.mat[2][2], mvp.mat[3][3] + mvp.mat[2][3]);
	value.plane[5] = CGPlaneMake(mvp.mat[3][0] - mvp.mat[2][0], mvp.mat[3][1] - mvp.mat[2][1], mvp.mat[3][2] - mvp.mat[2][2], mvp.mat[3][3] - mvp.mat[2][3]);
	value.plane[4] = CGPlaneNormalize(value.plane[4]);
	value.plane[5] = CGPlaneNormalize(value.plane[5]);
	
	return value;
}

CGRay CGRayMake(CGFloat3 origin, CGFloat3 direction)
{
	CGRay value;
	value.origin = origin;
	value.direction = direction;
	return value;
}

CGFloat4x4 identity4x4()
{
	CGFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(CGFloat));
	value.mat[0][0] = value.mat[1][1] = value.mat[2][2], value.mat[3][3] = 1;
	return value;
}

CGFloat4x4 scale4x4(CGFloat x, CGFloat y, CGFloat z)
{
	CGFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(CGFloat));
	value.mat[0][0] = x;
	value.mat[1][1] = y;
	value.mat[2][2] = z;
	value.mat[3][3] = 1;
	return value;
}


CGFloat4x4 translation4x4(CGFloat x, CGFloat y, CGFloat z)
{
	CGFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(CGFloat));
	value.mat[0][0] = value.mat[1][1] = value.mat[2][2], value.mat[3][3] = 1;
	value.mat[3][0] = x;
	value.mat[3][1] = y;
	value.mat[3][2] = z;
	return value;
}

CGFloat4x4 rotation4x4(CGFloat angle, CGFloat3 axis)
{
	CGQuaternion q = CGQuaternionMake(angle, axis);
	CGFloat x2 = q.x + q.x, y2 = q.y + q.y, z2 = q.z + q.z;
	CGFloat xx = q.x * x2, xy = q.x * y2, xz = q.x * z2;
	CGFloat yy = q.y * y2, yz = q.y * z2, zz = q.z * z2;
	CGFloat wx = q.w * x2, wy = q.w * y2, wz = q.w * z2;
	
	CGFloat4x4 value;
	value.mat[0][0] = 1-(yy+zz);	value.mat[1][0] = xy+wz;		value.mat[2][0] = xz-wy;		value.mat[3][0] = 0.0;
	value.mat[0][1] = xy-wz;		value.mat[1][1] = 1-(xx+zz);	value.mat[2][1] = yz+wx;		value.mat[3][1] = 0.0;
	value.mat[0][2] = xz+wy;		value.mat[1][2] = yz-wx;		value.mat[2][2] = 1-(xx+yy);	value.mat[3][2] = 0.0;
	value.mat[0][3] = 0.0;			value.mat[1][3] = 0.0;			value.mat[2][3] = 0.0;			value.mat[3][3] = 1.0;
	return value;
}

CGFloat4x4 orthographic4x4(CGFloat left, CGFloat right, CGFloat bottom, CGFloat top, CGFloat znear, CGFloat zfar)
{
	CGFloat4x4 value;
	
	CGFloat rml = right - left;
	CGFloat tmb = top - bottom;
	CGFloat fmn = zfar - znear;
	memset(value.mat, 0, 16 * sizeof(CGFloat));
	
	value.mat[0][0] = 2/rml;
	value.mat[1][1] = 2/tmb;
	value.mat[2][2] = 2/fmn;
	value.mat[3][0] = -(right + left)/rml;
	value.mat[3][1] = -(top + bottom)/tmb;
	value.mat[3][2] = -(zfar + znear)/fmn;
	value.mat[3][3] = 1;
	
	return value;
}

CGFloat4x4 perspective4x4(CGFloat fov, CGFloat aspect, CGFloat near, CGFloat far)
{
	CGFloat f = 1.0 / tan(fov * 0.5 * c_rad);
	CGFloat n = 1.0 / (near - far);
	
	CGFloat4x4 value;
	memset(value.mat, 0, 16 * sizeof(CGFloat));
	value.mat[0][0] = f/aspect;
	value.mat[1][1] = f;
	value.mat[2][2] = (far+near)*n;
	value.mat[2][3] = -1;
	value.mat[3][2] = 2*far*near*n;
	return value;
}

CGFloat4x4 look_toward4x4(CGFloat3 forward, CGFloat3 up)
{
	CGFloat3 side = cross(forward, up);
	CGFloat3 nup = cross(side, forward);
	
	CGFloat4x4 value;
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



CGFloat length3(CGFloat3 a)
{
	return sqrt(a.x*a.x + a.y*a.y + a.z*a.z);
}

CGFloat3 cross(CGFloat3 a, CGFloat3 b)
{
	return CGFloat3Make(a.y*b.z-a.z*b.y, a.z*b.x-a.x*b.z, a.x*b.y-a.y*b.x);
}



CGFloat4x4 mult(CGFloat4x4 a, CGFloat4x4 b)
{
	CGFloat4x4 ret;
	
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

CGFloat3 multVec3(CGFloat4x4 m, CGFloat3 a)
{
	CGFloat3 value;
	value.x = m.mat[0][0]*a.x + m.mat[1][0]*a.y + m.mat[2][0]*a.z + m.mat[3][0];
	value.y = m.mat[0][1]*a.x + m.mat[1][1]*a.y + m.mat[2][1]*a.z + m.mat[3][1];
	value.z = m.mat[0][2]*a.x + m.mat[1][2]*a.y + m.mat[2][2]*a.z + m.mat[3][2];
	return value;
}

CGFloat4 multVec4(CGFloat4x4 m, CGFloat4 v)
{
	CGFloat4 value;
	value.x = m.mat[0][0]*v.x + m.mat[1][0]*v.y + m.mat[2][0]*v.z + m.mat[3][0]*v.w;
	value.y = m.mat[0][1]*v.x + m.mat[1][1]*v.y + m.mat[2][1]*v.z + m.mat[3][1]*v.w;
	value.z = m.mat[0][2]*v.x + m.mat[1][2]*v.y + m.mat[2][2]*v.z + m.mat[3][2]*v.w;
	value.w = m.mat[0][3]*v.x + m.mat[1][3]*v.y + m.mat[2][3]*v.z + m.mat[3][3]*v.w;
	return value;
}

CGRect multRect(CGFloat4x4 m, CGRect r)
{
	CGRect value;
	value.origin.x = m.mat[0][0]*r.origin.x + m.mat[1][0]*r.origin.y + m.mat[3][0];
	value.origin.y = m.mat[0][1]*r.origin.x + m.mat[1][1]*r.origin.y + m.mat[3][1];
	value.size.width = m.mat[0][0]*r.size.width + m.mat[1][0]*r.size.height;
	value.size.height = m.mat[0][1]*r.size.width + m.mat[1][1]*r.size.height;
	return value;
}



void ludcmp(CGFloat4x4* m, CGFloat** a, int indx[], CGFloat *d, int size)
{
	int	i, imax, j, k;
	CGFloat	big, dum, sum, temp, vv[8];
	
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

CGFloat4x4 inverse(CGFloat4x4 m)
{
	CGFloat	tmp[12];
	CGFloat	src[16];
	CGFloat	dst[16];
	
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
	CGFloat det=src[0]*dst[0]+src[1]*dst[1]+src[2]*dst[2]+src[3]*dst[3];
	
	// calculate matrix inverse
	det = 1/det;
	for (int j = 0; j < 16; j++)
		dst[j] *= det;
	
	CGFloat4x4 r;
	for (int i = 0; i < 4; ++i) {
		r.mat[i][0] = dst[i];
		r.mat[i][1] = dst[i+4];
		r.mat[i][2] = dst[i+8];
		r.mat[i][3] = dst[i+12];
	}
	
	return r;
}

CGRay multRay(CGRay r, CGFloat4x4 m)
{
	CGFloat3 o = multVec3(m, r.origin);
	CGFloat4 d = multVec4(m, CGFloat4Make(r.direction.x, r.direction.y, r.direction.z, 0));
	return CGRayMake(o, normalVec3(CGFloat3Make(d.x, d.y, d.z)));
}

