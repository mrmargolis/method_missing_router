require 'spec_helper'

class TestMissingMethodRouter
  include MethodMissingRouter
end

describe MethodMissingRouter do
  let(:test_class) { TestMissingMethodRouter }

  after(:each) do
    test_class.reset_method_missing_routes!
  end

  context 'class method routing' do
    it 'can route any missing message to the same target' do
      test_class.class_route_missing(/.+/, :every_message)
      test_class.should_receive(:every_message).twice
      test_class.blammo
      test_class.dragon_soda
    end

    it 'can route two different formats of message to different targets' do
      test_class.class_route_missing(/^fish/, :fish_message)
      test_class.class_route_missing(/[a-z]+/, :lowercase_message)

      test_class.should_receive(:fish_message)
      test_class.should_receive(:lowercase_message)

      test_class.fish_powers_activate
      test_class.somelowercaseletters
    end

    it 'passes the original message name as the first argument' do
      test_class.class_route_missing(/^fire\_the\_/, :fire_weapon)
      test_class.should_receive(:fire_weapon).with(:fire_the_lazer, {:power => 11})
      test_class.fire_the_lazer(:power => 11)
    end

    it 'passes undeclared messages to super' do
      expect{test_class.something_unexpected}.to raise_error(NoMethodError)
    end
  end

  context 'instance method routing' do
    let(:test_instance) { test_class.new }

    it 'can route any missing message to the same target' do
      test_class.route_missing(/.*/, :every_message)
      test_instance.should_receive(:every_message).twice

      test_instance.blammo
      test_instance.dragon_soda
    end

    it 'can route two different formats of message to different targets' do
      test_class.route_missing(/^cow/, :cow_message)
      test_class.route_missing(/in_a_bag$/, :in_a_bag)

      test_instance.should_receive(:cow_message)
      test_instance.should_receive(:in_a_bag)

      test_instance.cowsplode
      test_instance.pudding_in_a_bag
    end

    it 'passes the original message name as the first argument' do
      test_class.route_missing(/^fire\_the\_/, :fire_weapon)
      test_instance.should_receive(:fire_weapon).with(:fire_the_lazer, {:power => 11})
      test_instance.fire_the_lazer(:power => 11)
    end

    it 'passes undeclared messages to super' do
      expect{test_instance.something_unexpected}.to raise_error(NoMethodError)
    end
  end
end
