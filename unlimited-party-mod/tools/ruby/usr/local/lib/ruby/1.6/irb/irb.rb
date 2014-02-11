#!/usr/bin/env ruby
#
#   irb.rb - intaractive ruby
#   	$Release Version: 0.6 $
#   	$Revision: 1.2 $
#   	$Date: 2000/07/14 04:34:43 $
#   	by Keiju ISHITSUKA(Nippon Rational Inc.)
#
# --
# Usage:
#
#   irb.rb [options] file_name opts
#
#

require "irb/main"

if __FILE__ == $0
  IRB.start(__FILE__)
else
  # check -e option
  if /^-e$/ =~ $0
    IRB.start(__FILE__)
  else
    IRB.initialize(__FILE__)
  end
end
