require "method_missing_router/version"

module MethodMissingRouter
  def self.included(base)
    base.extend(RoutedMethodMissing)
    base.send(:include, RoutedMethodMissing)
    base.extend(ClassMethods)
    base.reset_method_missing_routes!
  end


  module RoutedMethodMissing
    def respond_to_missing?(method_name, *)
      method_missing_routes.route_for(method_name) || super
    end

    private

    def method_missing(method_name, *args, &block)
      if route = method_missing_routes.route_for(method_name)
        call_info = CallInfo.new(self, route.target, *args, &block)
        call_info.prepend_argument(route.message_for(method_name))
        return call_info.call
      else
        super(method_name, *args, &block)
      end
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
      @method_missing_routes = RouteCollection.new
      @class_method_missing_routes = RouteCollection.new
    end
  end

  class RouteCollection
    def initialize
      @routes = []
    end

    def <<(item)
      @routes << item
    end

    def route_for(method_name)
      @routes.find{ |route | route.applies_to?(method_name) }
    end
  end

  class Route
    attr_reader :target

    def initialize(regex, target, options)
      @regex = regex
      @target = target
      @options = options
    end

    def applies_to?(method_name)
      @regex =~ method_name
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

    def call
      @object.send(method_name, *args, &block)
    end
  end
end
