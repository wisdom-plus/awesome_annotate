# frozen_string_literal: true

require_relative "lib/awesome_annotate/version"

Gem::Specification.new do |spec|
  spec.name = "awesome_annotate"
  spec.version = AwesomeAnnotate::VERSION
  spec.authors = ["wisdom-plus"]
  spec.email = ["wisdom.plus.264.dev@gmail.com"]

  spec.summary = "annotate your code with comments"
  spec.description = "annotate your code with comments (e.g. model schema, routes, etc.)"
  spec.homepage = "https://github.com/wisdom-plus/awesome_annotate"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + "/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.add_dependency "thor"
  spec.add_dependency "activerecord", ">= 6.1.0"
end
