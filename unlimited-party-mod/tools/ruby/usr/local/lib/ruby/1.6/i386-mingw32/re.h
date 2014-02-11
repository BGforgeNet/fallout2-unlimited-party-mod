/**********************************************************************

  re.h -

  $Author: matz $
  $Date: 2000/05/30 04:24:03 $
  created at: Thu Sep 30 14:18:32 JST 1993

  Copyright (C) 1993-2000 Yukihiro Matsumoto

**********************************************************************/

#ifndef RE_H
#define RE_H

#include <sys/types.h>
#include <stdio.h>

#include "regex.h"

typedef struct re_pattern_buffer Regexp;

struct RMatch {
    struct RBasic basic;
    VALUE str;
    struct re_registers *regs;
};

#define RMATCH(obj)  (R_CAST(RMatch)(obj))

int rb_str_cicmp _((VALUE, VALUE));
VALUE rb_reg_regcomp _((VALUE));
int rb_reg_search _((VALUE, VALUE, int, int));
VALUE rb_reg_regsub _((VALUE, VALUE, struct re_registers *));
int rb_reg_adjust_startpos _((VALUE, VALUE, int, int));

int rb_kcode _((void));
void rb_match_busy _((VALUE));

EXTERN int ruby_ignorecase;

int rb_reg_mbclen2 _((unsigned int, VALUE));
#define mbclen2(c,re) rb_reg_mbclen2((c),(re))
#endif
