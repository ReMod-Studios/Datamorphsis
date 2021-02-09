
class Identifier
  attr_reader :namespace, :path

  def initialize(*args)
    #TODO regex checks
    case args.size
    when 2
      (namespace, path) = args
    when 1
      split = args[0].split(':')
      split.prepend 'minecraft' if split.size < 2
      (namespace, path) = split
    else
      raise ArgumentError('incorrect parameters! expected either one or two strings')
    end
    unless namespace.match /[a-z0-9_.-]+/ and path.match /[a-z0-9\/._-]+/
      raise ArgumentError('illegal parameters!')
    end
    @namespace = namespace
    @path = path
    end

  def ==(other)
    @namespace == other.namespace && @path == other.path
  end

  def to_s
    "#{@namespace}:#{@path}"
  end

  def to_str
    to_s
  end

  def inspect
    to_s
  end
end

class String
  def to_id
    Identifier.new(self)
  end
end
