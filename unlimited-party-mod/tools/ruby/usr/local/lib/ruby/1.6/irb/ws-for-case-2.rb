#
#   irb/ws-for-case-2.rb - 
#   	$Release Version: 0.7.3$
#   	$Revision: 1.1.2.1 $
#   	$Date: 2001/04/30 18:39:35 $
#   	by Keiju ISHITSUKA(keiju@ishitsuka.com)
#
# --
#
#   
#

while true
  IRB::BINDING_QUEUE.push b = binding
end
