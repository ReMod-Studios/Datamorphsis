# frozen_string_literal: true

def log(str)
  puts "[Datamorphsis] #{str}"
end

class String
  def /(str)
    "#{self}/#{str}"
  end
end

$IN = Dir.pwd / 'in'
$OUT = Dir.pwd / 'out'

def input_file(path, mode = 'r')
  File.open($IN / path, mode)
end

def output_file(path, mode = 'w')
  File.open($OUT / path, mode)
end

class Task
  attr_accessor :input_dir, :output_dir, :inputs, :exec

  def initialize(&b)
    instance_exec &b if block_given?
  end

  def run
    require_relative @exec
    process
  end
end
