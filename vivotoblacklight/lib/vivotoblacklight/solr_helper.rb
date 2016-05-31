# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University

require 'cgi'
module Vivotoblacklight::SolrHelper 
  extend ActiveSupport::Concern

  include Blacklight::SolrHelper
  # returns a params hash for finding a single solr document (CatalogController #show action)
  # If the id arg is nil, then the value is fetched from params[:id]
  # This method is primary called by the get_solr_response_for_doc_id method.
  # returns a params hash for finding a single solr document (CatalogController #show action)
    # If the id arg is nil, then the value is fetched from params[:id]
    # This method is primary called by the get_solr_response_for_doc_id method.
    def solr_doc_params(id=nil)
      #Rails.logger.debug("Debugging in the solr_doc_params field!#{id}")
      if params["DocId"]
              id ||= params["DocId"]
           else 
                id ||= params[:id]
           end
           puts "SolrhelperGem solr_doc_params"
      # add our document id to the document_unique_id_param query parameter
      p = blacklight_config.default_document_solr_params.merge({
        # this assumes the request handler will map the unique id param
        # to the unique key field using either solr local params, the 
        # real-time get handler, etc.
        #:id => id # this assumes the document request handler will map the 'id' param to the unique key field
             # URL Escaping does not in fact work - at least not with the whole string with vitroIndividual:.. etc.
        blacklight_config.document_unique_id_param => id
        
      })
  
      p[:qt] ||= blacklight_config.document_solr_request_handler
      #If, instead of document handler, you want to use the regular
       # search  handler, the following will work
      #p = blacklight_config.default_document_solr_params.merge({
            #:id => id # this assumes the document request handler will map the 'id' param to the unique key field
            # URL Escaping does not in fact work - at least not with the whole string with vitroIndividual:.. etc.
       #     :q => "id:" + id
       #   })
        #Also, the p[:qt] above would be commented out  
     
      p
    end
 
  
    
  # a solr query method
  # retrieve a solr document, given the doc id
  # @return [Blacklight::SolrResponse, Blacklight::SolrDocument] the solr response object and the first document
  # We aren't really overriding the actual functionality here, but just utilzing logging here
  # to see what is actually being passed to Solr
    def get_solr_response_for_doc_id(id=nil, extra_controller_params={})
      puts "Solr helperGet solr response for doc"
     #Rails.logger.debug("Get solr response for doc id #{id.inspect} and #{extra_controller_params.inspect}")
     solr_params = solr_doc_params(id).merge(extra_controller_params)
     #Rails.logger.debug("Get solr response for doc, solr params now #{solr_params.inspect}")
     solr_response = find(blacklight_config.document_solr_path, solr_params)
     raise Blacklight::Exceptions::InvalidSolrID.new if solr_response.documents.empty?
     [solr_response, solr_response.documents.first]
   end
   
end