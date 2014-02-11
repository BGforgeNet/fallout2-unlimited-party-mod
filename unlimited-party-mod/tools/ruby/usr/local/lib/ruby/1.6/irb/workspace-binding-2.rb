#
#   bind.rb - 
#   	$Release Version: $
#   	$Revision: 1.1 $
#   	$Date: 2000/05/12 09:07:55 $
#   	by Keiju ISHITSUKA(Nihon Rational Software Co.,Ltd)
#
# --
#
#   
#

while true
  IRB::BINDING_QUEUE.push b = binding
end
