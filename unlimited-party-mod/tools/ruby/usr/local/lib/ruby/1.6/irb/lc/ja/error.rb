#
#   irb/lc/ja/error.rb - 
#   	$Release Version: 0.7.3$
#   	$Revision: 1.1.2.2 $
#   	$Date: 2001/05/03 08:56:49 $
#   	by Keiju ISHITSUKA(keiju@ishitsuka.com)
#
# --
#
#   
#
require "e2mmap"

module IRB
  # exceptions
  extend Exception2MessageMapper
  def_exception :UnrecognizedSwitch, '$B%9%$%C%A(B(%s)$B$,J,$j$^$;$s(B'
  def_exception :NotImplementError, '`%s\'$B$NDj5A$,I,MW$G$9(B'
  def_exception :CantRetuenNormalMode, 'Normal$B%b!<%I$KLa$l$^$;$s(B.'
  def_exception :IllegalParameter, '$B%Q%i%a!<%?(B(%s)$B$,4V0c$C$F$$$^$9(B.'
  def_exception :IrbAlreadyDead, 'Irb$B$O4{$K;`$s$G$$$^$9(B.'
  def_exception :IrbSwitchToCurrentThread, 'Change to current thread.'
  def_exception :NoSuchJob, '$B$=$N$h$&$J%8%g%V(B(%s)$B$O$"$j$^$;$s(B.'
  def_exception :CanNotGoMultiIrbMode, 'multi-irb mode$B$K0\$l$^$;$s(B.'
  def_exception :CanNotChangeBinding, '$B%P%$%s%G%#%s%0(B(%s)$B$KJQ99$G$-$^$;$s(B.'
  def_exception :UndefinedPromptMode, '$B%W%m%s%W%H%b!<%I(B(%s)$B$ODj5A$5$l$F$$$^$;$s(B.'
end


