require 'spec_helper'

describe "an example of instance routing with multiple matches" do
  class SpaceShip
    include MethodMissingRouter
    route_missing /^fire\_the\_(.+)_and_(.+)/, :fire_weapon, :pass_matches => true

    def fire_weapon(weapon_names, count)
      "firing #{count} #{weapon_names.first} and #{weapon_names.last}"
    end
  end

  it 'passes along the name of the weapon since we set pass matches' do
    ship = SpaceShip.new
    ship.fire_the_missiles_and_bacon(5).should == "firing 5 missiles and bacon"
  end
end


describe "an example of class routing with a single match" do
  class LetterCounter
    include MethodMissingRouter
    class_route_missing /([a-z])s/, :count_letter, :pass_match => true

    def self.count_letter(letter, string)
      string.count(letter)
    end
  end

  it 'passes along the letter since we set pass match' do
    LetterCounter.as('a string and another string').should == 3
  end
end


describe "an example of instance routing that doesn't override the message" do
  class Turtle
    include MethodMissingRouter
    route_missing /some_message/, :announce

    def announce(message)
      "message was #{message}"
    end
  end

  it 'passes along the original method name since we did not ask to pass the match(es)' do
    Turtle.new.some_message_fred.should == "message was some_message_fred"
  end
end
