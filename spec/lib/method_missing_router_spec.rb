require 'spec_helper'

describe MethodMissingRouter do
  context 'class method routing' do
    example 'route any missing message to the same target' do
      class TestMissingMethodRouter
        include MethodMissingRouter
        class_route_missing(/.*/, :every_message)

        def self.every_message
        end
      end
      TestMissingMethodRouter.should_receive(:every_message)
      TestMissingMethodRouter.blammo
    end
  end

  context 'instance method routing' do
    example 'route any missing message to the same target' do
      class TestMissingMethodRouter
        include MethodMissingRouter
        route_missing(/.*/, :every_message)

        def every_message
        end
      end
      test = TestMissingMethodRouter.new
      test.should_receive(:every_message)
      test.blammo
    end
  end
end
