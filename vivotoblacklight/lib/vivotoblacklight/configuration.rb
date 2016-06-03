module Vivotoblacklight
  #Configuration requires the following attributes to be set/read
  #VIVO_APP_URL, VIVO_SPARQLAPI
  #The class that stores the configuration information
  class Configuration
    attr_reader :vivo_app_url
    attr_reader :vivo_sparql_api
    
    def initialize
      #These need to be set by the application itself
      @vivo_app_url = nil
      @vivo_sparql_api = nil
    end
    
    def vivo_app_url=(vivo_app_url_value)
      @vivo_app_url = vivo_app_url_value
    end
    
    def vivo_sparql_api=(vivo_sparql_api_value)
      @vivo_sparql_api = vivo_sparql_api_value
    end
    


    
  end
  
  
  #Setting configuration variables on the gem
  class << self
    attr_accessor :configuration
  end
  
  def self.configuration
        @configuration ||= Configuration.new
      end

  def self.configure
      yield(configuration)
  end
  
end