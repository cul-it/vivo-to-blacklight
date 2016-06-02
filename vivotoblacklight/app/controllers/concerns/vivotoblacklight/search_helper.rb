# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
require 'cgi'
module Vivotoblacklight::SearchHelper 
  extend ActiveSupport::Concern

  include Blacklight::SearchHelper

  puts "VBL:SearchHelper in concerns"
  #OVerriding repository here
  def repository_class
    #Rails.logger.debug("Defining repository class from config ? #{blacklight_config.repository_class.inspect}")
    Vivotoblacklight::Repository
  end
  
  #Fetch a single id
  def fetch_one(id, extra_controller_params)
    puts "fetch one search helper"
    old_solr_doc_params = Deprecation.silence(Blacklight::SearchHelper) do
      solr_doc_params(id)
    end

    if default_solr_doc_params(id) != old_solr_doc_params
      Deprecation.warn Blacklight::SearchHelper, "The #solr_doc_params method is deprecated. Instead, you should provide a custom SolrRepository implementation for the additional behavior you're offering. The current behavior will be removed in Blacklight 6.0"
      extra_controller_params = extra_controller_params.merge(old_solr_doc_params)
    end
    
    #Override id
    if params["DocId"]
        id = params["DocId"]
        #Rails.logger.debug("Found DocID #{params['DocId'].inspect} and id is #{id.inspect}")
     else 
        id ||= params[:id]
        #Rails.logger.debug("Using other id")
     end
    

    solr_response = repository.find id, extra_controller_params
    [solr_response, solr_response.documents.first]
  end
  

  
end
