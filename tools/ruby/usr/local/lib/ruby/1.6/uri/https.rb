#
# $Id: https.rb,v 1.1.2.1 2002/01/16 14:48:28 akira Exp $
#
# Copyright (c) 2001 akira yamada <akira@ruby-lang.org>
# You can redistribute it and/or modify it under the same term as Ruby.
#

require 'uri/http'

module URI

=begin

== URI::HTTPS

=== Super Class

((<URI::HTTP>))

=end

  class HTTPS < HTTP
    DEFAULT_PORT = 443
  end
  @@schemes['HTTPS'] = HTTPS
end # URI
