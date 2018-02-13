require "set"

##
# A component of the dependency graph. Contains attributes:
#
# name: A string.
# dependencies: A Set of Component instances.
# explicit: Boolean. Default false.
#
class Component
  attr_accessor :name, :dependencies, :explicit

  def initialize(options)
    @name = options[:name]
    @dependencies = Set.new # a Set of Component instances

    # if dependencies are provided, add each to the required set
    if options[:dependencies]
      options[:dependencies].each {|d| @dependencies << d}
    end

    @explicit = options[:explicit] || false
  end

  # Returns a unique array of both immediate and ancestor dependencies.
  def all_dependencies
    (self.dependencies.to_a + self.dependencies.map(&:all_dependencies)).flatten.uniq
  end

  def explicit?
    @explicit
  end

  def to_s
    @name
  end
end
