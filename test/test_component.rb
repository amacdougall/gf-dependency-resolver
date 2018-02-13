require "set"
require "minitest/autorun"
require "./lib/component"

class TestComponent < MiniTest::Unit::TestCase
  def setup
    @ram = Component.new(name: "ram")
    @hdd = Component.new(name: "hdd")
    @computer = Component.new(name: "computer", dependencies: [@ram, @hdd])
  end

  def test_initialize_without_dependencies
    assert_equal "ram", @ram.name
    assert_empty @ram.dependencies
    refute @ram.explicit
  end

  def test_initialize_with_dependencies
    assert_equal "computer", @computer.name
    assert @computer.dependencies.include?(@ram)
    assert @computer.dependencies.include?(@hdd)
    refute @computer.explicit
  end

  def test_initialize_with_explicit
    joystick = Component.new(name: "joystick", explicit: true)
    assert_equal "joystick", joystick.name
    assert joystick.explicit
  end

  def test_all_dependencies
    # create multi-level dependency
    tomato = Component.new(name: "tomato")
    onion = Component.new(name: "onion")
    flour = Component.new(name: "flour")
    egg = Component.new(name: "egg")
    water = Component.new(name: "water")

    sauce = Component.new(name: "sauce", dependencies: [tomato, onion, water])
    pasta = Component.new(name: "pasta", dependencies: [flour, egg, water])

    lasagna = Component.new(name: "lasagna", dependencies: [sauce, pasta])

    assert lasagna.all_dependencies.is_a?(Array),
      "Component#all_dependencies should be an array"

    refute lasagna.all_dependencies.empty?,
      "Component#all_dependencies should not be empty when there are dependencies"

    assert_equal [tomato, onion, flour, egg, water, sauce, pasta].to_set,
      lasagna.all_dependencies.to_set,
      "all_dependencies should include ancestor dependencies, uniqued"
  end
end
