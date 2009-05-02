#ifndef _DIZZY_GLOBAL_H
#define _DIZZY_GLOBAL_H

#define _XOPEN_SOURCE 500

#ifdef __clang__
	#define __NO_INLINE__ 1
#endif
#include <math.h>
#include <stdlib.h>
#include <stdint.h>
#ifdef __clang__
	#undef __NO_INLINE__
#endif

#endif

