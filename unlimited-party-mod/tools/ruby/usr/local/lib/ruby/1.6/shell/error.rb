#
#   shell/error.rb - 
#   	$Release Version: 0.6.0 $
#   	$Revision: 1.1.2.1 $
#   	$Date: 2001/05/17 10:35:32 $
#   	by Keiju ISHITSUKA(Nihon Rational Software Co.,Ltd)
#
# --
#
#   
#

require "e2mmap"

class Shell
  module Error
    extend Exception2MessageMapper
    def_e2message TypeError, "wrong argument type %s (expected %s)"

    def_exception :DirStackEmpty, "Directory stack empty."
    def_exception :CanNotDefine, "Can't define method(%s, %s)."
    def_exception :CanNotMethodApply, "This method(%s) can't apply this type(%s)."
    def_exception :CommandNotFound, "Command not found(%s)."
  end
end

