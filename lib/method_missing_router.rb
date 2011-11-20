require "method_missing_router/version"
module MethodMissingRouter
  def self.included(base)
    base.extend(ClassMethods)
    base.reset_method_missing_routes!
    base.instance_variable_set("@class_method_missing_routes", [])
    base.instance_variable_set("@method_missing_routes", [])
  end

  def method_missing(meth, *args, &block)
    self.class.instance_variable_get("@method_missing_routes").each do |matcher, target|
      return self.send(target, *args, &block) if matcher =~ meth
    end
    super(meth, *args, &block)
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

    def method_missing(meth, *args, &block)
      @class_method_missing_routes.each do |matcher, target|
        if matcher =~ meth
          return self.send(target, *args, &block)
        end
      end
      super(meth, *args, &block)
    end
  end
end
