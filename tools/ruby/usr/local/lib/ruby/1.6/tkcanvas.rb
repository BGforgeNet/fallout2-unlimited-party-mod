
#		tkcanvas.rb - Tk canvas classes
#			$Date: 2002/02/28 06:52:49 $
#			by Yukihiro Matsumoto <matz@caelum.co.jp>
#			$Date: 2002/02/28 06:52:49 $
#			by Hidetoshi Nagai <nagai@ai.kyutech.ac.jp>

require "tk"
require 'tkfont'

module TkTreatCItemFont
  include TkTreatItemFont

  ItemCMD = ['itemconfigure', TkComm::None]
  def __conf_cmd(idx)
    ItemCMD[idx]
  end

  def __item_pathname(tagOrId)
    if tagOrId.kind_of?(TkcItem) || tagOrId.kind_of?(TkcTag)
      self.path + ';' + tagOrId.id.to_s
    else
      self.path + ';' + tagOrId.to_s
    end
  end
end

class TkCanvas<TkWindow
  include TkTreatCItemFont
  include Scrollable

  WidgetClassName = 'Canvas'.freeze
  WidgetClassNames[WidgetClassName] = self
  def self.to_eval
    WidgetClassName
  end

  def create_self(keys)
    if keys and keys != None
      tk_call 'canvas', @path, *hash_kv(keys)
    else
      tk_call 'canvas', @path
    end
  end

  def tagid(tag)
    if tag.kind_of?(TkcItem) || tag.kind_of?(TkcTag)
      tag.id
    else
      tag
    end
  end
  private :tagid

  def addtag(tag, mode, *args)
    tk_send 'addtag', tagid(tag), mode, *args
  end
  def addtag_above(tagOrId, target)
    addtag(tagOrId, 'above', tagid(target))
  end
  def addtag_all(tagOrId)
    addtag(tagOrId, 'all')
  end
  def addtag_below(tagOrId, target)
    addtag(tagOrId, 'below', tagid(target))
  end
  def addtag_closest(tagOrId, x, y, halo=None, start=None)
    addtag(tagOrId, 'closest', x, y, halo, start)
  end
  def addtag_enclosed(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'enclosed', x1, y1, x2, y2)
  end
  def addtag_overlapping(tagOrId, x1, y1, x2, y2)
    addtag(tagOrId, 'overlapping', x1, y1, x2, y2)
  end
  def addtag_withtag(tagOrId, tag)
    addtag(tagOrId, 'withtag', tagid(tag))
  end

  def bbox(tagOrId, *tags)
    list(tk_send('bbox', tagid(tagOrId), *tags.collect{|t| tagid(t)}))
  end

  def itembind(tag, context, cmd=Proc.new, args=nil)
    _bind([path, "bind", tagid(tag)], context, cmd, args)
  end

  def itembind_append(tag, context, cmd=Proc.new, args=nil)
    _bind_append([path, "bind", tagid(tag)], context, cmd, args)
  end

  def itembindinfo(tag, context=nil)
    _bindinfo([path, "bind", tagid(tag)], context)
  end

  def canvasx(x, *args)
    tk_tcl2ruby(tk_send 'canvasx', x, *args)
  end
  def canvasy(y, *args)
    tk_tcl2ruby(tk_send 'canvasy', y, *args)
  end

  def coords(tag, *args)
    if args == []
      tk_split_list(tk_send('coords', tagid(tag)))
    else
      tk_send('coords', tagid(tag), *args)
    end
  end

  def dchars(tag, first, last=None)
    tk_send 'dchars', tagid(tag), first, last
  end

  def delete(*args)
    tk_send 'delete', *args.collect{|t| tagid(t)}
  end
  alias remove delete

  def dtag(tag, tag_to_del=None)
    tk_send 'dtag', tagid(tag), tag_to_del
  end

  def find(mode, *args)
    list(tk_send 'find', mode, *args).collect!{|id| 
      TkcItem.id2obj(self, id)
    }
  end
  def find_above(target)
    find('above', tagid(target))
  end
  def find_all
    find('all')
  end
  def find_below(target)
    find('below', tagid(target))
  end
  def find_closest(x, y, halo=None, start=None)
    find('closest', x, y, halo, start)
  end
  def find_enclosed(x1, y1, x2, y2)
    find('enclosed', x1, y1, x2, y2)
  end
  def find_overlapping(x1, y1, x2, y2)
    find('overlapping', x1, y1, x2, y2)
  end
  def find_withtag(tag)
    find('withtag', tag)
  end

  def itemfocus(tagOrId=nil)
    if tagOrId
      tk_send 'focus', tagid(tagOrId)
    else
      ret = tk_send('focus')
      if ret == ""
	nil
      else
	TkcItem.id2obj(self, ret)
      end
    end
  end

  def gettags(tagOrId)
    list(tk_send('gettags', tagid(tagOrId))).collect{|tag|
      TkcTag.id2obj(self, tag)
    }
  end

  def icursor(tagOrId, index)
    tk_send 'icursor', tagid(tagOrId), index
  end

  def index(tagOrId, index)
    tk_send 'index', tagid(tagOrId), index
  end

  def insert(tagOrId, index, string)
    tk_send 'insert', tagid(tagOrId), index, string
  end

  def itemcget(tagOrId, option)
    case option
    when 'dash', 'activedash', 'disableddash'
      conf = tk_send('itemcget', tagid(tagOrId), "-#{option}")
      if conf =~ /^[0-9]/
	list(conf)
      else
	conf
      end
    when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
      tk_send 'itemcget', tagid(tagOrId), "-#{option}"
    else
      tk_tcl2ruby tk_send 'itemcget', tagid(tagOrId), "-#{option}"
    end
  end

  def itemconfigure(tagOrId, key, value=None)
    if key.kind_of? Hash
      if ( key['font'] || key['kanjifont'] \
	  || key['latinfont'] || key['asciifont'] )
	tagfont_configure(tagOrId, key.dup)
      else
	tk_send 'itemconfigure', tagid(tagOrId), *hash_kv(key)
      end

    else
      if ( key == 'font' || key == 'kanjifont' \
	  || key == 'latinfont' || key == 'asciifont' )
	tagfont_configure(tagid(tagOrId), {key=>value})
      else
	tk_send 'itemconfigure', tagid(tagOrId), "-#{key}", value
      end
    end
  end
