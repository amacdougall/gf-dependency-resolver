require "minitest/autorun"
require "./lib/component"
require "./lib/dependency_resolver"
require "./lib/errors"

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

  def test_mutual_dependency
    # Fortunately, we aren't testing for cyclical dependencies.
    @resolver.depend("computer", "hdd")
    assert_raises MutualDependencyError do
      @resolver.depend("hdd", "computer")
    end
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

  def test_install_without_dependencies
    installed_list = @resolver.install("ram")

    assert @resolver.known.has_key?("ram"),
      "DependencyResolver#install should create component if not known."

    ram = @resolver.known["ram"]

    assert @resolver.installed.include?(ram),
      "DependencyResolver#install should add the component to #installed."
    assert ram.explicit?,
      "DependencyResolver#install should make the target component explicit."
    assert_equal [ram], installed_list,
      "DependencyResolver#install should return a list of installed components."
  end

  def test_install_with_single_dependency
    @resolver.depend("computer", "ram")
    installed_list = @resolver.install("computer")

    assert @resolver.known.has_key?("computer")
    assert @resolver.known.has_key?("ram")

    computer = @resolver.known["computer"]
    ram = @resolver.known["ram"]

    assert @resolver.installed.include?(computer),
      "DependencyResolver#install should add the component to #installed."
    assert @resolver.installed.include?(ram),
      "DependencyResolver#install should add the dependency to #installed."
    assert computer.explicit?,
      "DependencyResolver#install should make the target component explicit."
    refute ram.explicit?,
      "DependencyResolver#install should not make the target component explicit."
    assert installed_list.include?(computer),
      "Installed list should include target component."
    assert installed_list.include?(ram),
      "Installed list should include dependency."
    assert computer.explicit?
    refute ram.explicit?
  end

  def test_install_list_when_dependency_already_satisfied
    @resolver.depend("computer", "ram")
    @resolver.install("ram")
    installed_list = @resolver.install("computer")

    computer = @resolver.known["computer"]
    ram = @resolver.known["ram"]

    assert_equal [computer], installed_list,
      "Installed list should include only the target if its single dep was already satisfied."
    assert computer.explicit?
    assert ram.explicit?
  end

  def test_redundant_explicit_install
    @resolver.install("hdd")
    assert_raises AlreadyAddedError do
      @resolver.install("hdd")
    end
  end

  def test_install_with_multiple_dependencies
    # create multi-level dependency
    @resolver.depend("sauce", "tomato", "onion", "water")
    @resolver.depend("pasta", "flour", "egg", "water")
    @resolver.depend("lasagna", "sauce", "pasta")

    @resolver.install("egg") # to prove it is not in the installed list
    installed_list = @resolver.install("lasagna")

    lasagna = @resolver.known["lasagna"]
    sauce = @resolver.known["sauce"]
    tomato = @resolver.known["tomato"]
    onion = @resolver.known["onion"]
    water = @resolver.known["water"]
    flour = @resolver.known["flour"]
    egg = @resolver.known["egg"]

    [lasagna, sauce, tomato, onion, water, flour, egg].all? do |ingredient|
      assert @resolver.installed.include?(ingredient),
        "DependencyResolver#install should install all dependencies: failed on #{ingredient.name}"
    end
    refute installed_list.include?(egg)
  end

  def test_simple_remove
    @resolver.install("computer")
    removed_list = @resolver.remove("computer")

    assert @resolver.known.has_key?("computer")

    computer = @resolver.known["computer"]

    refute @resolver.installed.include?("computer"),
      "DependencyResolver#remove should remove component from the installed list"
    assert_equal [computer], removed_list,
      "DependencyResolver#remove should return the removed component"
  end

  def test_remove_when_not_installed
    assert_raises NotInstalledError do
      @resolver.remove("computer")
    end
  end

  def test_remove_required_dependency
    @resolver.depend("computer", "ram")
    @resolver.install("computer")

    assert_raises RequiredDependencyError do
      @resolver.remove("ram")
    end
  end

  def test_remove_implicit_dependency
    @resolver.depend("computer", "ram")
    @resolver.install("computer")

    ram = @resolver.known["ram"]

    removed_list = @resolver.remove("computer")

    refute @resolver.installed.include?(ram)
    assert removed_list.include?(ram)
  end

  def test_list
    @resolver.install("ram")
    @resolver.install("hdd")

    assert @resolver.list.map(&:name).include?("ram")
    assert @resolver.list.map(&:name).include?("hdd")
  end
end
