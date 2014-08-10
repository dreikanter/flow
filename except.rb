require 'pp'

class Exception
  def backtrace
    'hello'
  end

  def message
    'message'
  end
end

def one
  two
end

def two
  three
end

def three
  1 / 0
end

one
