class AlreadyAddedError < StandardError
end

class NotInstalledError < StandardError
end

class RequiredDependencyError < StandardError
end

class MutualDependencyError < StandardError
end
