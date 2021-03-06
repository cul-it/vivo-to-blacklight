$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "vivotoblacklight/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "vivotoblacklight"
  s.version     = Vivotoblacklight::VERSION
  s.authors     = ["hudajkhan"]
  s.email       = ["hjk54@cornell.edu"]
  #s.homepage    = "homepage"
  s.summary     = "Summary of Vivotoblacklight."
  s.description = "Description of Vivotoblacklight."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

 s.add_dependency "rails"

 # s.add_development_dependency "sqlite3"
 s.add_dependency "blacklight"
end
