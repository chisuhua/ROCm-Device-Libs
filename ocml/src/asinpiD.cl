/*===--------------------------------------------------------------------------
 *                   ROCm Device Libraries
 *
 * This file is distributed under the University of Illinois Open Source
 * License. See LICENSE.TXT for details.
 *===------------------------------------------------------------------------*/

#include "mathD.h"

CONSTATTR double
MATH_MANGLE(asinpi)(double x)
{
    // Computes arcsin(x).
    // The argument is first reduced by noting that arcsin(x)
    // is invalid for abs(x) > 1 and arcsin(-x) = -arcsin(x).
    // For denormal and small arguments arcsin(x) = x to machine
    // accuracy. Remaining argument ranges are handled as follows.
    // For abs(x) <= 0.5 use
    // arcsin(x) = x + x^3*R(x^2)
    // where R(x^2) is a rational minimax approximation to
    // (arcsin(x) - x)/x^3.
    // For abs(x) > 0.5 exploit the identity:
    // arcsin(x) = pi/2 - 2*arcsin(sqrt(1-x)/2)
    // together with the above rational approximation, and
    // reconstruct the terms carefully.

    const double piinv = 0x1.45f306dc9c883p-2;

    double y = BUILTIN_ABS_F64(x);
    bool transform = y >= 0.5;

    double rt = MATH_MAD(y, -0.5, 0.5);
    double y2 = y * y;
    double r = transform ? rt : y2;

    double u = r * MATH_MAD(r, MATH_MAD(r, MATH_MAD(r, MATH_MAD(r, 
                   MATH_MAD(r, MATH_MAD(r, MATH_MAD(r, MATH_MAD(r, 
                   MATH_MAD(r, MATH_MAD(r, MATH_MAD(r, 
                       0x1.547a51d41fb0bp-7, -0x1.6a3fb0718a8f7p-8), 0x1.a7b91f7177ee8p-8), 0x1.035d3435b8ad8p-9),
                       0x1.ff0549b4e0449p-9), 0x1.21604ae288f96p-8), 0x1.6a2b36f9aec49p-8), 0x1.d2b076c914f04p-8),
                       0x1.3ce53861f8f1fp-7), 0x1.d1a4529a30a69p-7), 0x1.8723a1d61d2e9p-6), 0x1.b2995e7b7af0fp-5);

    double v;
    if (transform) {
        double s = MATH_FAST_SQRT(r);
        double sh = AS_DOUBLE(AS_ULONG(s) & 0xffffffff00000000UL);
        double st = MATH_FAST_DIV(MATH_MAD(-sh, sh, r), s + sh);
        double p = 2.0*MATH_MAD(s, u, piinv*st);
        double q = MATH_MAD(-2.0*piinv, sh, 0.25);
        v = 0.25 - (p - q);
        v = y == 1.0 ? 0.5 : v;
    } else {
        v = MATH_MAD(y, piinv, y*u);
    }

    return BUILTIN_COPYSIGN_F64(v, x);
}

