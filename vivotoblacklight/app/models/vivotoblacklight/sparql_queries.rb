# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
# -*- encoding : utf-8 -*-

# Utilizing this model to setup the sparql queries we will be utilizing
# This model is for retrieving information from VIVO using SPARQL and portions will be incorporated into 
# a reusable gem for integrating VIVO information into Blacklight

module Vivotoblacklight

class SparqlQueries
  require 'sparql/client'
  ##The actual query strings
  ## format should be
  ##{"queryid" => "SPARQL Query"}
  @@query_definitions = {
  }


  ##Setting up the sparql query
  #This defaults to highlights if nothing is passed
  def initialize()
    puts "sparql query"
    puts Rails.application.config.VIVONamespace
    options = {:method => :get}
    #Sparql API should be specified in app_constants
    @sparql = SPARQL::Client.new(Vivotoblacklight.configuration.vivo_sparql_api  , options)
    if(@sparql == nil)
      Rails.logger.error("ERROR: Sparql client is nil")
    end
    #Prefer JSON results - plain text may have lead to encoding errors
    @queryoptions = {:content_type => SPARQL::Client::RESULT_JSON}
  end
  
  ##Pass collection keys array
  ##Return hash with collection hash key as the key
  def get_results(collection_hash, query_id = "highlights")
    results_hash = {}
    query_definitions = get_query_definitions()
    if(@sparql != nil and query_definitions.has_key?(query_id))
      @query = query_definitions[query_id]
      collection_hash.each do |collection_key, collection_URI|
        results_hash[collection_key] = get_cached_results(@sparql, collection_key, collection_URI, @query, @queryoptions)
      end
    else
      Rails.logger.error("sparql client is nil OR query_id #{query_id.inspect} does not exist in definitions")
    end 
   return results_hash
  end
  
  def get_cached_results(sparql_client, collection_key, collection_URI, query_val, queryoptions)
    cache_key = collection_key + "_sparql_results"
    query_output = get_sparql_query(query_val, collection_URI)
    Rails.cache.fetch(cache_key, :expires_in => 8.hours) do
      # Rails.logger.debug("Executing query within cache")
      query_final_val = get_sparql_query(query_val, collection_URI)
      sparql_client.query(query_final_val, queryoptions)
    end
  end
  
  #Replace query collectionURI variable with concrete collection URI
  def get_sparql_query(query_val, collection_URI)
    query_final_val = query_val.gsub("?collectionURI", "<" + collection_URI + ">")
    return query_final_val
  end
  
  #On startup and at other times, we want to write results to the cache even if the cache expiration hasn't yet occurred
  #Collection hash is the actual hashmap portion that needs to be used
  def load_results(collection_hash, query_id="highlights")
      query_definitions = get_query_definitions()
       if(@sparql != nil and query_definitions.has_key?(query_id))
         @query = query_definitions[query_id]
         collection_hash.each do |collection_key, collection_URI|
           write_cached_results(@sparql, collection_key, collection_URI, @query, @queryoptions)
         end
         #results = @sparql.query(@query, @queryoptions)
       else
         Rails.logger.error("sparql client is nil OR query_id #{query_id.inspect} does not exist in definitions")
       end 
     
  end
  
  #Write cached results for a particular sparql query
def write_cached_results(sparql_client, collection_key, collection_URI, query_val, queryoptions)
  cache_key = collection_key + "_sparql_results"
  query_output = get_sparql_query(query_val, collection_URI)
  query_final_val = get_sparql_query(query_val, collection_URI)
  #Writing query results
  query_results = sparql_client.query(query_final_val, queryoptions)
  Rails.cache.write(cache_key, query_results, :expires_in => 2.hours) 
end

def get_query_definitions
  return @@query_definitions
end

end
end