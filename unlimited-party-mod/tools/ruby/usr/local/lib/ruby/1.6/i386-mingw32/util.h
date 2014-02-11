/**********************************************************************

  util.h -

  $Author: matz $
  $Date: 2002/12/02 18:19:04 $
  created at: Thu Mar  9 11:55:53 JST 1995

  Copyright (C) 1993-2000 Yukihiro Matsumoto

**********************************************************************/

#ifndef UTIL_H
#define UTIL_H

#ifndef _
#ifdef __cplusplus
# ifndef  HAVE_PROTOTYPES
#  define HAVE_PROTOTYPES 1
# endif
# ifndef  HAVE_STDARG_PROTOTYPES
#  define HAVE_STDARG_PROTOTYPES 1
# endif
#endif
#ifdef HAVE_PROTOTYPES
# define _(args) args
#else
# define _(args) ()
#endif
#ifdef HAVE_STDARG_PROTOTYPES
# define __(args) args
#else
# define __(args) ()
#endif
#endif

#define scan_oct ruby_scan_oct
unsigned long scan_oct _((const char*, int, int*));
#define scan_hex ruby_scan_hex
unsigned long scan_hex _((const char*, int, int*));

#if defined(MSDOS) || defined(__CYGWIN32__) || defined(NT)
void ruby_add_suffix();
#define add_suffix ruby_add_suffix
#endif

void ruby_qsort _((void*, int, int, int (*)()));
#define qsort(b,n,s,c) ruby_qsort(b,n,s,c)

void ruby_setenv _((const char*, const char*));
void ruby_unsetenv _((const char*));
#undef setenv
#undef unsetenv
#define setenv(name,val) ruby_setenv((name),(val))
#define unsetenv(name,val) ruby_unsetenv((name));

char *ruby_strdup _((const char*));
#undef strdup
#define strdup(s) ruby_strdup((s))

double ruby_strtod _((const char*, char **));
#define strtod(s,e) ruby_strtod((s),(e))

#endif /* UTIL_H */