#  def itemconfigure(tagOrId, key, value=None)
#    if key.kind_of? Hash
#      tk_send 'itemconfigure', tagid(tagOrId), *hash_kv(key)
#    else
#      tk_send 'itemconfigure', tagid(tagOrId), "-#{key}", value
#    end
#  end
#  def itemconfigure(tagOrId, keys)
#    tk_send 'itemconfigure', tagid(tagOrId), *hash_kv(keys)
#  end

  def itemconfiginfo(tagOrId, key=nil)
    if key
      case key
      when 'dash', 'activedash', 'disableddash'
	conf = tk_split_simplelist(tk_send 'itemconfigure', 
				   tagid(tagOrId), "-#{key}")
	if conf[3] && conf[3] =~ /^[0-9]/
	  conf[3] = list(conf[3])
	end
	if conf[4] && conf[4] =~ /^[0-9]/
	  conf[4] = list(conf[4])
	end
      when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
	conf = tk_split_simplelist(tk_send 'itemconfigure', 
				   tagid(tagOrId), "-#{key}")
      else
	conf = tk_split_list(tk_send 'itemconfigure', 
			     tagid(tagOrId), "-#{key}")
      end
      conf[0] = conf[0][1..-1]
      conf
    else
      tk_split_simplelist(tk_send 'itemconfigure', 
			  tagid(tagOrId)).collect{|conflist|
	conf = tk_split_simplelist(conflist)
	conf[0] = conf[0][1..-1]
	case conf[0]
	when 'text', 'label', 'show', 'data', 'file', 'maskdata', 'maskfile'
	when 'dash', 'activedash', 'disableddash'
	  if conf[3] && conf[3] =~ /^[0-9]/
	    conf[3] = list(conf[3])
	  end
	  if conf[4] && conf[4] =~ /^[0-9]/
	    conf[4] = list(conf[4])
	  end
	else
	  if conf[3]
	    if conf[3].index('{')
	      conf[3] = tk_split_list(conf[3]) 
	    else
	      conf[3] = tk_tcl2ruby(conf[3]) 
	    end
	  end
	  if conf[4]
	    if conf[4].index('{')
	      conf[4] = tk_split_list(conf[4]) 
	    else
	      conf[4] = tk_tcl2ruby(conf[4]) 
	    end
	  end
	end
	conf
      }
    end
  end

  def lower(tag, below=None)
    tk_send 'lower', tagid(tag), tagid(below)
  end

  def move(tag, x, y)
    tk_send 'move', tagid(tag), x, y
  end

  def postscript(keys)
    tk_send "postscript", *hash_kv(keys)
  end

  def raise(tag, above=None)
    tk_send 'raise', tagid(tag), tagid(above)
  end

  def scale(tag, x, y, xs, ys)
    tk_send 'scale', tagid(tag), x, y, xs, ys
  end

  def scan_mark(x, y)
    tk_send 'scan', 'mark', x, y
  end
  def scan_dragto(x, y)
    tk_send 'scan', 'dragto', x, y
  end

  def select(mode, *args)
    tk_send 'select', mode, *args
  end
  def select_adjust(tagOrId, index)
    select('adjust', tagid(tagOrId), index)
  end
  def select_clear
    select('clear')
  end
  def select_from(tagOrId, index)
    select('from', tagid(tagOrId), index)
  end
  def select_item
    select('item')
  end
  def select_to(tagOrId, index)
    select('to', tagid(tagOrId), index)
  end

  def itemtype(tag)
    TkcItem.type2class(tk_send 'type', tagid(tag))
  end
