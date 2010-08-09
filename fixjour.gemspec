# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{fixjour}
  s.version = "0.5.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Pat Nakajima"]
  s.date = %q{2008-12-29}
  s.email = %q{patnakajima@gmail.com}
  s.files = ["README.textile", "Rakefile", "fixjour.gemspec", "lib/core_ext/hash.rb", "lib/core_ext/object.rb", "lib/fixjour.rb", "lib/fixjour/builder.rb", "lib/fixjour/builders.rb", "lib/fixjour/counter.rb", "lib/fixjour/define.rb", "lib/fixjour/definitions.rb", "lib/fixjour/deprecation.rb", "lib/fixjour/errors.rb", "lib/fixjour/generator.rb", "lib/fixjour/merging_proxy.rb", "lib/fixjour/overrides_hash.rb", "lib/fixjour/redundant_check.rb", "lib/fixjour/verify.rb", "spec/builder_spec.rb", "spec/define_spec.rb", "spec/dev.rip", "spec/edge_cases_spec.rb", "spec/fixjour_spec.rb", "spec/merging_proxy_spec.rb", "spec/overrides_hash_spec.rb", "spec/spec_helper.rb", "spec/verify_spec.rb"]
  s.homepage = %q{http://github.com/nakajima/fixjour}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Object creation methods everyone already has}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activerecord>, [">= 0"])
      s.add_development_dependency(%q<faker>, [">= 0"])
      s.add_development_dependency(%q<acts_as_fu>, [">= 0"])
    else
      s.add_dependency(%q<activerecord>, [">= 0"])
      s.add_dependency(%q<faker>, [">= 0"])
      s.add_dependency(%q<acts_as_fu>, [">= 0"])
    end
  else
    s.add_dependency(%q<activerecord>, [">= 0"])
    s.add_dependency(%q<faker>, [">= 0"])
    s.add_dependency(%q<acts_as_fu>, [">= 0"])
  end
end
