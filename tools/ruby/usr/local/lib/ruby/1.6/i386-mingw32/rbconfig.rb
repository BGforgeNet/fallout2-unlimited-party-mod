
# This file was created by mkconfig.rb when ruby was built.  Any
# changes made to this file will be lost the next time ruby is built.

module Config
  RUBY_VERSION == "1.6.8" or
    raise "ruby lib version (1.6.8) doesn't match executable version (#{RUBY_VERSION})"

  DESTDIR = '' if not defined? DESTDIR
  CONFIG = {}
  TOPDIR = File.dirname(__FILE__).sub!(%r'/lib/ruby/1\.6/i386\-mingw32\Z', '')
  CONFIG["srcdir"] = "/pub/ruby/16/ruby16"
  CONFIG["prefix"] = (TOPDIR || DESTDIR + "/usr/local")
  CONFIG["ruby_install_name"] = "ruby"
  CONFIG["EXEEXT"] = ".exe"
  CONFIG["SHELL"] = "/bin/sh"
  CONFIG["CFLAGS"] = "-DNT -D__NO_ISOCEXT -Os"
  CONFIG["CPPFLAGS"] = ""
  CONFIG["CXXFLAGS"] = ""
  CONFIG["FFLAGS"] = ""
  CONFIG["LDFLAGS"] = "-Wl,--stack,0x02000000"
  CONFIG["LIBS"] = "-lwsock32 -lmsvcrt"
  CONFIG["exec_prefix"] = "$(prefix)"
  CONFIG["bindir"] = "$(exec_prefix)/bin"
  CONFIG["sbindir"] = "$(exec_prefix)/sbin"
  CONFIG["libexecdir"] = "$(exec_prefix)/libexec"
  CONFIG["datadir"] = "$(prefix)/share"
  CONFIG["sysconfdir"] = "$(prefix)/etc"
  CONFIG["sharedstatedir"] = "$(prefix)/com"
  CONFIG["localstatedir"] = "$(prefix)/var"
  CONFIG["libdir"] = "$(exec_prefix)/lib"
  CONFIG["includedir"] = "/usr/local/mingw/include"
  CONFIG["oldincludedir"] = "/usr/include"
  CONFIG["infodir"] = "$(prefix)/info"
  CONFIG["mandir"] = "$(prefix)/man"
  CONFIG["MAJOR"] = "1"
  CONFIG["MINOR"] = "6"
  CONFIG["TEENY"] = "8"
  CONFIG["host"] = "i686-pc-cygwin"
  CONFIG["host_alias"] = "i686-pc-cygwin"
  CONFIG["host_cpu"] = "i686"
  CONFIG["host_vendor"] = "pc"
  CONFIG["host_os"] = "cygwin"
  CONFIG["target"] = "i386-pc-mingw32"
  CONFIG["target_alias"] = "i386-mingw32"
  CONFIG["target_cpu"] = "i386"
  CONFIG["target_vendor"] = "pc"
  CONFIG["target_os"] = "mingw32"
  CONFIG["build"] = "i586-pc-linux-gnu"
  CONFIG["build_alias"] = "i586-pc-linux-gnu"
  CONFIG["build_cpu"] = "i586"
  CONFIG["build_vendor"] = "pc"
  CONFIG["build_os"] = "linux-gnu"
  CONFIG["CC"] = "gcc -mno-cygwin"
  CONFIG["CPP"] = "gcc -mno-cygwin -E"
  CONFIG["GNU_LD"] = "yes"
  CONFIG["CPPOUTFILE"] = ""
  CONFIG["OUTFLAG"] = "-o"
  CONFIG["YACC"] = "bison -y"
  CONFIG["RANLIB"] = "ranlib"
  CONFIG["AR"] = "ar"
  CONFIG["NM"] = "nm"
  CONFIG["DLLWRAP"] = "dllwrap"
  CONFIG["AS"] = "as"
  CONFIG["DLLTOOL"] = "dlltool"
  CONFIG["WINDRES"] = "windres"
  CONFIG["LN_S"] = "ln -s"
  CONFIG["SET_MAKE"] = ""
  CONFIG["OBJEXT"] = "o"
  CONFIG["LIBOBJS"] = "crypt.o flock.o isinf.o win32.o"
  CONFIG["ALLOCA"] = ""
  CONFIG["XLDFLAGS"] = ""
  CONFIG["DLDFLAGS"] = ""
  CONFIG["STATIC"] = ""
  CONFIG["CCDLFLAGS"] = "-DIMPORT"
  CONFIG["LDSHARED"] = "dllwrap --target=mingw32 --as=as --dlltool-name=dlltool --driver-name=gcc -mno-cygwin --export-all -s"
  CONFIG["DLEXT"] = "so"
  CONFIG["DLEXT2"] = "dll"
  CONFIG["STRIP"] = "strip"
  CONFIG["EXTSTATIC"] = ""
  CONFIG["setup"] = "Setup"
  CONFIG["MINIRUBY"] = "ruby -I/pub/ruby/16/mingw16 -rfake"
  CONFIG["PREP"] = "fake.rb"
  CONFIG["LIBRUBY_LDSHARED"] = "dllwrap --target=mingw32 --as=as --dlltool-name=dlltool --driver-name=gcc -mno-cygwin --export-all -s"
  CONFIG["LIBRUBY_DLDFLAGS"] = "--dllname=$@ --output-lib=$(LIBRUBY) --add-stdcall-alias --def=$(RUBYDEF)"
  CONFIG["RUBY_INSTALL_NAME"] = "ruby"
  CONFIG["RUBY_SO_NAME"] = "mingw32-$(RUBY_INSTALL_NAME)16"
  CONFIG["LIBRUBY_A"] = "lib$(RUBY_INSTALL_NAME)s.a"
  CONFIG["LIBRUBY_SO"] = "$(RUBY_SO_NAME).dll"
  CONFIG["LIBRUBY_ALIASES"] = ""
  CONFIG["LIBRUBY"] = "lib$(LIBRUBY_SO).a"
  CONFIG["LIBRUBYARG"] = "-L. -l$(RUBY_SO_NAME)"
  CONFIG["SOLIBS"] = "$(LIBS)"
  CONFIG["DLDLIBS"] = ""
  CONFIG["ENABLE_SHARED"] = "yes"
  CONFIG["MAINLIBS"] = ""
  CONFIG["arch"] = "i386-mingw32"
  CONFIG["sitedir"] = "$(prefix)/lib/ruby/site_ruby"
  CONFIG["configure_args"] = "--cache=config.cache --program-prefix= --target=i386-mingw32 --host=i686-pc-cygwin --build=i586-pc-linux-gnu --includedir=/usr/local/mingw/include --enable-shared --enable-tcltk_stubs --with-tcllib=tclstub83 --with-tklib=tkstub83 --with-dbm-type=gdbm --with-opt-dir=/usr/local/mingw"
  CONFIG["ruby_version"] = "$(MAJOR).$(MINOR)"
  CONFIG["rubylibdir"] = "$(libdir)/ruby/$(ruby_version)"
  CONFIG["archdir"] = "$(rubylibdir)/$(arch)"
  CONFIG["sitelibdir"] = "$(sitedir)/$(ruby_version)"
  CONFIG["sitearchdir"] = "$(sitelibdir)/$(arch)"
  CONFIG["compile_dir"] = "/pub/ruby/16/mingw16"
  MAKEFILE_CONFIG = {}
  CONFIG.each{|k,v| MAKEFILE_CONFIG[k] = v.dup}
  def Config::expand(val)
    val.gsub!(/\$\(([^()]+)\)/) do |var|
      key = $1
      if CONFIG.key? key
        Config::expand(CONFIG[key])
      else
	var
      end
    end
    val
  end
  CONFIG.each_value do |val|
    Config::expand(val)
  end
end
