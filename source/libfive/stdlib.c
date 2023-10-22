// See `dflags` in dub.json for C preprocessor flags:
// -I subprojects/libfive/libfive/include
// -I subprojects/libfive/libfive/stdlib
// FIXME: This was fixed by https://github.com/dlang/dmd/pull/15640
#define __signed signed
#include "libfive_stdlib.h"
