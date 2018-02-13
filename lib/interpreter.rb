require "./lib/dependency_resolver"
require "./lib/errors"

##
# Accepts string inputs for the DependencyResolver.
class Interpreter
  def initialize
    @resolver = DependencyResolver.new
  end

  def execute(s)
    tokens = s.scan(/\w+/)

    command = tokens.shift
    arguments = tokens

    output = ""

    case command
    when "DEPEND"
      begin
        @resolver.depend(*arguments) # no output on success
      rescue MutualDependencyError => e
        output = e.to_s
      end
    when "INSTALL"
      begin
        installed_list = @resolver.install(*arguments)
        installed_list.each do |item|
          output << "Installing #{item.name}\n"
        end
      rescue AlreadyAddedError => e
        output = e.to_s
      end
    when "REMOVE"
      begin
        removed_list = @resolver.remove(*arguments)
        removed_list.each do |item|
          output << "Removing #{item.name}\n"
        end
      rescue NotInstalledError => e
        output = e.message
      rescue RequiredDependencyError => e
        output = e.message
      end
    when "LIST"
      list = @resolver.list.map(&:name)
      list.each do |item|
        output << "#{item}\n"
      end
    when "END"
      output = ""
    else
      output = "Invalid command '#{s}'."
    end

    output
  end
end

