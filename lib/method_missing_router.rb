require "method_missing_router/version"

module MethodMissingRouter
  def self.included(base)
    base.extend(MethodMissing)
    base.send(:include, MethodMissing)
    base.extend(ClassMethods)
    base.reset_method_missing_routes!
  end


  module MethodMissing
    def method_missing(method_name, *args, &block)
      call_info = CallInfo.new(self, method_name, *args, &block)
      method_missing_routes.each do |route|
        return route.run(call_info) if route.applies_to?(call_info.method_name)
      end
      super(method_name, *args, &block)
    end

    def method_missing_routes
      if self.kind_of?(Class)
        self.instance_variable_get("@class_method_missing_routes")
      else 
        self.class.instance_variable_get("@method_missing_routes")
      end
    end
  end


  module ClassMethods
    def class_route_missing(matcher, target, options={})
      @class_method_missing_routes << Route.new(matcher, target, options)
    end

    def route_missing(matcher, target, options={})
      @method_missing_routes << Route.new(matcher, target, options)
    end

    def reset_method_missing_routes!
      @method_missing_routes = []
      @class_method_missing_routes = []
    end
  end

  class Route
    def initialize(regex, target, options)
      @regex = regex
      @target = target
      @options = options
    end

    def applies_to?(method_name)
      @regex =~ method_name
    end

    def run(call_info)
      call_info.prepend_argument(message_for(call_info.method_name))
      return call_info.object.send(@target, *call_info.args, &call_info.block)
    end

    def message_for(method_name)
      captures = @regex.match(method_name).captures
      if @options[:pass_matches]
        return captures
      elsif @options[:pass_match]
        return captures.first 
      else
        return method_name.to_s
      end
    end
  end

  class CallInfo
    attr_accessor :object, :method_name, :args, :block
    def initialize(object, method_name, *args, &block)
      @object = object
      @method_name = method_name
      @args = args
      @block = block
    end

    def prepend_argument(new_arg)
      @args.unshift(new_arg)
    end
  end
end
