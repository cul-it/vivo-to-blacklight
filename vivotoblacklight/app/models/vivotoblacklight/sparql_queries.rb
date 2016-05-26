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
  @@query_definitions = {"highlights" => "PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>  
    PREFIX rdfs:     <http://www.w3.org/2000/01/rdf-schema#>  
    PREFIX xsd:      <http://www.w3.org/2001/XMLSchema#>  
    PREFIX owl:      <http://www.w3.org/2002/07/owl#>  
    PREFIX ccsc:      <" + Rails.application.config.VIVONamespace + "ontology/>  
    PREFIX bibo:     <http://purl.org/ontology/bibo/>  
    SELECT ?collectionTitle ?collectionAbstract ?collectionImageDownloadURI ?collectionImageDirectDownloadURL ?collectionImageCaption ?collectionImageSource ?resourceURI ?resourceTitle ?resourceImageDownloadURI ?resourceImageDirectDownloadURL ?resourceRank
    WHERE { 
      ?collectionURI rdfs:label ?collectionTitle. 
      OPTIONAL {  ?collectionURI bibo:abstract ?collectionAbstract . } 
      OPTIONAL { 
            ?collectionURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#mainImage> ?imageURI .  
            ?imageURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#downloadLocation> ?collectionImageDownloadURI . 
            ?collectionImageDownloadURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#directDownloadUrl> ?collectionImageDirectDownloadURL .
            OPTIONAL { ?imageURI rdfs:label ?collectionImageCaption . } 
            OPTIONAL { ?imageURI ccsc:source ?collectionImageSource . } 
      }     
      OPTIONAL {
        ?collectionURI <http://vivoweb.org/ontology/core#relatedBy> ?collectionMembership .
        ?resourceURI <http://vivoweb.org/ontology/core#relatedBy> ?collectionMembership .
        ?collectionMembership rdf:type <" + Rails.application.config.VIVONamespace + "ontology/CollectionMembership> . 
        ?collectionMembership <http://vivoweb.org/ontology/core#rank> ?resourceRank .
        ?resourceURI rdfs:label ?resourceTitle .  
        OPTIONAL { 
          ?resourceURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#mainImage> ?resourceImageURI .   
          ?resourceImageURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#downloadLocation> ?resourceImageDownloadURI . 
          ?resourceImageDownloadURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#directDownloadUrl> ?resourceImageDirectDownloadURL .
        }

          FILTER (?resourceURI != ?collectionURI)   
      }
    } ORDER BY ?resourceRank",
    "documents" => "PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>  
    PREFIX rdfs:     <http://www.w3.org/2000/01/rdf-schema#>  
    PREFIX xsd:      <http://www.w3.org/2001/XMLSchema#>  
    PREFIX owl:      <http://www.w3.org/2002/07/owl#>  
    PREFIX ccsc:     <" + Rails.application.config.VIVONamespace + "ontology/>  
    PREFIX bibo:     <http://purl.org/ontology/bibo/>  
    PREFIX vivo:     <http://vivoweb.org/ontology/core#>  
    PREFIX fn: <http://www.w3.org/2005/xpath-functions#> 
    SELECT                    
                ?resourceURI 
                ?resourceTitle 
                (group_concat(distinct ?resourceAltTitle;separator=\"|||\") as ?resourceAltTitles) 
                ?resourceAbstract 
                ?resourcePublisher 
                ?resourcePublicationDate 
                ?resourcePublicationDatePrecisionURI 
                ?resourceImageDownloadURI  
                ?resourceImageDirectDownloadURL
                ?resourceRank
                  (group_concat(DISTINCT(fn:concat(\"URL=\",?urlLink, \",Title=\",?urlTitle, \",Type=\", ?urlType, \",Rank=\", ?urlRank));separator=\"|||\") AS ?urlInfo)
   WHERE { 
    ?collectionURI <http://vivoweb.org/ontology/core#relatedBy> ?collectionMembership .
        ?resourceURI <http://vivoweb.org/ontology/core#relatedBy> ?collectionMembership .
        ?collectionMembership rdf:type <" + Rails.application.config.VIVONamespace + "ontology/CollectionMembership> . 
        ?collectionMembership <http://vivoweb.org/ontology/core#rank> ?resourceRank .
    ?resourceURI rdfs:label ?resourceTitle .  
      OPTIONAL { 
        ?resourceURI bibo:abstract ?resourceAbstract .   
      } 
      OPTIONAL {
        ?resourceURI ccsc:alternateTitle ?resourceAltTitle . 
      }
      OPTIONAL { 
        ?resourceURI vivo:publisher ?resourcePublisherURI .   
        ?resourcePublisherURI rdfs:label ?resourcePublisher .  
      } 
      OPTIONAL { 
        ?resourceURI vivo:dateTimeValue ?resourcePublicationDateURI .  
        ?resourcePublicationDateURI vivo:dateTime ?resourcePublicationDate .  
        ?resourcePublicationDateURI vivo:dateTimePrecision ?resourcePublicationDatePrecisionURI .  
      } 
      OPTIONAL { 
        ?resourceURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#mainImage> ?resourceImageURI .   
        ?resourceImageURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#downloadLocation> ?resourceImageDownloadURI . 
        ?resourceImageDownloadURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#directDownloadUrl> ?resourceImageDirectDownloadURL .
      }     
      
      OPTIONAL {
      ?resourceURI <http://purl.obolibrary.org/obo/ARG_2000028> ?vcard .
      ?vcard <http://www.w3.org/2006/vcard/ns#hasURL> ?url . 
      ?url <http://www.w3.org/2006/vcard/ns#url> ?urlLink . 
      ?url <http://www.w3.org/2000/01/rdf-schema#label> ?urlTitle . 
      ?url <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#mostSpecificType> ?urlType . 
      ?url <http://vivoweb.org/ontology/core#rank> ?urlRank . 
      }
      FILTER (?resourceURI != ?collectionURI)

}
GROUP BY ?resourceURI ?resourceTitle ?resourceAbstract ?resourcePublisher ?resourcePublicationDate ?resourcePublicationDatePrecisionURI ?resourceImageDownloadURI ?resourceImageDirectDownloadURL ?resourceRank
ORDER BY ?resourceRank
",
  "data-maps" => "PREFIX rdf:      <http://www.w3.org/1999/02/22-rdf-syntax-ns#>  
    PREFIX rdfs:     <http://www.w3.org/2000/01/rdf-schema#>  
    PREFIX xsd:      <http://www.w3.org/2001/XMLSchema#>  
    PREFIX owl:      <http://www.w3.org/2002/07/owl#>  
    PREFIX ccsc:     <" + Rails.application.config.VIVONamespace + "ontology/>  
    PREFIX bibo:     <http://purl.org/ontology/bibo/>  
    PREFIX vivo:     <http://vivoweb.org/ontology/core#>  
    PREFIX fn: <http://www.w3.org/2005/xpath-functions#> 
    SELECT                
      ?resourceURI 
      ?resourceTitle 
      (group_concat(distinct ?resourceAltTitle;separator=\"|||\") as ?resourceAltTitles)
      ?resourceAbstract 
      (group_concat(DISTINCT(fn:concat(\"serviceURI=\",?resourceServiceProvidedByURI,\",serviceLabel=\",?resourceServiceProvidedByLabel));separator=\"|\") AS ?serviceProviders)
      ?resourceImageDownloadURI  
      ?resourceImageDirectDownloadURL
      ?resourceRank
      (group_concat(DISTINCT(fn:concat(\"URL=\",?urlLink, \",Title=\",?urlTitle, \",Type=\", ?urlType, \",Rank=\", ?urlRank));separator=\"|||\") AS ?urlInfo)
    WHERE {
          ?collectionURI <http://vivoweb.org/ontology/core#relatedBy> ?collectionMembership .
          ?resourceURI <http://vivoweb.org/ontology/core#relatedBy> ?collectionMembership .
          ?collectionMembership rdf:type <" + Rails.application.config.VIVONamespace + "ontology/CollectionMembership> . 
          ?collectionMembership <http://vivoweb.org/ontology/core#rank> ?resourceRank .
      ?resourceURI rdfs:label ?resourceTitle .  
      OPTIONAL { 
        ?resourceURI bibo:abstract ?resourceAbstract .  
      } 
      OPTIONAL {
        ?resourceURI ccsc:alternateTitle ?resourceAltTitle . 
      }
      OPTIONAL { 
        ?resourceURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#mainImage> ?resourceImageURI .   
        ?resourceImageURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#downloadLocation> ?resourceImageDownloadURI . 
        ?resourceImageDownloadURI <http://vitro.mannlib.cornell.edu/ns/vitro/public#directDownloadUrl> ?resourceImageDirectDownloadURL .

      }     
      OPTIONAL {
        ?resourceURI <http://purl.obolibrary.org/obo/ARG_2000028> ?vcard .
        ?vcard <http://www.w3.org/2006/vcard/ns#hasURL> ?url . 
        ?url <http://www.w3.org/2006/vcard/ns#url> ?urlLink . 
        ?url <http://www.w3.org/2000/01/rdf-schema#label> ?urlTitle . 
        ?url <http://vitro.mannlib.cornell.edu/ns/vitro/0.7#mostSpecificType> ?urlType . 
        ?url <http://vivoweb.org/ontology/core#rank> ?urlRank . 
      }
      OPTIONAL {
        ?resourceURI <http://purl.obolibrary.org/obo/ERO_0000390> ?resourceServiceProvidedByURI .
        ?resourceServiceProvidedByURI rdfs:label ?resourceServiceProvidedByLabel .
      }
  
      FILTER (?resourceURI != ?collectionURI)   
    }
    GROUP BY ?resourceURI ?resourceTitle ?resourceAbstract ?resourceImageDownloadURI ?resourceImageDirectDownloadURL ?resourceRank
   ORDER BY ?resourceRank"
  }


  ##Setting up the sparql query
  #This defaults to highlights if nothing is passed
  def initialize()
    puts "sparql query"
    puts Rails.application.config.VIVONamespace
    options = {:method => :get}
    #Sparql API should be specified in app_constants
    @sparql = SPARQL::Client.new(ENV["VIVO_SPARQLAPI"]  , options)
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
    if(@sparql != nil and @@query_definitions.has_key?(query_id))
      @query = @@query_definitions[query_id]
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
   
       if(@sparql != nil and @@query_definitions.has_key?(query_id))
         @query = @@query_definitions[query_id]
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

end
end