require "set"
require "./lib/component"

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
        dependency = Component.new(name: dep_name)
        @known[dep_name] = dependency
      end
      @known[name].dependencies << dependency
    end
  end
end
