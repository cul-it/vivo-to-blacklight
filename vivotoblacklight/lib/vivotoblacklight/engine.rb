module Vivotoblacklight
  class Engine < ::Rails::Engine
    isolate_namespace Vivotoblacklight
    
    initializer "engine.initialize" do |app|
     
      #config.VIVONamespace = app.config.VIVONamespace
    end
    
  end
end