end

module TkcTagAccess
  include TkComm
  include TkTreatTagFont

  def addtag(tag)
    @c.addtag(tag, 'with', @id)
  end

  def bbox
    @c.bbox(@id)
  end

  def bind(seq, cmd=Proc.new, args=nil)
    @c.itembind @id, seq, cmd, args
  end

  def bindinfo(seq=nil)
    @c.itembindinfo @id, seq
  end

  def cget(option)
    @c.itemcget @id, option
  end

  def configure(key, value=None)
    @c.itemconfigure @id, key, value
  end
#  def configure(keys)
#    @c.itemconfigure @id, keys
#  end

  def configinfo(key=nil)
    @c.itemconfiginfo @id, key
  end

  def coords(*args)
    @c.coords @id, *args
  end

  def dchars(first, last=None)
    @c.dchars @id, first, last
  end

  def dtag(tag_to_del=None)
    @c.dtag @id, tag_to_del
  end

  def find
    @c.find 'withtag', @id
  end
  alias list find

  def focus
    @c.itemfocus @id
  end

  def gettags
    @c.gettags @id
  end

  def icursor(index)
    @c.icursor @id, index
  end

  def index(index)
    @c.index @id, index
  end

  def insert(beforethis, string)
    @c.insert @id, beforethis, string
  end

  def lower(belowthis=None)
    @c.lower @id, belowthis
  end

  def move(xamount, yamount)
    @c.move @id, xamount, yamount
  end

  def raise(abovethis=None)
    @c.raise @id, abovethis
  end

  def scale(xorigin, yorigin, xscale, yscale)
    @c.scale @id, xorigin, yorigin, xscale, yscale
  end

  def select_adjust(index)
    @c.select('adjust', @id, index)
  end
  def select_from(index)
    @c.select('from', @id, index)
  end
  def select_to(index)
    @c.select('to', @id, index)
  end

  def itemtype
    @c.itemtype @id
  end

  # Followings operators supports logical expressions of canvas tags
  # (for Tk8.3+).
  # If tag1.path is 't1' and tag2.path is 't2', then
  #      ltag = tag1 & tag2; ltag.path => "(t1)&&(t2)"
  #      ltag = tag1 | tag2; ltag.path => "(t1)||(t2)"
  #      ltag = tag1 ^ tag2; ltag.path => "(t1)^(t2)"
  #      ltag = - tag1;      ltag.path => "!(t1)"
  def & (tag)
    if tag.kind_of? TkObject
      TkcTagString.new(@c, '(' + @id + ')&&(' + tag.path + ')')
    else
      TkcTagString.new(@c, '(' + @id + ')&&(' + tag.to_s + ')')
    end
  end

  def | (tag)
    if tag.kind_of? TkObject
      TkcTagString.new(@c, '(' + @id + ')||(' + tag.path + ')')
    else
      TkcTagString.new(@c, '(' + @id + ')||(' + tag.to_s + ')')
    end
  end

  def ^ (tag)
    if tag.kind_of? TkObject
      TkcTagString.new(@c, '(' + @id + ')^(' + tag.path + ')')
    else
      TkcTagString.new(@c, '(' + @id + ')^(' + tag.to_s + ')')
    end
  end

  def -@
    TkcTagString.new(@c, '!(' + @id + ')')
  end
end

