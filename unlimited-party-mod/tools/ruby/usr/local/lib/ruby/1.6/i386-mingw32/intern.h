/**********************************************************************

  intern.h -

  $Author: aamine $
  $Date: 2002/09/05 20:08:49 $
  created at: Thu Jun 10 14:22:17 JST 1993

  Copyright (C) 1993-2000 Yukihiro Matsumoto
  Copyright (C) 2000  Network Applied Communication Laboratory, Inc.
  Copyright (C) 2000  Information-technology Promotion Agency, Japan

**********************************************************************/

/* 
 * Functions and variables that are used by more than one source file of
 * the kernel.
 */

/* array.c */
void rb_mem_clear _((register VALUE*, register long));
VALUE rb_assoc_new _((VALUE, VALUE));
VALUE rb_ary_new _((void));
VALUE rb_ary_new2 _((long));
VALUE rb_ary_new3 __((long,...));
VALUE rb_ary_new4 _((long, VALUE *));
VALUE rb_ary_freeze _((VALUE));
VALUE rb_ary_aref _((int, VALUE*, VALUE));
void rb_ary_store _((VALUE, long, VALUE));
VALUE rb_ary_to_s _((VALUE));
VALUE rb_ary_push _((VALUE, VALUE));
VALUE rb_ary_pop _((VALUE));
VALUE rb_ary_shift _((VALUE));
VALUE rb_ary_unshift _((VALUE, VALUE));
VALUE rb_ary_entry _((VALUE, long));
VALUE rb_ary_each _((VALUE));
VALUE rb_ary_join _((VALUE, VALUE));
VALUE rb_ary_print_on _((VALUE, VALUE));
VALUE rb_ary_reverse _((VALUE));
VALUE rb_ary_sort _((VALUE));
int rb_cmpint _((VALUE));
VALUE rb_ary_sort_bang _((VALUE));
VALUE rb_ary_delete _((VALUE, VALUE));
VALUE rb_ary_delete_at _((VALUE, long));
VALUE rb_ary_clear _((VALUE));
VALUE rb_ary_plus _((VALUE, VALUE));
VALUE rb_ary_concat _((VALUE, VALUE));
VALUE rb_ary_assoc _((VALUE, VALUE));
VALUE rb_ary_rassoc _((VALUE, VALUE));
VALUE rb_ary_includes _((VALUE, VALUE));
VALUE rb_protect_inspect _((VALUE(*)(),VALUE,VALUE));
VALUE rb_inspecting_p _((VALUE));
/* bignum.c */
VALUE rb_big_clone _((VALUE));
void rb_big_2comp _((VALUE));
VALUE rb_big_norm _((VALUE));
VALUE rb_uint2big _((unsigned long));
VALUE rb_int2big _((long));
VALUE rb_uint2inum _((unsigned long));
VALUE rb_int2inum _((long));
VALUE rb_cstr2inum _((const char*, int));
VALUE rb_str2inum _((VALUE, int));
VALUE rb_big2str _((VALUE, int));
long rb_big2long _((VALUE));
#define rb_big2int(x) rb_big2long(x)
unsigned long rb_big2ulong _((VALUE));
#define rb_big2uint(x) rb_big2ulong(x)
VALUE rb_dbl2big _((double));
double rb_big2dbl _((VALUE));
VALUE rb_big_plus _((VALUE, VALUE));
VALUE rb_big_minus _((VALUE, VALUE));
VALUE rb_big_mul _((VALUE, VALUE));
VALUE rb_big_divmod _((VALUE, VALUE));
VALUE rb_big_pow _((VALUE, VALUE));
VALUE rb_big_and _((VALUE, VALUE));
VALUE rb_big_or _((VALUE, VALUE));
VALUE rb_big_xor _((VALUE, VALUE));
VALUE rb_big_lshift _((VALUE, VALUE));
VALUE rb_big_rand _((VALUE, double));
/* class.c */
VALUE rb_class_new _((VALUE));
VALUE rb_mod_clone _((VALUE));
VALUE rb_mod_dup _((VALUE));
VALUE rb_singleton_class_new _((VALUE));
VALUE rb_singleton_class_clone _((VALUE));
void rb_singleton_class_attached _((VALUE,VALUE));
VALUE rb_make_metaclass _((VALUE, VALUE));
VALUE rb_class_inherited _((VALUE, VALUE));
VALUE rb_define_class_id _((ID, VALUE));
VALUE rb_module_new _((void));
VALUE rb_define_module_id _((ID));
VALUE rb_mod_included_modules _((VALUE));
VALUE rb_mod_ancestors _((VALUE));
VALUE rb_class_instance_methods _((int, VALUE*, VALUE));
VALUE rb_class_protected_instance_methods _((int, VALUE*, VALUE));
VALUE rb_class_private_instance_methods _((int, VALUE*, VALUE));
VALUE rb_obj_singleton_methods _((VALUE));
void rb_define_method_id _((VALUE, ID, VALUE (*)(ANYARGS), int));
void rb_frozen_class_p _((VALUE));
void rb_undef _((VALUE, ID));
void rb_define_protected_method _((VALUE, const char*, VALUE (*)(ANYARGS), int));
void rb_define_private_method _((VALUE, const char*, VALUE (*)(ANYARGS), int));
void rb_define_singleton_method _((VALUE,const char*,VALUE(*)(ANYARGS),int));
void rb_define_private_method _((VALUE,const char*,VALUE(*)(ANYARGS),int));
VALUE rb_singleton_class _((VALUE));
/* enum.c */
VALUE rb_enum_length _((VALUE));
/* error.c */
EXTERN int ruby_nerrs;
VALUE rb_exc_new _((VALUE, const char*, long));
VALUE rb_exc_new2 _((VALUE, const char*));
VALUE rb_exc_new3 _((VALUE, VALUE));
void rb_loaderror __((const char*, ...)) NORETURN;
void rb_compile_error __((const char*, ...));
void rb_compile_error_append __((const char*, ...));
void rb_load_fail _((char*)) NORETURN;
void rb_error_frozen _((char*)) NORETURN;
/* eval.c */
void rb_exc_raise _((VALUE)) NORETURN;
void rb_exc_fatal _((VALUE)) NORETURN;
void rb_stack_check _((void));
void rb_remove_method _((VALUE, const char*));
void rb_disable_super _((VALUE, const char*));
void rb_enable_super _((VALUE, const char*));
void rb_clear_cache _((void));
void rb_alias _((VALUE, ID, ID));
void rb_attr _((VALUE,ID,int,int,int));
int rb_method_boundp _((VALUE, ID, int));
VALUE rb_dvar_defined _((ID));
VALUE rb_dvar_curr _((ID));
VALUE rb_dvar_ref _((ID));
void rb_dvar_asgn _((ID, VALUE));
void rb_dvar_push _((ID, VALUE));
VALUE rb_eval_cmd _((VALUE, VALUE));
int rb_respond_to _((VALUE, ID));
void rb_interrupt _((void));
VALUE rb_apply _((VALUE, ID, VALUE));
void rb_backtrace _((void));
ID rb_frame_last_func _((void));
VALUE rb_obj_instance_eval _((int, VALUE*, VALUE));
void rb_load _((VALUE, int));
void rb_load_protect _((VALUE, int, int*));
void rb_jump_tag _((int)) NORETURN;
int rb_provided _((const char*));
void rb_provide _((const char*));
VALUE rb_f_require _((VALUE, VALUE));
void rb_obj_call_init _((VALUE, int, VALUE*));
VALUE rb_class_new_instance _((int, VALUE*, VALUE));
VALUE rb_f_lambda _((void));
VALUE rb_protect _((VALUE (*)(), VALUE, int*));
void rb_set_end_proc _((void (*)(), VALUE));
void rb_mark_end_proc _((void));
void rb_exec_end_proc _((void));
void ruby_finalize _((void));
void ruby_stop _((int));
void rb_gc_mark_threads _((void));
void rb_thread_start_timer _((void));
void rb_thread_stop_timer _((void));
void rb_thread_schedule _((void));
void rb_thread_wait_fd _((int));
int rb_thread_fd_writable _((int));
void rb_thread_fd_close _((int));
int rb_thread_alone _((void));
void rb_thread_polling _((void));
void rb_thread_sleep _((int));
void rb_thread_sleep_forever _((void));
VALUE rb_thread_stop _((void));
VALUE rb_thread_wakeup _((VALUE));
VALUE rb_thread_run _((VALUE));
VALUE rb_thread_create _((VALUE (*)(ANYARGS), void*));
int rb_thread_scope_shared_p _((void));
void rb_thread_interrupt _((void));
void rb_thread_trap_eval _((VALUE, int));
void rb_thread_signal_raise _((char*));
int rb_thread_select(ANYARGS);
void rb_thread_wait_for(ANYARGS);
VALUE rb_thread_current _((void));
VALUE rb_thread_main _((void));
VALUE rb_thread_local_aref _((VALUE, ID));
VALUE rb_thread_local_aset _((VALUE, ID, VALUE));
void rb_thread_atfork _((void));
/* file.c */
int eaccess _((const char*, int));
VALUE rb_file_s_expand_path _((int, VALUE *));
void rb_file_const _((const char*, VALUE));
int rb_find_file_ext _((VALUE*, const char* const*));
VALUE rb_find_file _((VALUE));
/* gc.c */
void rb_gc_mark_locations _((VALUE*, VALUE*));
void rb_mark_tbl _((struct st_table*));
void rb_mark_hash _((struct st_table*));
void rb_gc_mark_maybe _((VALUE));
void rb_gc_mark _((VALUE));
void rb_gc_force_recycle _((VALUE));
void rb_gc _((void));
char *rb_source_filename _((const char *));
void rb_gc_call_finalizer_at_exit _((void));
/* hash.c */
VALUE rb_hash _((VALUE));
VALUE rb_hash_new _((void));
VALUE rb_hash_freeze _((VALUE));
VALUE rb_hash_aref _((VALUE, VALUE));
VALUE rb_hash_aset _((VALUE, VALUE, VALUE));
VALUE rb_hash_delete_if _((VALUE));
int rb_path_check _((char *));
int rb_env_path_tainted _((void));
/* io.c */
EXTERN VALUE rb_fs;
EXTERN VALUE rb_output_fs;
EXTERN VALUE rb_rs;
EXTERN VALUE rb_default_rs;
EXTERN VALUE rb_output_rs;
VALUE rb_io_write _((VALUE, VALUE));
VALUE rb_io_gets _((VALUE));
VALUE rb_io_getc _((VALUE));
VALUE rb_io_ungetc _((VALUE, VALUE));
VALUE rb_io_close _((VALUE));
VALUE rb_io_eof _((VALUE));
VALUE rb_io_binmode _((VALUE));
VALUE rb_io_addstr _((VALUE, VALUE));
VALUE rb_io_printf _((int, VALUE*, VALUE));
VALUE rb_io_print _((int, VALUE*, VALUE));
VALUE rb_io_puts _((int, VALUE*, VALUE));
VALUE rb_file_open _((const char*, const char*));
VALUE rb_gets _((void));
/* numeric.c */
void rb_num_zerodiv _((void));
VALUE rb_num_coerce_bin _((VALUE, VALUE));
VALUE rb_float_new _((double));
VALUE rb_num2fix _((VALUE));
VALUE rb_fix2str _((VALUE, int));
VALUE rb_fix_upto _((VALUE, VALUE));
/* object.c */
int rb_eql _((VALUE, VALUE));
VALUE rb_any_to_s _((VALUE));
VALUE rb_inspect _((VALUE));
VALUE rb_obj_is_instance_of _((VALUE, VALUE));
VALUE rb_obj_is_kind_of _((VALUE, VALUE));
VALUE rb_obj_alloc _((VALUE));
VALUE rb_obj_clone _((VALUE));
VALUE rb_obj_dup _((VALUE));
VALUE rb_obj_taint _((VALUE));
VALUE rb_obj_tainted _((VALUE));
VALUE rb_obj_untaint _((VALUE));
VALUE rb_obj_freeze _((VALUE));
VALUE rb_obj_id _((VALUE));
VALUE rb_class_real _((VALUE));
VALUE rb_obj_class _((VALUE));
VALUE rb_convert_type _((VALUE,int,const char*,const char*));
VALUE rb_check_convert_type _((VALUE,int,const char*,const char*));
VALUE rb_to_int _((VALUE));
VALUE rb_Integer _((VALUE));
VALUE rb_Float _((VALUE));
VALUE rb_String _((VALUE));
VALUE rb_Array _((VALUE));
/* parse.y */
EXTERN int   ruby_sourceline;
EXTERN char *ruby_sourcefile;
#define yyparse rb_yyparse
#define yylex rb_yylex
#define yyerror rb_yyerror
#define yylval rb_yylval
#define yychar rb_yychar
#define yydebug rb_yydebug
int yyparse _((void));
ID rb_id_attrset _((ID));
void rb_parser_append_print _((void));
void rb_parser_while_loop _((int, int));
int ruby_parser_stack_on_heap _((void));
void rb_gc_mark_parser _((void));
int rb_is_const_id _((ID));
int rb_is_instance_id _((ID));
int rb_is_class_id _((ID));
VALUE rb_backref_get _((void));
void rb_backref_set _((VALUE));
VALUE rb_lastline_get _((void));
void rb_lastline_set _((VALUE));
/* process.c */
int rb_proc_exec _((const char*));
void rb_syswait _((int));
/* range.c */
VALUE rb_range_new _((VALUE, VALUE, int));
VALUE rb_range_beg_len _((VALUE, long*, long*, long, int));
VALUE rb_length_by_each _((VALUE));
/* re.c */
int rb_memcmp _((char*,char*,long));
VALUE rb_reg_nth_defined _((int, VALUE));
VALUE rb_reg_nth_match _((int, VALUE));
VALUE rb_reg_last_match _((VALUE));
VALUE rb_reg_match_pre _((VALUE));
VALUE rb_reg_match_post _((VALUE));
VALUE rb_reg_match_last _((VALUE));
VALUE rb_reg_new _((const char*, long, int));
VALUE rb_reg_match _((VALUE, VALUE));
VALUE rb_reg_match2 _((VALUE));
int rb_reg_options _((VALUE));
void rb_set_kcode _((const char*));
const char* rb_get_kcode _((void));
/* ruby.c */
EXTERN VALUE rb_argv;
EXTERN VALUE rb_argv0;
void rb_load_file _((char*));
void ruby_script _((char*));
void ruby_prog_init _((void));
void ruby_set_argv _((int, char**));
void ruby_process_options _((int, char**));
void ruby_load_script _((void));
void ruby_init_loadpath _((void));
void ruby_incpush _((const char*));
/* signal.c */
VALUE rb_f_kill _((int, VALUE*));
void rb_gc_mark_trap_list _((void));
#ifdef POSIX_SIGNAL
#define posix_signal ruby_posix_signal
void posix_signal _((int, RETSIGTYPE (*)()));
#endif
void rb_trap_exit _((void));
void rb_trap_exec _((void));
/* sprintf.c */
VALUE rb_f_sprintf _((int, VALUE*));
/* string.c */
VALUE rb_str_new _((const char*, long));
VALUE rb_str_new2 _((const char*));
VALUE rb_str_new3 _((VALUE));
VALUE rb_str_new4 _((VALUE));
VALUE rb_tainted_str_new _((const char*, long));
VALUE rb_tainted_str_new2 _((const char*));
VALUE rb_obj_as_string _((VALUE));
VALUE rb_str_to_str _((VALUE));
VALUE rb_str_dup _((VALUE));
VALUE rb_str_dup_frozen _((VALUE));
VALUE rb_str_plus _((VALUE, VALUE));
VALUE rb_str_times _((VALUE, VALUE));
VALUE rb_str_substr _((VALUE, long, long));
void rb_str_modify _((VALUE));
VALUE rb_str_freeze _((VALUE));
VALUE rb_str_resize _((VALUE, long));
VALUE rb_str_cat _((VALUE, const char*, long));
VALUE rb_str_cat2 _((VALUE, const char*));
VALUE rb_str_append _((VALUE, VALUE));
VALUE rb_str_concat _((VALUE, VALUE));
int rb_str_hash _((VALUE));
int rb_str_cmp _((VALUE, VALUE));
VALUE rb_str_upto _((VALUE, VALUE, int));
VALUE rb_str_inspect _((VALUE));
VALUE rb_str_split _((VALUE, const char*));
void rb_str_associate _((VALUE, VALUE));
void rb_str_setter _((VALUE, ID, VALUE*));
/* struct.c */
VALUE rb_struct_new __((VALUE, ...));
VALUE rb_struct_define __((const char*, ...));
VALUE rb_struct_alloc _((VALUE, VALUE));
VALUE rb_struct_aref _((VALUE, VALUE));
VALUE rb_struct_aset _((VALUE, VALUE, VALUE));
VALUE rb_struct_getmember _((VALUE, ID));
/* time.c */
VALUE rb_time_new(ANYARGS);
/* variable.c */
VALUE rb_mod_name _((VALUE));
VALUE rb_class_path _((VALUE));
void rb_set_class_path _((VALUE, VALUE, const char*));
VALUE rb_path2class _((const char*));
void rb_name_class _((VALUE, ID));
void rb_autoload _((const char*, const char*));
VALUE rb_f_autoload _((VALUE, VALUE, VALUE));
void rb_gc_mark_global_tbl _((void));
VALUE rb_f_trace_var _((int, VALUE*));
VALUE rb_f_untrace_var _((int, VALUE*));
VALUE rb_f_global_variables _((void));
void rb_alias_variable _((ID, ID));
struct st_table* rb_generic_ivar_table _((VALUE));
void rb_clone_generic_ivar _((VALUE,VALUE));
void rb_mark_generic_ivar _((VALUE));
void rb_mark_generic_ivar_tbl _((void));
void rb_free_generic_ivar _((VALUE));
VALUE rb_ivar_get _((VALUE, ID));
VALUE rb_ivar_set _((VALUE, ID, VALUE));
VALUE rb_ivar_defined _((VALUE, ID));
VALUE rb_obj_instance_variables _((VALUE));
VALUE rb_obj_remove_instance_variable _((VALUE, VALUE));
VALUE rb_mod_const_at _((VALUE, VALUE));
VALUE rb_mod_constants _((VALUE));
VALUE rb_mod_const_of _((VALUE, VALUE));
VALUE rb_mod_remove_const _((VALUE, VALUE));
int rb_const_defined_at _((VALUE, ID));
int rb_autoload_defined _((ID));
int rb_const_defined _((VALUE, ID));
VALUE rb_const_get _((VALUE, ID));
VALUE rb_const_get_at _((VALUE, ID));
void rb_const_set _((VALUE, ID, VALUE));
void rb_const_assign _((VALUE, ID, VALUE));
VALUE rb_mod_constants _((VALUE));
void rb_autoload_load _((ID));
void rb_cvar_declare _((VALUE, ID, VALUE));
VALUE rb_cvar_defined _((VALUE, ID));
void rb_cvar_set _((VALUE, ID, VALUE));
VALUE rb_cvar_get _((VALUE, ID));
void rb_cv_set _((VALUE, const char *, VALUE));
VALUE rb_cv_get _((VALUE, const char *));
void rb_define_class_variable _((VALUE, const char *, VALUE));
VALUE rb_mod_class_variables _((VALUE));
VALUE rb_mod_remove_cvar _((VALUE, VALUE));
/* version.c */
void ruby_show_version _((void));
void ruby_show_copyright _((void));
