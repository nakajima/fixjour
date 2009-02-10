module Fixjour
  # Raised when a builder returns an invalid object.
  class InvalidBuilder < StandardError; end
  
  # Raised when a builder will return an invalid object
  # due to a validates_uniqueness_of validation.
  class DangerousBuilder < StandardError; end
  
  # Raised when a builder returns an object that cannot
  # be saved the database.
  class UnsavableBuilder < StandardError; end
  
  # Raised when a builder returns an object of the wrong type
  class WrongBuilderType < StandardError; end
  
  # Raised when a builder block saves the object.
  class BuilderSavedRecord < StandardError; end
  
  # Raised when a Fixjour creation method is called in
  # the wrong context.
  class NonBlockBuilderReference < StandardError; end
  
  # Raised when a builder is defined for a class that already
  # has one.
  class RedundantBuilder < StandardError; end
  
  # Raised when a builder is defined with one block argument and
  # the user assumes that it's the overrides hash. This used to
  # be the standard behavior, but now blocks with one argument
  # are passed the class proxy, and getting access to the overrides
  # hash requires you pass two block arguments.
  class DeprecatedMergeAttempt < StandardError; end
end