require "method_missing_router/version"
module MethodMissingRouter
  def self.included(base)
    base.extend(Routing)
    base.send(:include, Routing)
    base.extend(ClassMethods)
    base.reset_method_missing_routes!
  end


  module Routing
    def method_missing_routes
      if self.kind_of?(Class)
        @class_method_missing_routes
      else 
        self.class.instance_variable_get("@method_missing_routes")
      end
    end

    def method_missing(meth, *args, &block)
      method_missing_routes.each do |matcher, target|
        args.unshift(meth)
        return self.send(target, *args, &block) if matcher =~ meth
      end
      super(meth, *args, &block)
    end
  end


  module ClassMethods
    def class_route_missing(matcher, target)
      @class_method_missing_routes << [matcher, target]
    end

    def route_missing(matcher, target)
      @method_missing_routes << [matcher, target]
    end

    def reset_method_missing_routes!
      @method_missing_routes = []
      @class_method_missing_routes = []
    end
  end
end