class TkcTag<TkObject
  include TkcTagAccess

  CTagID_TBL = {}

  def TkcTag.id2obj(canvas, id)
    cpath = canvas.path
    return id unless CTagID_TBL[cpath]
    CTagID_TBL[cpath][id]? CTagID_TBL[cpath][id]: id
  end

  Tk_CanvasTag_ID = ['ctag0000']
  def initialize(parent, mode=nil, *args)
    if not parent.kind_of?(TkCanvas)
      fail format("%s need to be TkCanvas", parent.inspect)
    end
    @c = parent
    @cpath = parent.path
    @path = @id = Tk_CanvasTag_ID[0]
    CTagID_TBL[@cpath] = {} unless CTagID_TBL[@cpath]
    CTagID_TBL[@cpath][@id] = self
    Tk_CanvasTag_ID[0] = Tk_CanvasTag_ID[0].succ
    if mode
      tk_call @c.path, "addtag", @id, mode, *args
    end
  end
  def id
    return @id
  end

  def delete
    @c.delete @id
    CTagID_TBL[@path][@id] = nil if CTagID_TBL[@path]
  end
  alias remove  delete
  alias destroy delete

  def set_to_above(target)
    @c.addtag_above(@id, target)
  end
  alias above set_to_above

  def set_to_all
    @c.addtag_all(@id)
  end
  alias all set_to_all

  def set_to_below(target)
    @c.addtag_below(@id, target)
  end
  alias below set_to_below

  def set_to_closest(x, y, halo=None, start=None)
    @c.addtag_closest(@id, x, y, halo, start)
  end
  alias closest set_to_closest

  def set_to_enclosed(x1, y1, x2, y2)
    @c.addtag_enclosed(@id, x1, y1, x2, y2)
  end
  alias enclosed set_to_enclosed

  def set_to_overlapping(x1, y1, x2, y2)
    @c.addtag_overlapping(@id, x1, y1, x2, y2)
  end
  alias overlapping set_to_overlapping

  def set_to_withtag(target)
    @c.addtag_withtag(@id, target)
  end
  alias withtag set_to_withtag
end

class TkcTagString<TkcTag
  def self.new(parent, name, *args)
    if CTagID_TBL[parent.path] && CTagID_TBL[parent.path][name]
      return CTagID_TBL[parent.path][name]
    else
      super(parent, name, *args)
    end
  end

  def initialize(parent, name, mode=nil, *args)
    if not parent.kind_of?(TkCanvas)
      fail format("%s need to be TkCanvas", parent.inspect)
    end
    @c = parent
    @cpath = parent.path
    @path = @id = name
    CTagID_TBL[@cpath] = {} unless CTagID_TBL[@cpath]
    CTagID_TBL[@cpath][@id] = self
    if mode
      tk_call @c.path, "addtag", @id, mode, *args
    end
  end
end

class TkcTagAll<TkcTag
  def initialize(parent)
    if not parent.kind_of?(TkCanvas)
      fail format("%s need to be TkCanvas", parent.inspect)
    end
    @c = parent
    @cpath = parent.path
    @path = @id = 'all'
    CTagID_TBL[@cpath] = {} unless CTagID_TBL[@cpath]
    CTagID_TBL[@cpath][@id] = self
  end
end

class TkcTagCurrent<TkcTag
  def initialize(parent)
    if not parent.kind_of?(TkCanvas)
      fail format("%s need to be TkCanvas", parent.inspect)
    end
    @c = parent
    @cpath = parent.path
    @path = @id = 'current'
    CTagID_TBL[@cpath] = {} unless CTagID_TBL[@cpath]
    CTagID_TBL[@cpath][@id] = self
  end
end

class TkcGroup<TkcTag
  Tk_cGroup_ID = ['tkcg00000']
  def create_self(parent, *args)
    if not parent.kind_of?(TkCanvas)
      fail format("%s need to be TkCanvas", parent.inspect)
    end
    @c = parent
    @cpath = parent.path
    @path = @id = Tk_cGroup_ID[0]
    CTagID_TBL[@cpath] = {} unless CTagID_TBL[@cpath]
    CTagID_TBL[@cpath][@id] = self
    Tk_cGroup_ID[0] = Tk_cGroup_ID[0].succ
    add(*args) if args != []
  end
  
  def include(*tags)
    for i in tags
      i.addtag @id
    end
  end

  def exclude(*tags)
    for i in tags
      i.delete @id
    end
  end
end

class TkcItem<TkObject
  include TkcTagAccess

  CItemTypeToClass = {}
  CItemID_TBL = {}

  def TkcItem.type2class(type)
    CItemTypeToClass[type]
  end

  def TkcItem.id2obj(canvas, id)
    cpath = canvas.path
    return id unless CItemID_TBL[cpath]
    CItemID_TBL[cpath][id]? CItemID_TBL[cpath][id]: id
  end

  def initialize(parent, *args)
    if not parent.kind_of?(TkCanvas)
      fail format("%s need to be TkCanvas", parent.inspect)
    end
    @parent = @c = parent
    @path = parent.path
    fontkeys = {}
    if args[-1].kind_of? Hash
      args = args.dup
      keys = args.pop
      ['font', 'kanjifont', 'latinfont', 'asciifont'].each{|key|
	fontkeys[key] = keys.delete(key) if keys.key?(key)
      }
      args += hash_kv(keys)
    end
    @id = create_self(*args).to_i ;# 'canvas item id' is integer number
    CItemID_TBL[@path] = {} unless CItemID_TBL[@path]
    CItemID_TBL[@path][@id] = self
    font_configure(fontkeys) unless fontkeys.empty?

