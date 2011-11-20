require "method_missing_router/version"
module MethodMissingRouter
  def self.included(base)
    base.extend(ClassMethods)
    base.instance_variable_set("@class_method_missing_routes", [])
    base.instance_variable_set("@method_missing_routes", [])
  end

  def method_missing(meth, *args, &block)
    self.class.instance_variable_get("@method_missing_routes").each do |matcher, target|
      self.send(target, *args, &block) if matcher =~ meth
    end
  end

  module ClassMethods
    def class_route_missing(matcher, target)
      @class_method_missing_routes << [matcher, target]
    end

    def route_missing(matcher, target)
      @method_missing_routes << [matcher, target]
    end

    def method_missing(meth, *args, &block)
      @class_method_missing_routes.each do |matcher, target|
        self.send(target, *args, &block) if matcher =~ meth
      end
    end
  end
end
