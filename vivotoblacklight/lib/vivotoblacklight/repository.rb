# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
require 'cgi'
module Vivotoblacklight
  class Repository < Blacklight::Solr::Repository
  ##
     # Find a single solr document result (by id) using the document configuration
     # @param [String] document's unique key value
     # @param [Hash] additional solr query parameters
     def find id, params = {}
       puts "Repository - find id"
       #Special id handling
       if params["DocId"]
          id = params["DocId"]
          #Rails.logger.debugger("Solr Repository = Using DocID #{id.inspect}")
          #id is already a value being sent in, so just use that
#       else 
#            id ||= params[:id]
       end
       
       doc_params = params.reverse_merge(blacklight_config.default_document_solr_params)
                          .reverse_merge(qt: blacklight_config.document_solr_request_handler)
                          .merge(blacklight_config.document_unique_id_param => id)
 
       solr_response = send_and_receive blacklight_config.document_solr_path || blacklight_config.solr_path, doc_params
       raise Blacklight::Exceptions::RecordNotFound.new if solr_response.documents.empty?
       solr_response
     end
  
end
end