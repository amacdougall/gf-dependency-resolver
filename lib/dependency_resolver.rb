require "set"
require "./lib/component"
require "./lib/errors"

class DependencyResolver
  attr_accessor :known, :installed

  def initialize
    @known = {}
    @installed = Set.new
  end

  def depend(name, *dependencies)
    unless @known.has_key? name
      @known[name] = Component.new(name: name)
    end

    component = @known[name]

    # Separating the create and depend steps so we can check for mutual
    # dependencies among all deps first
    dependencies.each do |dep_name|
      unless @known.has_key? dep_name
        @known[dep_name] = Component.new(name: dep_name)
      end
    end

    dependencies.each do |dep_name|
      dependency = @known[dep_name]
      if dependency.dependencies.include?(component)
        raise MutualDependencyError.new("#{dependency} depends on #{component}. Ignoring command.")
      end
    end

    dependencies.each do |dep_name|
      @known[name].dependencies << @known[dep_name]
    end
  end

  # Installs the component with the supplied name. Returns an array of Component
  # objects which were newly installed as a result of this method call.
  #
  # If the target component is already installed, raises AlreadyAddedError.
  def install(name)
    unless @known.has_key? name
      @known[name] = Component.new(name: name)
    end

    component = @known[name]

    raise AlreadyAddedError if @installed.include?(component)

    component.explicit = true
    @installed << component
    newly_installed = [component]

    # Since @installed is a Set, we can << identical components all day long;
    # but we only want to notify when a component is newly installed, so we
    # have to check anyway.
    component.all_dependencies.each do |d|
      unless @installed.include?(d)
        newly_installed << d
      end
      @installed << d
    end

    newly_installed
  end

  ##
  # Removes the component with the supplied name, and any of its implicit
  # dependencies which are not supporting another component.
  #
  # If the component is not installed, raises NotInstalledError.
  #
  # If an installed component depends upon this component, raises
  # RequiredDependencyError.
  #
  def remove(name)
    unless @known[name] && @installed.include?(@known[name])
      raise NotInstalledError.new("#{name} is not installed.")
    end

    component = @known[name]

    # raise if anything depends upon this component
    if is_required(component)
      raise RequiredDependencyError.new("#{name} is still needed.")
    end

    # otherwise, remove this component:
    @installed.delete(component)
    removed_list = [component]

    # ...and any of its dependencies which are not required by anything else:
    component.all_dependencies.reject {|c| is_required(c)}.each do |c|
      unless c.explicit?
        @installed.delete(c)
        removed_list << c
      end
    end

    removed_list
  end

  ##
  # The list of installed Component instances.
  #
  def list
    @installed
  end

  private

  def is_required(component)
    @installed.any? {|c| c.dependencies.include?(component)}
  end
end
