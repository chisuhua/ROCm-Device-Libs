
#include "mathF.h"

extern float MATH_PRIVATE(sincosb)(float, int, __private float *);
extern float MATH_PRIVATE(pzero)(float);
extern float MATH_PRIVATE(qzero)(float);

// This implementation makes use of large x approximations from
// the Sun library which reqires the following to be included:
/*
 * ====================================================
 * Copyright (C) 1993 by Sun Microsystems, Inc. All rights reserved.
 *
 * Developed at SunPro, a Sun Microsystems, Inc. business.
 * Permission to use, copy, modify, and distribute this
 * software is freely granted, provided that this notice
 * is preserved.
 * ====================================================
 */

float
MATH_MANGLE(j0)(float x)
{
    x = BUILTIN_ABS_F32(x);

    const float b0 = 1.65625f;
    const float b1 = 3.125f;
    const float b2 = 4.6875f;
    const float b3 = 6.265625f;
    const float b4 = 7.84375f;
    const float b5 = 9.421875f;
    const float b6 = 10.984375f;
    const float b7 = 12.578125f;

    float ret;

    if (x <= b7) {
        // Ty to maintain relative accuracy here

        USE_TABLE(float, p, M32_J0);
        float ch, cl;

        if (x <= b3) {
            if (x <= b0) {
                ch = 0x0.000000p+0f;
                cl = 0x0.000000p+0f;
            } else if (x <= b1) {
                ch = 0x1.33d152p+1f;
                cl = 0x1.d2e368p-24f;
                p += 1*9;
            } else if (x <= b2) {
                ch = 0x1.ea7558p+1f;
                cl = -0x1.4a121ep-24f;
                p += 2*9;
            } else {
                ch = 0x1.6148f6p+2f;
                cl = -0x1.34f46ep-24f;
                p += 3*9;
            }
        } else {
            if (x <= b4) {
                ch = 0x1.c0ff60p+2f;
                cl = -0x1.8971b6p-23f;
                p += 4*9;
            } else if (x <= b5) {
                ch = 0x1.14eb56p+3f;
                cl = 0x1.999bdap-22f;
                p += 5*9;
            } else if (x <= b6) {
                ch = 0x1.458d0ep+3f;
                cl = -0x1.e8407ap-22f;
                p += 6*9;
            } else {
                ch = 0x1.795440p+3f;
                cl = 0x1.04e56cp-26f;
                p += 7*9;
            }
        }

        x = x - ch - cl;
        ret = MATH_MAD(x, MATH_MAD(x, MATH_MAD(x, MATH_MAD(x,
              MATH_MAD(x, MATH_MAD(x, MATH_MAD(x, MATH_MAD(x,
              p[8],  p[7]), p[6]), p[5]), p[4]),
              p[3]), p[2]), p[1]), p[0]);
    } else {
        // j0(x) ~ sqrt(2 / (pi*x)) * (P0(x) cos(x-pi/4) - Q0(x) sin(x-pi/4))
        float c;
        float s = MATH_PRIVATE(sincosb)(x, 0, &c);
        const float sqrt2bypi = 0x1.988454p-1f;
        if (x > 0x1.0p+17f)
            ret = MATH_DIV(sqrt2bypi * c, MATH_SQRT(x));
        else
            ret = MATH_DIV(sqrt2bypi * (MATH_PRIVATE(pzero)(x)*c - MATH_PRIVATE(qzero)(x)*s), MATH_SQRT(x));
        ret = BUILTIN_CLASS_F32(x, CLASS_PINF) ? 0.0f : ret;
    }

    return ret;
}
