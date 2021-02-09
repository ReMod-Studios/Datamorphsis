module Datamorphsis
  private
  class Task
    attr_reader :name, :parameters, :exec

    protected
    attr_writer :parameters, :exec

    class WorkPath
      attr_reader :rel

      def initialize(dir, path)
        @rel = path
        @path = File.join dir, path
      end

      def to_s
        @path
      end

      def to_str
        to_s
      end

      def inspect
        to_s
      end
    end

    class TaskBuilder
      def initialize(process)
        @process = process
        @parameters = {}
        @inputs = {}
        @outputs = {}
      end

      def inputs(arg)
        @inputs.update arg
      end

      def outputs(arg)
        @outputs.update arg
      end

      def parameters(arg)
        @parameters.update arg
      end

      def exec(exec)
        @exec = exec
      end

      def init(task)
        @inputs.transform_values! { |v| WorkPath.new(@process.in_dir, v) }
        @outputs.transform_values! { |v| WorkPath.new(@process.out_dir, v) }


        task.parameters.update @inputs
        task.parameters.update @outputs
        task.parameters.update @parameters
        task.send(:exec=, @exec)
      end
    end

    public
    def self.run(process, name, &b)
      Task.new(process, name, &b).run
    end

    def initialize(process, name, &b)
      @process = process
      @name = name
      @parameters = {}
      builder = TaskBuilder.new(process)
      builder.instance_exec &b if block_given?
      builder.init self
    end

    def run(*args)
      log "Executing task - #{@name}"
      #noinspection RubyResolve
      require_relative @exec
      process(*args)
    end

    def method_missing(method, *args, &block)
      return @parameters[method] if @parameters.key? method
      return @process.send(method, *args, &block) if @process.respond_to? method
      super method, *args, &block
    end
  end
end