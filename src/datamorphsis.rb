# frozen_string_literal: true

#TODO use Logger
def log(str)
  puts "[Datamorphsis] #{str}"
end

module Datamorphsis
  class Process
    attr_reader :namespace

    require_relative 'task'

    def initialize(ns, &scope)
      @namespace = ns
      @in_dir = File.join Dir.pwd, 'in/assets', @namespace
      @out_dir = File.join Dir.pwd,  'out'
      instance_exec &scope
    end

    def task(name, &b)
      Task.new(self, name, &b)
    end
    def run_task(name, &b)
      Task.new(self, name, &b).send(:run)
      puts
    end
    def in_dir(*args)
      if args.empty?
        @in_dir
      else
        File.join @in_dir, args
      end
    end

    def out_dir(*args)
      if args.empty?
        @out_dir
      else
        File.join @out_dir, args
      end
    end
  end
end

def datamorphsis(ns, &scope)
  log 'Initializing...'

  Datamorphsis::Process.new(ns, &scope)
end
