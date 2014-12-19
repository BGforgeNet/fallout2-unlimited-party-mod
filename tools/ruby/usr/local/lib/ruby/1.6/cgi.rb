=begin

== NAME

cgi.rb - cgi support library

Copyright (C) 2000  Network Applied Communication Laboratory, Inc.

Copyright (C) 2000  Information-technology Promotion Agency, Japan

Wakou Aoyama <wakou@ruby-lang.org>



== EXAMPLE

=== GET FORM VALUES

  require "cgi"
  cgi = CGI.new
  values = cgi['field_name']   # <== array of 'field_name'
    # if not 'field_name' included, then return [].
  fields = cgi.keys            # <== array of field names

  # returns true if form has 'field_name'
  cgi.has_key?('field_name')
  cgi.has_key?('field_name')
  cgi.include?('field_name')


=== GET FORM VALUES AS HASH

  require "cgi"
  cgi = CGI.new
  params = cgi.params

cgi.params is a hash.

  cgi.params['new_field_name'] = ["value"]  # add new param
  cgi.params['field_name'] = ["new_value"]  # change value
  cgi.params.delete('field_name')           # delete param
  cgi.params.clear                          # delete all params


=== SAVE FORM VALUES TO FILE

  require "pstore"
  db = PStore.new("query.db")
  db.transaction do
    db["params"] = cgi.params
  end


=== RESTORE FORM VALUES FROM FILE

  require "pstore"
  db = PStore.new("query.db")
  db.transaction do
    cgi.params = db["params"]
  end


=== GET MULTIPART FORM VALUES

  require "cgi"
  cgi = CGI.new
  values = cgi['field_name']   # <== array of 'field_name'
  values[0].read               # <== body of values[0]
  values[0].local_path         # <== path to local file of values[0]
  values[0].original_filename  # <== original filename of values[0]
  values[0].content_type       # <== content_type of values[0]

and values[0] has StringIO or Tempfile class methods.


=== GET COOKIE VALUES

  require "cgi"
  cgi = CGI.new
  values = cgi.cookies['name']  # <== array of 'name'
    # if not 'name' included, then return [].
  names = cgi.cookies.keys      # <== array of cookie names

and cgi.cookies is a hash.


=== GET COOKIE OBJECTS

  require "cgi"
  cgi = CGI.new
  for name, cookie in cgi.cookies
    cookie.expires = Time.now + 30
  end
  cgi.out("cookie" => cgi.cookies){"string"}

  cgi.cookies # { "name1" => cookie1, "name2" => cookie2, ... }

  require "cgi"
  cgi = CGI.new
  cgi.cookies['name'].expires = Time.now + 30
  cgi.out("cookie" => cgi.cookies['name']){"string"}

and see MAKE COOKIE OBJECT.


=== GET ENVIRONMENT VALUE

  require "cgi"
  cgi = CGI.new
  value = cgi.auth_type
    # ENV["AUTH_TYPE"]

see http://www.w3.org/CGI/

AUTH_TYPE CONTENT_LENGTH CONTENT_TYPE GATEWAY_INTERFACE PATH_INFO
PATH_TRANSLATED QUERY_STRING REMOTE_ADDR REMOTE_HOST REMOTE_IDENT
REMOTE_USER REQUEST_METHOD SCRIPT_NAME SERVER_NAME SERVER_PORT
SERVER_PROTOCOL SERVER_SOFTWARE

content_length and server_port return Integer. and the others return String.

and HTTP_COOKIE, HTTP_COOKIE2

  value = cgi.raw_cookie
    # ENV["HTTP_COOKIE"]
  value = cgi.raw_cookie2
    # ENV["HTTP_COOKIE2"]

and other HTTP_*

  value = cgi.accept
    # ENV["HTTP_ACCEPT"]
  value = cgi.accept_charset
    # ENV["HTTP_ACCEPT_CHARSET"]

HTTP_ACCEPT HTTP_ACCEPT_CHARSET HTTP_ACCEPT_ENCODING HTTP_ACCEPT_LANGUAGE
HTTP_CACHE_CONTROL HTTP_FROM HTTP_HOST HTTP_NEGOTIATE HTTP_PRAGMA
HTTP_REFERER HTTP_USER_AGENT


=== PRINT HTTP HEADER AND HTML STRING TO $DEFAULT_OUTPUT ($>)

  require "cgi"
  cgi = CGI.new("html3")  # add HTML generation methods
  cgi.out() do
    cgi.html() do
      cgi.head{ cgi.title{"TITLE"} } +
      cgi.body() do
        cgi.form() do
          cgi.textarea("get_text") +
          cgi.br +
          cgi.submit
        end +
        cgi.pre() do
          CGI::escapeHTML(
            "params: " + cgi.params.inspect + "\n" +
            "cookies: " + cgi.cookies.inspect + "\n" +
            ENV.collect() do |key, value|
              key + " --> " + value + "\n"
            end.join("")
          )
        end
      end
    end
  end

  # add HTML generation methods
  CGI.new("html3")    # html3.2
  CGI.new("html4")    # html4.01 (Strict)
  CGI.new("html4Tr")  # html4.01 Transitional
  CGI.new("html4Fr")  # html4.01 Frameset


=end

raise "Please, use ruby1.5.4 or later." if RUBY_VERSION < "1.5.4"

require 'English'

class CGI

  CR  = "\015"
  LF  = "\012"
  EOL = CR + LF
  REVISION = '$Id: cgi.rb,v 1.23.2.17 2002/08/25 20:15:54 wakou Exp $'

  NEEDS_BINMODE = true if /WIN/ni.match(RUBY_PLATFORM)
  PATH_SEPARATOR = {'UNIX'=>'/', 'WINDOWS'=>'\\', 'MACINTOSH'=>':'}

  HTTP_STATUS = {
    "OK"                  => "200 OK",
    "PARTIAL_CONTENT"     => "206 Partial Content",
    "MULTIPLE_CHOICES"    => "300 Multiple Choices",
    "MOVED"               => "301 Moved Permanently",
    "REDIRECT"            => "302 Found",
    "NOT_MODIFIED"        => "304 Not Modified",
    "BAD_REQUEST"         => "400 Bad Request",
    "AUTH_REQUIRED"       => "401 Authorization Required",
    "FORBIDDEN"           => "403 Forbidden",
    "NOT_FOUND"           => "404 Not Found",
    "METHOD_NOT_ALLOWED"  => "405 Method Not Allowed",
    "NOT_ACCEPTABLE"      => "406 Not Acceptable",
    "LENGTH_REQUIRED"     => "411 Length Required",
    "PRECONDITION_FAILED" => "412 Rrecondition Failed",
    "SERVER_ERROR"        => "500 Internal Server Error",
    "NOT_IMPLEMENTED"     => "501 Method Not Implemented",
    "BAD_GATEWAY"         => "502 Bad Gateway",
    "VARIANT_ALSO_VARIES" => "506 Variant Also Negotiates"
  }

  RFC822_DAYS = %w[ Sun Mon Tue Wed Thu Fri Sat ]
  RFC822_MONTHS = %w[ Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ]

  def env_table
    ENV
  end

  def stdinput
    $stdin
  end

  def stdoutput
    $DEFAULT_OUTPUT
  end

  private :env_table, :stdinput, :stdoutput

