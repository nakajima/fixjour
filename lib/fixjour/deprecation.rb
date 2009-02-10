module Fixjour
  module Deprecation
    module MergingProxy
      def process(*args)
        raise DeprecatedMergeAttempt.new(<<-END
        You are attempting to call process on the class proxy.
        This behavior was recently deprecated. In order to process
        the overrides hash, pass two block arguments:

          define_builder(Foo) do |klass, overrides|
            overrides.process(:bar) do |bar|
              overrides[:bar] = 'overridden'
            end

            klass.new(:name => 'fizz')
          end
        END
        )
      end
    end
  end
end

Fixjour::MergingProxy.send :include, Fixjour::Deprecation::MergingProxy