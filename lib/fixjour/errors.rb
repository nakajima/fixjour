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
end