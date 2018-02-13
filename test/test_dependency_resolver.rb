require "minitest/autorun"
require "./lib/component"
require "./lib/dependency_resolver"

class TestDependencyResolver < MiniTest::Unit::TestCase
  def setup
    @resolver = DependencyResolver.new
  end

  def test_depend_with_one_arg
    @resolver.depend("computer", "hdd")

    assert @resolver.known.has_key?("computer"), "Component was not added to resolver.known."
    assert @resolver.known.has_key?("hdd"), "Dependency was not added to resolver.known."

    hdd = @resolver.known["hdd"]
    computer = @resolver.known["computer"]

    assert computer.dependencies.include?(hdd), "Dependency was not added to component's dependencies."
  end

  def test_depend_with_several_args
    @resolver.depend("computer", "hdd", "ram")

    assert @resolver.known.has_key?("computer"),
      "Component was not added to resolver.known."
    assert @resolver.known.has_key?("hdd"),
      "First dependency was not added to resolver.known."
    assert @resolver.known.has_key?("ram"),
      "Second dependency was not added to resolver.known."

    hdd = @resolver.known["hdd"]
    ram = @resolver.known["ram"]
    computer = @resolver.known["computer"]

    assert computer.dependencies.include?(hdd),
      "First dependency was not added to component's dependencies."
    assert computer.dependencies.include?(ram),
      "Second dependency was not added to component's dependencies."
  end
end
