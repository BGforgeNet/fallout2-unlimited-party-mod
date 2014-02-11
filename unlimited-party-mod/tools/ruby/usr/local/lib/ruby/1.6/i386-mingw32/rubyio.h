/**********************************************************************

  rubyio.h -

  $Author: nobu $
  $Date: 2003/01/09 08:05:23 $
  created at: Fri Nov 12 16:47:09 JST 1993

  Copyright (C) 1993-2000 Yukihiro Matsumoto

**********************************************************************/

#ifndef RUBYIO_H
#define RUBYIO_H

#include <stdio.h>
#include <errno.h>

typedef struct OpenFile {
    FILE *f;			/* stdio ptr for read/write */
    FILE *f2;			/* additional ptr for rw pipes */
    int mode;			/* mode flags */
    int pid;			/* child's pid (for pipes) */
    int lineno;			/* number of lines read */
    char *path;			/* pathname for file */
    void (*finalize)();		/* finalize proc */
} OpenFile;

#define FMODE_READABLE  1
#define FMODE_WRITABLE  2
#define FMODE_READWRITE 3
#define FMODE_BINMODE   4
#define FMODE_SYNC      8
#define FMODE_WBUF     16
#define FMODE_RBUF     32

#define GetOpenFile(obj,fp) rb_io_check_closed((fp) = RFILE(rb_io_taint_check(obj))->fptr)

#define MakeOpenFile(obj, fp) do {\
    fp = 0;\
    fp = RFILE(obj)->fptr = ALLOC(OpenFile);\
    fp->f = fp->f2 = NULL;\
    fp->mode = 0;\
    fp->pid = 0;\
    fp->lineno = 0;\
    fp->path = NULL;\
    fp->finalize = 0;\
} while (0)

#define GetReadFile(fptr) ((fptr)->f)
#define GetWriteFile(fptr) (((fptr)->f2) ? (fptr)->f2 : (fptr)->f)

FILE *rb_fopen _((const char*, const char*));
FILE *rb_fdopen _((int, const char*));
int rb_getc _((FILE*));
int  rb_io_mode_flags _((const char*));
void rb_io_check_writable _((OpenFile*));
void rb_io_check_readable _((OpenFile*));
void rb_io_fptr_finalize _((OpenFile*));
void rb_io_synchronized _((OpenFile*));
void rb_io_check_closed _((OpenFile*));

VALUE rb_io_taint_check _((VALUE));
void rb_eof_error _((void));

void rb_read_check _((FILE*));
int rb_read_pending _((FILE*));
#endif
