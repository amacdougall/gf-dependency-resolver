require "set"
require "./lib/component"
require "./lib/already_added_error"

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

    dependencies.each do |dep_name|
      unless @known.has_key? dep_name
        @known[dep_name] = Component.new(name: dep_name)
      end
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
end