######## old version
#    if args[-1].kind_of? Hash
#      keys = args.pop
#    end
#    @id = create_self(*args).to_i ;# 'canvas item id' is integer number
#    CItemID_TBL[@path] = {} unless CItemID_TBL[@path]
#    CItemID_TBL[@path][@id] = self
#    if keys
#      # tk_call @path, 'itemconfigure', @id, *hash_kv(keys)
#      configure(keys) if keys
#    end
########
  end
  def create_self(*args); end
  private :create_self
  def id
    return @id
  end

  def delete
    @c.delete @id
    CItemID_TBL[@path][@id] = nil if CItemID_TBL[@path]
  end
  alias remove  delete
  alias destroy delete
end

class TkcArc<TkcItem
  CItemTypeToClass['arc'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'arc', *args)
  end
end
class TkcBitmap<TkcItem
  CItemTypeToClass['bitmap'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'bitmap', *args)
  end
end
class TkcImage<TkcItem
  CItemTypeToClass['image'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'image', *args)
  end
end
class TkcLine<TkcItem
  CItemTypeToClass['line'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'line', *args)
  end
end
class TkcOval<TkcItem
  CItemTypeToClass['oval'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'oval', *args)
  end
end
class TkcPolygon<TkcItem
  CItemTypeToClass['polygon'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'polygon', *args)
  end
end
class TkcRectangle<TkcItem
  CItemTypeToClass['rectangle'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'rectangle', *args)
  end
end
class TkcText<TkcItem
  CItemTypeToClass['text'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'text', *args)
  end
end
class TkcWindow<TkcItem
  CItemTypeToClass['window'] = self
  def create_self(*args)
    tk_call(@path, 'create', 'window', *args)
  end
end

class TkImage<TkObject
  include Tk

  Tk_IMGTBL = {}

  Tk_Image_ID = ['i00000']
  def initialize(keys=nil)
    @path = Tk_Image_ID[0]
    Tk_Image_ID[0] = Tk_Image_ID[0].succ
    tk_call 'image', 'create', @type, @path, *hash_kv(keys)
    Tk_IMGTBL[@path] = self
  end

  def delete
    Tk_IMGTBL[@id] = nil if @id
    tk_call('image', 'delete', @path)
  end
  def height
    number(tk_call('image', 'height', @path))
  end
  def inuse
    bool(tk_call('image', 'inuse', @path))
  end
  def itemtype
    tk_call('image', 'type', @path)
  end
  def width
    number(tk_call('image', 'width', @path))
  end

  def TkImage.names
    Tk.tk_call('image', 'names').split.collect!{|id|
      (Tk_IMGTBL[id])? Tk_IMGTBL[id] : id
    }
  end

  def TkImage.types
    Tk.tk_call('image', 'types').split
  end
end

class TkBitmapImage<TkImage
  def initialize(*args)
    @type = 'bitmap'
    super
  end
end

class TkPhotoImage<TkImage
  def initialize(*args)
    @type = 'photo'
    super
  end

  def blank
    tk_send 'blank'
  end

  def cget(option)
    case option
    when 'data', 'file'
      tk_send 'cget', option
    else
      tk_tcl2ruby tk_send 'cget', option
    end
  end

  def copy(source, *opts)
    args = opts.collect{|term|
      if term.kind_of?(String) && term.include?(?\s)
	term.split
      else
	term
      end
    }.flatten

    tk_send 'copy', source, *args
  end

  def data(keys=nil)
    tk_send 'data', *hash_kv(keys)
  end

  def get(x, y)
    tk_send 'get', x, y
  end

  def put(data, *to)
    if to == []
      tk_send 'put', data
    else
      tk_send 'put', data, '-to', *to
    end
  end

  def read(file, *opts)
    args = opts.collect{|term|
      if term.kind_of?(String) && term.include?(?\s)
	term.split
      else
	term
      end
    }.flatten
  
    tk_send 'read', file, *args
  end

  def redither
    tk_send 'redither'
  end

  def write(file, *opts)
    args = opts.collect{|term|
      if term.kind_of?(String) && term.include?(?\s)
	term.split
      else
	term
      end
    }.flatten
  
    tk_send 'write', file, *args
  end
end