=begin
== METHODS
=end

=begin
=== ESCAPE URL ENCODE
  url_encoded_string = CGI::escape("string")
=end
  def CGI::escape(string)
    string.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
      '%' + $1.unpack('H2' * $1.size).join('%').upcase
    end.tr(' ', '+')
  end


=begin
=== UNESCAPE URL ENCODED
  string = CGI::unescape("url encoded string")
=end
  def CGI::unescape(string)
    string.tr('+', ' ').gsub(/((?:%[0-9a-fA-F]{2})+)/n) do
      [$1.delete('%')].pack('H*')
    end
  end


=begin
=== ESCAPE HTML &\"<>
  CGI::escapeHTML("string")
=end
  def CGI::escapeHTML(string)
    string.gsub(/&/n, '&amp;').gsub(/\"/n, '&quot;').gsub(/>/n, '&gt;').gsub(/</n, '&lt;')
  end


=begin
=== UNESCAPE HTML
  CGI::unescapeHTML("HTML escaped string")
=end
  def CGI::unescapeHTML(string)
    string.gsub(/&(.*?);/n) do
      match = $1.dup
      case match
      when /\Aamp\z/ni           then '&'
      when /\Aquot\z/ni          then '"'
      when /\Agt\z/ni            then '>'
      when /\Alt\z/ni            then '<'
      when /\A#0*(\d+)\z/n       then
        if Integer($1) < 256
          Integer($1).chr
        else
          if Integer($1) < 65536 and ($KCODE[0] == ?u or $KCODE[0] == ?U)
            [Integer($1)].pack("U")
          else
            "&##{$1};"
          end
        end
      when /\A#x([0-9a-f]+)\z/ni then
        if $1.hex < 256
          $1.hex.chr
        else
          if $1.hex < 65536 and ($KCODE[0] == ?u or $KCODE[0] == ?U)
            [$1.hex].pack("U")
          else
            "&#x#{$1};"
          end
        end
      else
        "&#{match};"
      end
    end
  end


=begin
=== ESCAPE ELEMENT
  print CGI::escapeElement('<BR><A HREF="url"></A>', "A", "IMG")
    # "<BR>&lt;A HREF="url"&gt;&lt;/A&gt"

  print CGI::escapeElement('<BR><A HREF="url"></A>', ["A", "IMG"])
    # "<BR>&lt;A HREF="url"&gt;&lt;/A&gt"
=end
  def CGI::escapeElement(string, *elements)
    elements = elements[0] if elements[0].kind_of?(Array)
    unless elements.empty?
      string.gsub(/<\/?(?:#{elements.join("|")})(?!\w)(?:.|\n)*?>/ni) do
        CGI::escapeHTML($&)
      end
    else
      string
    end
  end


=begin
=== UNESCAPE ELEMENT
  print CGI::unescapeElement(
          CGI::escapeHTML('<BR><A HREF="url"></A>'), "A", "IMG")
    # "&lt;BR&gt;<A HREF="url"></A>"

  print CGI::unescapeElement(
          CGI::escapeHTML('<BR><A HREF="url"></A>'), ["A", "IMG"])
    # "&lt;BR&gt;<A HREF="url"></A>"
=end
  def CGI::unescapeElement(string, *elements)
    elements = elements[0] if elements[0].kind_of?(Array)
    unless elements.empty?
      string.gsub(/&lt;\/?(?:#{elements.join("|")})(?!\w)(?:.|\n)*?&gt;/ni) do
        CGI::unescapeHTML($&)
      end
    else
      string
    end
  end


=begin
=== MAKE RFC1123 DATE STRING
  CGI::rfc1123_date(Time.now)
    # Sat, 01 Jan 2000 00:00:00 GMT
=end
  def CGI::rfc1123_date(time)
    t = time.clone.gmtime
    return format("%s, %.2d %s %.4d %.2d:%.2d:%.2d GMT",
                RFC822_DAYS[t.wday], t.day, RFC822_MONTHS[t.month-1], t.year,
                t.hour, t.min, t.sec)
  end


=begin
=== MAKE HTTP HEADER STRING
  header
    # Content-Type: text/html

  header("text/plain")
    # Content-Type: text/plain

  header({"nph"        => true,
          "status"     => "OK",  # == "200 OK"
            # "status"     => "200 GOOD",
          "server"     => ENV['SERVER_SOFTWARE'],
          "connection" => "close",
          "type"       => "text/html",
          "charset"    => "iso-2022-jp",
            # Content-Type: text/html; charset=iso-2022-jp
          "language"   => "ja",
          "expires"    => Time.now + 30,
          "cookie"     => [cookie1, cookie2],
          "my_header1" => "my_value"
          "my_header2" => "my_value"})

header will not convert charset.

status:

  "OK"                  --> "200 OK"
  "PARTIAL_CONTENT"     --> "206 Partial Content"
  "MULTIPLE_CHOICES"    --> "300 Multiple Choices"
  "MOVED"               --> "301 Moved Permanently"
  "REDIRECT"            --> "302 Found"
  "NOT_MODIFIED"        --> "304 Not Modified"
  "BAD_REQUEST"         --> "400 Bad Request"
  "AUTH_REQUIRED"       --> "401 Authorization Required"
  "FORBIDDEN"           --> "403 Forbidden"
  "NOT_FOUND"           --> "404 Not Found"
  "METHOD_NOT_ALLOWED"  --> "405 Method Not Allowed"
  "NOT_ACCEPTABLE"      --> "406 Not Acceptable"
  "LENGTH_REQUIRED"     --> "411 Length Required"
  "PRECONDITION_FAILED" --> "412 Rrecondition Failed"
  "SERVER_ERROR"        --> "500 Internal Server Error"
  "NOT_IMPLEMENTED"     --> "501 Method Not Implemented"
  "BAD_GATEWAY"         --> "502 Bad Gateway"
  "VARIANT_ALSO_VARIES" --> "506 Variant Also Negotiates"

=end
  def header(options = "text/html")

    buf = ""

    case options
    when String
      options = { "type" => options }
    when Hash
      options = options.dup
    end

    unless options.has_key?("type")
      options["type"] = "text/html"
    end

    if options.has_key?("charset")
      options["type"] += "; charset=" + options.delete("charset")
    end

    options.delete("nph") if defined?(MOD_RUBY)
    if options.delete("nph") or /IIS/n.match(env_table['SERVER_SOFTWARE'])
      buf += (env_table["SERVER_PROTOCOL"] or "HTTP/1.0")  + " " +
             (HTTP_STATUS[options["status"]] or options["status"] or "200 OK") +
             EOL +
             "Date: " + CGI::rfc1123_date(Time.now) + EOL

      unless options.has_key?("server")
        options["server"] = (env_table['SERVER_SOFTWARE'] or "")
      end

      unless options.has_key?("connection")
        options["connection"] = "close"
      end

      options.delete("status")
    end

    if options.has_key?("status")
      buf += "Status: " +
             (HTTP_STATUS[options["status"]] or options["status"]) + EOL
      options.delete("status")
    end

    if options.has_key?("server")
      buf += "Server: " + options.delete("server") + EOL
    end

    if options.has_key?("connection")
      buf += "Connection: " + options.delete("connection") + EOL
    end

    buf += "Content-Type: " + options.delete("type") + EOL

    if options.has_key?("length")
      buf += "Content-Length: " + options.delete("length").to_s + EOL
    end

    if options.has_key?("language")
      buf += "Content-Language: " + options.delete("language") + EOL
    end

    if options.has_key?("expires")
      buf += "Expires: " + CGI::rfc1123_date( options.delete("expires") ) + EOL
    end

    if options.has_key?("cookie")
      if options["cookie"].kind_of?(String) or
           options["cookie"].kind_of?(Cookie)
        buf += "Set-Cookie: " + options.delete("cookie").to_s + EOL
      elsif options["cookie"].kind_of?(Array)
        options.delete("cookie").each{|cookie|
          buf += "Set-Cookie: " + cookie.to_s + EOL
        }
      elsif options["cookie"].kind_of?(Hash)
        options.delete("cookie").each_value{|cookie|
          buf += "Set-Cookie: " + cookie.to_s + EOL
        }
      end
    end
    if @output_cookies
      for cookie in @output_cookies
        buf += "Set-Cookie: " + cookie.to_s + EOL
      end
    end

    options.each{|key, value|
      buf += key + ": " + value.to_s + EOL
    }

    if defined?(MOD_RUBY)
      table = Apache::request.headers_out
      buf.scan(/([^:]+): (.+)#{EOL}/n){ |name, value|
        $stderr.printf("name:%s value:%s\n", name, value) if $DEBUG
        case name
        when 'Set-Cookie'
          table.add($1, $2)
        when /^status$/ni
          Apache::request.status_line = value
          Apache::request.status = value.to_i
        when /^content-type$/ni
          Apache::request.content_type = value
        when /^content-encoding$/ni
          Apache::request.content_encoding = value
        when /^location$/ni
	  if Apache::request.status == 200
	    Apache::request.status = 302
	  end
          Apache::request.headers_out[name] = value
        else
          Apache::request.headers_out[name] = value
        end
      }
      Apache::request.send_http_header
      ''
    else
      buf + EOL
    end

  end # header()


=begin
=== PRINT HTTP HEADER AND STRING TO $DEFAULT_OUTPUT ($>)
  cgi = CGI.new
  cgi.out{ "string" }
    # Content-Type: text/html
    # Content-Length: 6
    #
    # string

  cgi.out("text/plain"){ "string" }
    # Content-Type: text/plain
    # Content-Length: 6
    #
    # string

  cgi.out({"nph"        => true,
           "status"     => "OK",  # == "200 OK"
           "server"     => ENV['SERVER_SOFTWARE'],
           "connection" => "close",
           "type"       => "text/html",
           "charset"    => "iso-2022-jp",
             # Content-Type: text/html; charset=iso-2022-jp
           "language"   => "ja",
           "expires"    => Time.now + (3600 * 24 * 30),
           "cookie"     => [cookie1, cookie2],
           "my_header1" => "my_value",
           "my_header2" => "my_value"}){ "string" }

if "HEAD" == REQUEST_METHOD then output only HTTP header.

if charset is "iso-2022-jp" or "euc-jp" or "shift_jis" then
convert string charset, and set language to "ja".

=end
  def out(options = "text/html")

    options = { "type" => options } if options.kind_of?(String)
    content = yield

    if options.has_key?("charset")
      require "nkf"
      case options["charset"]
      when /iso-2022-jp/ni
        content = NKF::nkf('-j', content)
        options["language"] = "ja" unless options.has_key?("language")
      when /euc-jp/ni
        content = NKF::nkf('-e', content)
        options["language"] = "ja" unless options.has_key?("language")
      when /shift_jis/ni
        content = NKF::nkf('-s', content)
        options["language"] = "ja" unless options.has_key?("language")
      end
    end

    options["length"] = content.length.to_s
    output = stdoutput
    output.binmode if defined? output.binmode
    output.print header(options)
    output.print content unless "HEAD" == env_table['REQUEST_METHOD']
  end


=begin
=== PRINT
  cgi = CGI.new
  cgi.print    # default:  cgi.print == $DEFAULT_OUTPUT.print
=end
  def print(*options)
    stdoutput.print(*options)
  end


=begin
=== MAKE COOKIE OBJECT
  cookie1 = CGI::Cookie::new("name", "value1", "value2", ...)
  cookie1 = CGI::Cookie::new({"name" => "name", "value" => "value"})
  cookie1 = CGI::Cookie::new({'name'    => 'name',
                              'value'   => ['value1', 'value2', ...],
                              'path'    => 'path',   # optional
                              'domain'  => 'domain', # optional
                              'expires' => Time.now, # optional
                              'secure'  => true      # optional
                             })

  cgi.out({"cookie" => [cookie1, cookie2]}){ "string" }

  name    = cookie1.name
  values  = cookie1.value
  path    = cookie1.path
  domain  = cookie1.domain
  expires = cookie1.expires
  secure  = cookie1.secure

  cookie1.name    = 'name'
  cookie1.value   = ['value1', 'value2', ...]
  cookie1.path    = 'path'
  cookie1.domain  = 'domain'
  cookie1.expires = Time.now + 30
  cookie1.secure  = true
=end
  require "delegate"
  class Cookie < SimpleDelegator

    def initialize(name = "", *value)
      options = if name.kind_of?(String)
                  { "name" => name, "value" => value }
                else
                  name
                end
      unless options.has_key?("name")
        raise ArgumentError, "`name' required"
      end

      @name = options["name"]
      @value = Array(options["value"])
      # simple support for IE
      if options["path"]
        @path = options["path"]
      else
        %r|^(.*/)|.match(ENV["SCRIPT_NAME"])
        @path = ($1 or "")
      end
      @domain = options["domain"]
      @expires = options["expires"]
      @secure = options["secure"] == true ? true : false

      super(@value)
    end

    attr_accessor("name", "value", "path", "domain", "expires")
    attr_reader("secure")
    def secure=(val)
      @secure = val if val == true or val == false
      @secure
    end

    def to_s
      buf = ""
      buf += @name + '='

      if @value.kind_of?(String)
        buf += CGI::escape(@value)
      else
        buf += @value.collect{|v| CGI::escape(v) }.join("&")
      end

      if @domain
        buf += '; domain=' + @domain
      end

      if @path
        buf += '; path=' + @path
      end

      if @expires
        buf += '; expires=' + CGI::rfc1123_date(@expires)
      end

      if @secure == true
        buf += '; secure'
      end

      buf
    end

  end # class Cookie


=begin
=== PARSE RAW COOKIE STRING
  cookies = CGI::Cookie::parse("raw_cookie_string")
    # { "name1" => cookie1, "name2" => cookie2, ... }
=end
  def Cookie::parse(raw_cookie)
    cookies = Hash.new([])
    return cookies unless raw_cookie

    raw_cookie.split('; ').each do |pairs|
      name, values = pairs.split('=',2)
      name = CGI::unescape(name)
      values ||= ""
      values = values.split('&').collect{|v| CGI::unescape(v) }
      unless cookies.has_key?(name)
        cookies[name] = Cookie::new({ "name" => name, "value" => values })
      end
    end

    cookies
  end


=begin
=== PARSE QUERY STRING
  params = CGI::parse("query_string")
    # {"name1" => ["value1", "value2", ...],
    #  "name2" => ["value1", "value2", ...], ... }
=end
  def CGI::parse(query)
    params = Hash.new([])

    query.split(/[&;]/n).each do |pairs|
      key, value = pairs.split('=',2).collect{|v| CGI::unescape(v) }
      if params.has_key?(key)
        params[key].push(value)
      else
        params[key] = [value]
      end
    end

    params
  end


  module QueryExtension

    for env in %w[ CONTENT_LENGTH SERVER_PORT ]
      eval( <<-END )
        def #{env.sub(/^HTTP_/n, '').downcase}
          env_table["#{env}"] && Integer(env_table["#{env}"])
        end
      END
    end

    for env in %w[ AUTH_TYPE CONTENT_TYPE GATEWAY_INTERFACE PATH_INFO
        PATH_TRANSLATED QUERY_STRING REMOTE_ADDR REMOTE_HOST
        REMOTE_IDENT REMOTE_USER REQUEST_METHOD SCRIPT_NAME
        SERVER_NAME SERVER_PROTOCOL SERVER_SOFTWARE

        HTTP_ACCEPT HTTP_ACCEPT_CHARSET HTTP_ACCEPT_ENCODING
        HTTP_ACCEPT_LANGUAGE HTTP_CACHE_CONTROL HTTP_FROM HTTP_HOST
        HTTP_NEGOTIATE HTTP_PRAGMA HTTP_REFERER HTTP_USER_AGENT ]
      eval( <<-END )
        def #{env.sub(/^HTTP_/n, '').downcase}
          env_table["#{env}"]
        end
      END
    end

    def raw_cookie
      env_table["HTTP_COOKIE"]
    end

    def raw_cookie2
      env_table["HTTP_COOKIE2"]
    end

    attr_accessor("cookies")
    attr("params")
    def params=(hash)
      @params.clear
      @params.update(hash)
    end

    def read_multipart(boundary, content_length)
      params = Hash.new([])
      boundary = "--" + boundary
      buf = ""
      bufsize = 10 * 1024

      # start multipart/form-data
      stdinput.binmode
      boundary_size = boundary.size + EOL.size
      content_length -= boundary_size
      status = stdinput.read(boundary_size)
      if nil == status
        raise EOFError, "no content body"
      elsif boundary + EOL != status
        raise EOFError, "bad content body"
      end

      until -1 == content_length
        head = nil
        if 10240 < content_length
          require "tempfile"
          body = Tempfile.new("CGI")
        else
          begin
            require "stringio" if not defined? StringIO
            body = StringIO.new
          rescue LoadError
            require "tempfile"
            body = Tempfile.new("CGI")
          end
        end
        body.binmode

        until head and /#{boundary}(?:#{EOL}|--)/n.match(buf)

          if (not head) and /#{EOL}#{EOL}/n.match(buf)
            buf = buf.sub(/\A((?:.|\n)*?#{EOL})#{EOL}/n) do
              head = $1.dup
              ""
            end
            next
          end

          if head and ( (EOL + boundary + EOL).size < buf.size )
            body.print buf[0 ... (buf.size - (EOL + boundary + EOL).size)]
            buf[0 ... (buf.size - (EOL + boundary + EOL).size)] = ""
          end

          c = if bufsize < content_length
                stdinput.read(bufsize) or ''
              else
                stdinput.read(content_length) or ''
              end
          buf += c
          content_length -= c.size

        end

        buf = buf.sub(/\A((?:.|\n)*?)(?:#{EOL})?#{boundary}(#{EOL}|--)/n) do
          body.print $1
          if "--" == $2
            content_length = -1
          end
          ""
        end

        body.rewind

        eval <<-END
          def body.local_path
            #{body.path.dump}
          end
        END

        /Content-Disposition:.* filename="?([^\";]*)"?/ni.match(head)
        eval <<-END
          def body.original_filename
            #{
              filename = ($1 or "").dup
              if /Mac/ni.match(env_table['HTTP_USER_AGENT']) and
                 /Mozilla/ni.match(env_table['HTTP_USER_AGENT']) and
                 (not /MSIE/ni.match(env_table['HTTP_USER_AGENT']))
                CGI::unescape(filename)
              else
                filename
              end.dump.untaint
            }.taint
          end
        END

        /Content-Type: (.*)/ni.match(head)
        eval <<-END
          def body.content_type
            #{($1 or "").dump.untaint}.taint
          end
        END

        /Content-Disposition:.* name="?([^\";]*)"?/ni.match(head)
        name = $1.dup

        if params.has_key?(name)
          params[name].push(body)
        else
          params[name] = [body]
        end

      end

      params
    end # read_multipart
    private :read_multipart

    # offline mode. read name=value pairs on standard input.
    def read_from_cmdline
      require "shellwords"

      string = unless ARGV.empty?
        ARGV.join(' ')
      else
        if STDIN.tty?
          STDERR.print(
            %|(offline mode: enter name=value pairs on standard input)\n|
          )
        end
        readlines.join(' ').gsub(/\n/n, '')
      end.gsub(/\\=/n, '%3D').gsub(/\\&/n, '%26')

      words = Shellwords.shellwords(string)

      if words.find{|x| /=/n.match(x) }
        words.join('&')
      else
        words.join('+')
      end
    end
    private :read_from_cmdline

    def initialize_query()
      if ("POST" == env_table['REQUEST_METHOD']) and
         %r|\Amultipart/form-data.*boundary=\"?([^\";,]+)\"?|n.match(env_table['CONTENT_TYPE'])
        boundary = $1.dup
        @params = read_multipart(boundary, Integer(env_table['CONTENT_LENGTH']))
      else
        @params = CGI::parse(
                    case env_table['REQUEST_METHOD']
                    when "GET", "HEAD"
                      if defined?(MOD_RUBY)
                        Apache::request.args or ""
                      else
                        env_table['QUERY_STRING'] or ""
                      end
                    when "POST"
                      stdinput.binmode
                      stdinput.read(Integer(env_table['CONTENT_LENGTH'])) or ''
                    else
                      read_from_cmdline
                    end
                  )
      end

      @cookies = CGI::Cookie::parse((env_table['HTTP_COOKIE'] or env_table['COOKIE']))

    end
    private :initialize_query

    def [](*args)
      @params[*args]
    end

    def keys(*args)
      @params.keys(*args)
    end

    def has_key?(*args)
      @params.has_key?(*args)
    end
    alias key? has_key?
    alias include? has_key?

  end # QueryExtension


=begin
=== HTML PRETTY FORMAT
  print CGI::pretty("<HTML><BODY></BODY></HTML>")
    # <HTML>
    #   <BODY>
    #   </BODY>
    # </HTML>

  print CGI::pretty("<HTML><BODY></BODY></HTML>", "\t")
    # <HTML>
    #         <BODY>
    #         </BODY>
    # </HTML>
=end
  def CGI::pretty(string, shift = "  ")
    lines = string.gsub(/(?!\A)<(?:.|\n)*?>/n, "\n\\0").gsub(/<(?:.|\n)*?>(?!\n)/n, "\\0\n")
    end_pos = 0
    while end_pos = lines.index(/^<\/(\w+)/n, end_pos)
      element = $1.dup
      start_pos = lines.rindex(/^\s*<#{element}/ni, end_pos)
      lines[start_pos ... end_pos] = "__" + lines[start_pos ... end_pos].gsub(/\n(?!\z)/n, "\n" + shift) + "__"
    end
    lines.gsub(/^((?:#{Regexp::quote(shift)})*)__(?=<\/?\w)/n, '\1')
  end


=begin
== HTML ELEMENTS

  cgi = CGI.new("html3")  # add HTML generation methods
  cgi.element
  cgi.element{ "string" }
  cgi.element({ "ATTRIBUTE1" => "value1", "ATTRIBUTE2" => "value2" })
  cgi.element({ "ATTRIBUTE1" => "value1", "ATTRIBUTE2" => "value2" }){ "string" }

  # add HTML generation methods
  CGI.new("html3")    # html3.2
  CGI.new("html4")    # html4.0 (Strict)
  CGI.new("html4Tr")  # html4.0 Transitional
  CGI.new("html4Fr")  # html4.0 Frameset

=end


  module TagMaker

    # - -
    def nn_element_def(element)
      <<-END.gsub(/element\.downcase/n, element.downcase).gsub(/element\.upcase/n, element.upcase)
          "<element.upcase" + attributes.collect{|name, value|
            next unless value
            " " + CGI::escapeHTML(name) +
            if true == value
              ""
            else
              '="' + CGI::escapeHTML(value) + '"'
            end
          }.to_s + ">" +
          if block_given?
            yield.to_s
          else
            ""
          end +
          "</element.upcase>"
      END
    end

    # - O EMPTY
    def nOE_element_def(element)
      <<-END.gsub(/element\.downcase/n, element.downcase).gsub(/element\.upcase/n, element.upcase)
          "<element.upcase" + attributes.collect{|name, value|
            next unless value
            " " + CGI::escapeHTML(name) +
            if true == value
              ""
            else
              '="' + CGI::escapeHTML(value) + '"'
            end
          }.to_s + ">"
      END
    end

    # O O or - O
    def nO_element_def(element)
      <<-END.gsub(/element\.downcase/n, element.downcase).gsub(/element\.upcase/n, element.upcase)
          "<element.upcase" + attributes.collect{|name, value|
            next unless value
            " " + CGI::escapeHTML(name) +
            if true == value
              ""
            else
              '="' + CGI::escapeHTML(value) + '"'
            end
          }.to_s + ">" +
          if block_given?
            yield.to_s + "</element.upcase>"
          else
            ""
          end
      END
    end

  end # TagMaker


  module HtmlExtension


=begin
=== A ELEMENT
  a("url")
    # = a({ "HREF" => "url" })
=end
    def a(href = "")
      attributes = if href.kind_of?(String)
                     { "HREF" => href }
                   else
                     href
                   end
      if block_given?
        super(attributes){ yield }
      else
        super(attributes)
      end
    end


=begin
=== BASE ELEMENT
  base("url")
    # = base({ "HREF" => "url" })
=end
    def base(href = "")
      attributes = if href.kind_of?(String)
                     { "HREF" => href }
                   else
                     href
                   end
      if block_given?
        super(attributes){ yield }
      else
        super(attributes)
      end
    end


=begin
=== BLOCKQUOTE ELEMENT
  blockquote("url"){ "string" }
    # = blockquote({ "CITE" => "url" }){ "string" }
=end
    def blockquote(cite = nil)
      attributes = if cite.kind_of?(String)
                     { "CITE" => cite }
                   else
                     cite or ""
                   end
      if block_given?
        super(attributes){ yield }
      else
        super(attributes)
      end
    end


=begin
=== CAPTION ELEMENT
  caption("align"){ "string" }
    # = caption({ "ALIGN" => "align" }){ "string" }
=end
    def caption(align = nil)
      attributes = if align.kind_of?(String)
                     { "ALIGN" => align }
                   else
                     align or ""
                   end
      if block_given?
        super(attributes){ yield }
      else
        super(attributes)
      end
    end


=begin
=== CHECKBOX
  checkbox("name")
    # = checkbox({ "NAME" => "name" })

  checkbox("name", "value")
    # = checkbox({ "NAME" => "name", "VALUE" => "value" })

  checkbox("name", "value", true)
    # = checkbox({ "NAME" => "name", "VALUE" => "value", "CHECKED" => true })
=end
    def checkbox(name = "", value = nil, checked = nil)
      attributes = if name.kind_of?(String)
                     { "TYPE" => "checkbox", "NAME" => name,
                       "VALUE" => value, "CHECKED" => checked }
                   else
                     name["TYPE"] = "checkbox"
                     name
                   end
      input(attributes)
    end


=begin
=== CHECKBOX_GROUP
  checkbox_group("name", "foo", "bar", "baz")
    # <INPUT TYPE="checkbox" NAME="name" VALUE="foo">foo
    # <INPUT TYPE="checkbox" NAME="name" VALUE="bar">bar
    # <INPUT TYPE="checkbox" NAME="name" VALUE="baz">baz

  checkbox_group("name", ["foo"], ["bar", true], "baz")
    # <INPUT TYPE="checkbox" NAME="name" VALUE="foo">foo
    # <INPUT TYPE="checkbox" CHECKED NAME="name" VALUE="bar">bar
    # <INPUT TYPE="checkbox" NAME="name" VALUE="baz">baz

  checkbox_group("name", ["1", "Foo"], ["2", "Bar", true], "Baz")
    # <INPUT TYPE="checkbox" NAME="name" VALUE="1">Foo
    # <INPUT TYPE="checkbox" CHECKED NAME="name" VALUE="2">Bar
    # <INPUT TYPE="checkbox" NAME="name" VALUE="Baz">Baz

  checkbox_group({ "NAME" => "name",
                   "VALUES" => ["foo", "bar", "baz"] })

  checkbox_group({ "NAME" => "name",
                   "VALUES" => [["foo"], ["bar", true], "baz"] })

  checkbox_group({ "NAME" => "name",
                   "VALUES" => [["1", "Foo"], ["2", "Bar", true], "Baz"] })
=end
    def checkbox_group(name = "", *values)
      if name.kind_of?(Hash)
        values = name["VALUES"]
        name = name["NAME"]
      end
      values.collect{|value|
        if value.kind_of?(String)
          checkbox(name, value) + value
        else
          if value[value.size - 1] == true
            checkbox(name, value[0], true) +
            value[value.size - 2]
          else
            checkbox(name, value[0]) +
            value[value.size - 1]
          end
        end
      }.to_s
    end


=begin
=== FILE_FIELD
  file_field("name")
    # <INPUT TYPE="file" NAME="name" SIZE="20">

  file_field("name", 40)
    # <INPUT TYPE="file" NAME="name" SIZE="40">

  file_field("name", 40, 100)
    # <INPUT TYPE="file" NAME="name" SIZE="40" MAXLENGTH="100">

  file_field({ "NAME" => "name", "SIZE" => 40 })
    # <INPUT TYPE="file" NAME="name" SIZE="40">
=end
    def file_field(name = "", size = 20, maxlength = nil)
      attributes = if name.kind_of?(String)
                     { "TYPE" => "file", "NAME" => name,
                       "SIZE" => size.to_s }
                   else
                     name["TYPE"] = "file"
                     name
                   end
      attributes["MAXLENGTH"] = maxlength.to_s if maxlength
      input(attributes)
    end


=begin
=== FORM ELEMENT
  form{ "string" }
    # <FORM METHOD="post" ENCTYPE="application/x-www-form-urlencoded">string</FORM>

  form("get"){ "string" }
    # <FORM METHOD="get" ENCTYPE="application/x-www-form-urlencoded">string</FORM>

  form("get", "url"){ "string" }
    # <FORM METHOD="get" ACTION="url" ENCTYPE="application/x-www-form-urlencoded">string</FORM>

  form({"METHOD" => "post", "ENCTYPE" => "enctype"}){ "string" }
    # <FORM METHOD="post" ENCTYPE="enctype">string</FORM>

The hash keys are case sensitive. Ask the samples.
=end
    def form(method = "post", action = script_name, enctype = "application/x-www-form-urlencoded")
      attributes = if method.kind_of?(String)
                     { "METHOD" => method, "ACTION" => action,
                       "ENCTYPE" => enctype } 
                   else
                     unless method.has_key?("METHOD")
                       method["METHOD"] = "post"
                     end
                     unless method.has_key?("ENCTYPE")
                       method["ENCTYPE"] = enctype
                     end
                     method
                   end
      if block_given?
        body = yield
      else
        body = ""
      end
      if @output_hidden
        hidden = @output_hidden.collect{|k,v|
          "<INPUT TYPE=HIDDEN NAME=\"#{k}\" VALUE=\"#{v}\">"
        }.to_s
        if defined? fieldset
          body += fieldset{ hidden }
        else
          body += hidden
        end
      end
      super(attributes){body}
    end

=begin
=== HIDDEN FIELD
  hidden("name")
    # <INPUT TYPE="hidden" NAME="name">

  hidden("name", "value")
    # <INPUT TYPE="hidden" NAME="name" VALUE="value">

  hidden({ "NAME" => "name", "VALUE" => "reset", "ID" => "foo" })
    # <INPUT TYPE="hidden" NAME="name" VALUE="value" ID="foo">
=end
    def hidden(name = "", value = nil)
      attributes = if name.kind_of?(String)
                     { "TYPE" => "hidden", "NAME" => name, "VALUE" => value }
                   else
                     name["TYPE"] = "hidden"
                     name
                   end
      input(attributes)
    end


=begin
=== HTML ELEMENT

  html{ "string" }
    # <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"><HTML>string</HTML>

  html({ "LANG" => "ja" }){ "string" }
    # <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN"><HTML LANG="ja">string</HTML>

  html({ "DOCTYPE" => false }){ "string" }
    # <HTML>string</HTML>

  html({ "DOCTYPE" => '<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">' }){ "string" }
    # <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN"><HTML>string</HTML>

  html({ "PRETTY" => "  " }){ "<BODY></BODY>" }
    # <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
    # <HTML>
    #   <BODY>
    #   </BODY>
    # </HTML>

  html({ "PRETTY" => "\t" }){ "<BODY></BODY>" }
    # <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
    # <HTML>
    #         <BODY>
    #         </BODY>
    # </HTML>

  html("PRETTY"){ "<BODY></BODY>" }
    # = html({ "PRETTY" => "  " }){ "<BODY></BODY>" }

  html(if $VERBOSE then "PRETTY" end){ "HTML string" }

=end
    def html(attributes = {})
      if nil == attributes
        attributes = {}
      elsif "PRETTY" == attributes
        attributes = { "PRETTY" => true }
      end
      pretty = attributes.delete("PRETTY")
      pretty = "  " if true == pretty
      buf = ""

      if attributes.has_key?("DOCTYPE")
        if attributes["DOCTYPE"]
          buf += attributes.delete("DOCTYPE")
        else
          attributes.delete("DOCTYPE")
        end
      else
        buf += doctype
      end

      if block_given?
        buf += super(attributes){ yield }
      else
        buf += super(attributes)
      end

      if pretty
        CGI::pretty(buf, pretty)
      else
        buf
      end

    end


=begin
=== IMAGE_BUTTON
  image_button("url")
    # <INPUT TYPE="image" SRC="url">

  image_button("url", "name", "string")
    # <INPUT TYPE="image" SRC="url" NAME="name" ALT="string">

  image_button({ "SRC" => "url", "ATL" => "strng" })
    # <INPUT TYPE="image" SRC="url" ALT="string">
=end
    def image_button(src = "", name = nil, alt = nil)
      attributes = if src.kind_of?(String)
                     { "TYPE" => "image", "SRC" => src, "NAME" => name,
                       "ALT" => alt }
                   else
                     src["TYPE"] = "image"
                     src["SRC"] ||= ""
                     src
                   end
      input(attributes)
    end


=begin
=== IMG ELEMENT
  img("src", "alt", 100, 50)
    # <IMG SRC="src" ALT="alt" WIDTH="100" HEIGHT="50">

  img({ "SRC" => "src", "ALT" => "alt", "WIDTH" => 100, "HEIGHT" => 50 })
    # <IMG SRC="src" ALT="alt" WIDTH="100" HEIGHT="50">
=end
    def img(src = "", alt = "", width = nil, height = nil)
      attributes = if src.kind_of?(String)
                     { "SRC" => src, "ALT" => alt }
                   else
                     src
                   end
      attributes["WIDTH"] = width.to_s if width
      attributes["HEIGHT"] = height.to_s if height
      super(attributes)
    end


=begin
=== MULTIPART FORM
  multipart_form{ "string" }
    # <FORM METHOD="post" ENCTYPE="multipart/form-data">string</FORM>

  multipart_form("url"){ "string" }
    # <FORM METHOD="post" ACTION="url" ENCTYPE="multipart/form-data">string</FORM>
=end
    def multipart_form(action = nil, enctype = "multipart/form-data")
      attributes = if action == nil
                     { "METHOD" => "post", "ENCTYPE" => enctype } 
                   elsif action.kind_of?(String)
                     { "METHOD" => "post", "ACTION" => action,
                       "ENCTYPE" => enctype } 
                   else
                     unless action.has_key?("METHOD")
                       action["METHOD"] = "post"
                     end
                     unless action.has_key?("ENCTYPE")
                       action["ENCTYPE"] = enctype
                     end
                     action
                   end
      if block_given?
        form(attributes){ yield }
      else
        form(attributes)
      end
    end


=begin
=== PASSWORD_FIELD
  password_field("name")
    # <INPUT TYPE="password" NAME="name" SIZE="40">

  password_field("name", "value")
    # <INPUT TYPE="password" NAME="name" VALUE="value" SIZE="40">

  password_field("password", "value", 80, 200)
    # <INPUT TYPE="password" NAME="name" VALUE="value" SIZE="80" MAXLENGTH="200">

  password_field({ "NAME" => "name", "VALUE" => "value" })
    # <INPUT TYPE="password" NAME="name" VALUE="value">
=end
    def password_field(name = "", value = nil, size = 40, maxlength = nil)
      attributes = if name.kind_of?(String)
                     { "TYPE" => "password", "NAME" => name,
                       "VALUE" => value, "SIZE" => size.to_s }
                   else
                     name["TYPE"] = "password"
                     name
                   end
      attributes["MAXLENGTH"] = maxlength.to_s if maxlength
      input(attributes)
    end


=begin
=== POPUP_MENU
  popup_menu("name", "foo", "bar", "baz")
    # <SELECT NAME="name">
    #   <OPTION VALUE="foo">foo</OPTION>
    #   <OPTION VALUE="bar">bar</OPTION>
    #   <OPTION VALUE="baz">baz</OPTION>
    # </SELECT>

  popup_menu("name", ["foo"], ["bar", true], "baz")
    # <SELECT NAME="name">
    #   <OPTION VALUE="foo">foo</OPTION>
    #   <OPTION VALUE="bar" SELECTED>bar</OPTION>
    #   <OPTION VALUE="baz">baz</OPTION>
    # </SELECT>

  popup_menu("name", ["1", "Foo"], ["2", "Bar", true], "Baz")
    # <SELECT NAME="name">
    #   <OPTION VALUE="1">Foo</OPTION>
    #   <OPTION SELECTED VALUE="2">Bar</OPTION>
    #   <OPTION VALUE="Baz">Baz</OPTION>
    # </SELECT>

  popup_menu({"NAME" => "name", "SIZE" => 2, "MULTIPLE" => true,
              "VALUES" => [["1", "Foo"], ["2", "Bar", true], "Baz"] })
    # <SELECT NAME="name" MULTIPLE SIZE="2">
    #   <OPTION VALUE="1">Foo</OPTION>
    #   <OPTION SELECTED VALUE="2">Bar</OPTION>
    #   <OPTION VALUE="Baz">Baz</OPTION>
    # </SELECT>
=end
    def popup_menu(name = "", *values)

      if name.kind_of?(Hash)
        values   = name["VALUES"]
        size     = name["SIZE"].to_s if name["SIZE"]
        multiple = name["MULTIPLE"]
        name     = name["NAME"]
      else
        size = nil
        multiple = nil
      end

      select({ "NAME" => name, "SIZE" => size,
               "MULTIPLE" => multiple }){
        values.collect{|value|
          if value.kind_of?(String)
            option({ "VALUE" => value }){ value }
          else
            if value[value.size - 1] == true
              option({ "VALUE" => value[0], "SELECTED" => true }){
                value[value.size - 2]
              }
            else
              option({ "VALUE" => value[0] }){
                value[value.size - 1]
              }
            end
          end
        }.to_s
      }

    end


=begin
=== RADIO_BUTTON
  radio_button("name", "value")
    # <INPUT TYPE="radio" NAME="name" VALUE="value">

  radio_button("name", "value", true)
    # <INPUT TYPE="radio" NAME="name" VALUE="value" CHECKED>

  radio_button({ "NAME" => "name", "VALUE" => "value", "ID" => "foo" })
    # <INPUT TYPE="radio" NAME="name" VALUE="value" ID="foo">
=end
    def radio_button(name = "", value = nil, checked = nil)
      attributes = if name.kind_of?(String)
                     { "TYPE" => "radio", "NAME" => name,
                       "VALUE" => value, "CHECKED" => checked }
                   else
                     name["TYPE"] = "radio"
                     name
                   end
      input(attributes)
    end


=begin
=== RADIO_GROUP
  radio_group("name", "foo", "bar", "baz")
    # <INPUT TYPE="radio" NAME="name" VALUE="foo">foo
    # <INPUT TYPE="radio" NAME="name" VALUE="bar">bar
    # <INPUT TYPE="radio" NAME="name" VALUE="baz">baz

  radio_group("name", ["foo"], ["bar", true], "baz")
    # <INPUT TYPE="radio" NAME="name" VALUE="foo">foo
    # <INPUT TYPE="radio" CHECKED NAME="name" VALUE="bar">bar
    # <INPUT TYPE="radio" NAME="name" VALUE="baz">baz

  radio_group("name", ["1", "Foo"], ["2", "Bar", true], "Baz")
    # <INPUT TYPE="radio" NAME="name" VALUE="1">Foo
    # <INPUT TYPE="radio" CHECKED NAME="name" VALUE="2">Bar
    # <INPUT TYPE="radio" NAME="name" VALUE="Baz">Baz

  radio_group({ "NAME" => "name",
                "VALUES" => ["foo", "bar", "baz"] })

  radio_group({ "NAME" => "name",
                "VALUES" => [["foo"], ["bar", true], "baz"] })

  radio_group({ "NAME" => "name",
                "VALUES" => [["1", "Foo"], ["2", "Bar", true], "Baz"] })
=end
    def radio_group(name = "", *values)
      if name.kind_of?(Hash)
        values = name["VALUES"]
        name = name["NAME"]
      end
      values.collect{|value|
        if value.kind_of?(String)
          radio_button(name, value) + value
        else
          if value[value.size - 1] == true
            radio_button(name, value[0], true) +
            value[value.size - 2]
          else
            radio_button(name, value[0]) +
            value[value.size - 1]
          end
        end
      }.to_s
    end


=begin
=== RESET BUTTON
  reset
    # <INPUT TYPE="reset">

  reset("reset")
    # <INPUT TYPE="reset" VALUE="reset">

  reset({ "VALUE" => "reset", "ID" => "foo" })
    # <INPUT TYPE="reset" VALUE="reset" ID="foo">
=end
    def reset(value = nil, name = nil)
      attributes = if (not value) or value.kind_of?(String)
                     { "TYPE" => "reset", "VALUE" => value, "NAME" => name }
                   else
                     value["TYPE"] = "reset"
                     value
                   end
      input(attributes)
    end


=begin
=== SCROLLING_LIST
  scrolling_list({"NAME" => "name", "SIZE" => 2, "MULTIPLE" => true,
                  "VALUES" => [["1", "Foo"], ["2", "Bar", true], "Baz"] })
    # <SELECT NAME="name" MULTIPLE SIZE="2">
    #   <OPTION VALUE="1">Foo</OPTION>
    #   <OPTION SELECTED VALUE="2">Bar</OPTION>
    #   <OPTION VALUE="Baz">Baz</OPTION>
    # </SELECT>
=end
    alias scrolling_list popup_menu


=begin
=== SUBMIT BUTTON
  submit
    # <INPUT TYPE="submit">

  submit("ok")
    # <INPUT TYPE="submit" VALUE="ok">

  submit("ok", "button1")
    # <INPUT TYPE="submit" VALUE="ok" NAME="button1">

  submit({ "VALUE" => "ok", "NAME" => "button1", "ID" => "foo" })
    # <INPUT TYPE="submit" VALUE="ok" NAME="button1" ID="foo">
=end
    def submit(value = nil, name = nil)
      attributes = if (not value) or value.kind_of?(String)
                     { "TYPE" => "submit", "VALUE" => value, "NAME" => name }
                   else
                     value["TYPE"] = "submit"
                     value
                   end
      input(attributes)
    end


=begin
=== TEXT_FIELD
  text_field("name")
    # <INPUT TYPE="text" NAME="name" SIZE="40">

  text_field("name", "value")
    # <INPUT TYPE="text" NAME="name" VALUE="value" SIZE="40">

  text_field("name", "value", 80)
    # <INPUT TYPE="text" NAME="name" VALUE="value" SIZE="80">

  text_field("name", "value", 80, 200)
    # <INPUT TYPE="text" NAME="name" VALUE="value" SIZE="80" MAXLENGTH="200">

  text_field({ "NAME" => "name", "VALUE" => "value" })
    # <INPUT TYPE="text" NAME="name" VALUE="value">
=end
    def text_field(name = "", value = nil, size = 40, maxlength = nil)
      attributes = if name.kind_of?(String)
                     { "TYPE" => "text", "NAME" => name, "VALUE" => value,
                       "SIZE" => size.to_s }
                   else
                     name["TYPE"] = "text"
                     name
                   end
      attributes["MAXLENGTH"] = maxlength.to_s if maxlength
      input(attributes)
    end


=begin
=== TEXTAREA ELEMENT
  textarea("name")
    # = textarea({ "NAME" => "name", "COLS" => 70, "ROWS" => 10 })

  textarea("name", 40, 5)
    # = textarea({ "NAME" => "name", "COLS" => 40, "ROWS" => 5 })
=end
    def textarea(name = "", cols = 70, rows = 10)
      attributes = if name.kind_of?(String)
                     { "NAME" => name, "COLS" => cols.to_s,
                       "ROWS" => rows.to_s }
                   else
                     name
                   end
      if block_given?
        super(attributes){ yield }
      else
        super(attributes)
      end
    end

  end # HtmlExtension


  module Html3

    def doctype
      %|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">|
    end

    def element_init
      extend TagMaker
      methods = ""
      # - -
      for element in %w[ A TT I B U STRIKE BIG SMALL SUB SUP EM STRONG
          DFN CODE SAMP KBD VAR CITE FONT ADDRESS DIV center MAP
          APPLET PRE XMP LISTING DL OL UL DIR MENU SELECT table TITLE
          STYLE SCRIPT H1 H2 H3 H4 H5 H6 TEXTAREA FORM BLOCKQUOTE
          CAPTION ]
        methods += <<-BEGIN + nn_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end

      # - O EMPTY
      for element in %w[ IMG BASE BASEFONT BR AREA LINK PARAM HR INPUT
          ISINDEX META ]
        methods += <<-BEGIN + nOE_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end

      # O O or - O
      for element in %w[ HTML HEAD BODY P PLAINTEXT DT DD LI OPTION tr
          th td ]
        methods += <<-BEGIN + nO_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end
      eval(methods)
    end

  end # Html3


  module Html4

    def doctype
      %|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">|
    end

    def element_init
      extend TagMaker
      methods = ""
      # - -
      for element in %w[ TT I B BIG SMALL EM STRONG DFN CODE SAMP KBD
        VAR CITE ABBR ACRONYM SUB SUP SPAN BDO ADDRESS DIV MAP OBJECT
        H1 H2 H3 H4 H5 H6 PRE Q INS DEL DL OL UL LABEL SELECT OPTGROUP
        FIELDSET LEGEND BUTTON TABLE TITLE STYLE SCRIPT NOSCRIPT
        TEXTAREA FORM A BLOCKQUOTE CAPTION ]
        methods += <<-BEGIN + nn_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end

      # - O EMPTY
      for element in %w[ IMG BASE BR AREA LINK PARAM HR INPUT COL META ]
        methods += <<-BEGIN + nOE_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end

      # O O or - O
      for element in %w[ HTML BODY P DT DD LI OPTION THEAD TFOOT TBODY
          COLGROUP TR TH TD HEAD]
        methods += <<-BEGIN + nO_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end
      eval(methods)
    end

  end # Html4


  module Html4Tr

    def doctype
      %|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">|
    end

    def element_init
      extend TagMaker
      methods = ""
      # - -
      for element in %w[ TT I B U S STRIKE BIG SMALL EM STRONG DFN
          CODE SAMP KBD VAR CITE ABBR ACRONYM FONT SUB SUP SPAN BDO
          ADDRESS DIV CENTER MAP OBJECT APPLET H1 H2 H3 H4 H5 H6 PRE Q
          INS DEL DL OL UL DIR MENU LABEL SELECT OPTGROUP FIELDSET
          LEGEND BUTTON TABLE IFRAME NOFRAMES TITLE STYLE SCRIPT
          NOSCRIPT TEXTAREA FORM A BLOCKQUOTE CAPTION ]
        methods += <<-BEGIN + nn_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end

      # - O EMPTY
      for element in %w[ IMG BASE BASEFONT BR AREA LINK PARAM HR INPUT
          COL ISINDEX META ]
        methods += <<-BEGIN + nOE_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end

      # O O or - O
      for element in %w[ HTML BODY P DT DD LI OPTION THEAD TFOOT TBODY
          COLGROUP TR TH TD HEAD ]
        methods += <<-BEGIN + nO_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end
      eval(methods)
    end

  end # Html4Tr


  module Html4Fr

    def doctype
      %|<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">|
    end

    def element_init
      methods = ""
      # - -
      for element in %w[ FRAMESET ]
        methods += <<-BEGIN + nn_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end

      # - O EMPTY
      for element in %w[ FRAME ]
        methods += <<-BEGIN + nOE_element_def(element) + <<-END
          def #{element.downcase}(attributes = {})
        BEGIN
          end
        END
      end
      eval(methods)
    end

  end # Html4Fr


  def initialize(type = "query")
    if defined?(MOD_RUBY) && !ENV.key?("GATEWAY_INTERFACE")
      Apache.request.setup_cgi_env
    end

    extend QueryExtension
    if "POST" != env_table['REQUEST_METHOD']
      initialize_query()  # set @params, @cookies
    else
      if defined?(CGI_PARAMS)
        @params  = CGI_PARAMS.nil?  ? nil : CGI_PARAMS.dup
        @cookies = CGI_COOKIES.nil? ? nil : CGI_COOKIES.dup
      else
        initialize_query()  # set @params, @cookies
        eval "CGI_PARAMS  = @params.nil?  ? nil : @params.dup"
        eval "CGI_COOKIES = @cookies.nil? ? nil : @cookies.dup"
        if defined?(MOD_RUBY) and (RUBY_VERSION < "1.4.3")
          raise "Please, use ruby1.4.3 or later."
        else
          at_exit() do
            if defined?(CGI_PARAMS)
              self.class.class_eval("remove_const(:CGI_PARAMS)")
              self.class.class_eval("remove_const(:CGI_COOKIES)")
            end
          end
        end
      end
    end
    @output_cookies = nil
    @output_hidden = nil

    case type
    when "html3"
      extend Html3
      element_init()
      extend HtmlExtension
    when "html4"
      extend Html4
      element_init()
      extend HtmlExtension
    when "html4Tr"
      extend Html4Tr
      element_init()
      extend HtmlExtension
    when "html4Fr"
      extend Html4Tr
      element_init()
      extend Html4Fr
      element_init()
      extend HtmlExtension
    end

  end
end


=begin

== HISTORY

delete. see cvs log.


=end

# vi:set tw=0:
