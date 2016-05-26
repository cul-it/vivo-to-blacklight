# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
#As described here https://github.com/projectblacklight/blacklight/wiki/Providing-your-own-view-templates
#This module helps with handling URIs from VIVO and can be packated into a reusable gem for integrating VIVO with Blacklight.
module Vivotoblacklight
module UrlHelper
  include Blacklight::UrlHelperBehavior
  ##
  # Extension point for downstream applications
  # to provide more interesting routing to
  # documents
  
  # We are overriding this to enable passing the DocId parameter in the url should the DocId field exist
  #The code we are overriding looks the same within 5.16.3
  
  def url_for_document doc, options = {}
    require 'cgi'
    if respond_to?(:blacklight_config) and
        blacklight_config.show.route and
        (!doc.respond_to?(:to_model) or doc.to_model.is_a? SolrDocument)
      route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
      route[:controller] = controller_name if route[:controller] == :current
      route
    else
      # This branch is the one executed for a search results index page 
      if doc and doc["DocId"]
        # IF doc exists and has this field
        # One mechanism is to return the doc itself (Ruby can recognize that it is an object and create the appropriate url)
        # In that case, the url would be catalog/id
        # but here, we want to ensure we pass the DocId parameter and we are escaping the ID in the parameter 
        # Additionally, we tried updating the doc id to be the escaped uri, but that did  not work correctly
        # What we are doing here is passing the local name (which has no slashes, etc. that could throw either apache or ruby off)
        # and then utilizing the normal behavior for showing a document but passing in the parameter as well
        # Code on the solr document helper side knows to expect that parameter and utilize that for the solr document id if it exists
        # Not passing in a local name in the url would make the code expect this was some search query, and without a query it jsut
        # goes back to the front page
        id = doc["DocId"]
        local_name = get_uri_localname(id)
        "/catalog/" + local_name + "?DocId=" + id
       else       
         #Does what this code would do without our updates 
        doc                      
      end
    end
  end

#  # We are overriding this to enable passing the DocId parameter in the url should the DocId field exist
  def url_for_bookmark doc, options = {}
    require 'cgi'
    
    if doc and doc["DocId"]
      # if doc exists and has this field
      id = doc["DocId"]
      layer = doc["layercodename_display"]
      local_name = get_uri_localname(id)
      "/bookmarks/" + local_name + "?DocId=" + id + "&layerId=" + layer.to_s
     else       
       #Does what this code would do without our updates 
      doc                      
    end
  end

  
  #We need to override this method - the internals have changed for the most recent Blacklight versions (after 5.9.3) so will need to recheck this later
  #track_solr_document_path is a Rails _path mechanism which gives the path for a named route (track_solr_document) which corresponds to the catalog/id/track
  #url used with a post method.  For a given search result URL, handleSearchContextMethod defined in search_context.js captures the click event on the link and 
  # uses the data-context-href attribute to build a form where the URL is the redirect action and the data-context-href attribute is the post URL (i.e. track solr document).
  #More recent Rails versions appear to return a URL encoded form for the URL, so instead of catalog/vitroIndividual:http://nyclimateclearinghouse.org/individual/n14187/track?counter=1&search_id=171945
  #you get catalog/vitroIndividual:http:%2F%2Fnyclimateclearinghouse.org%2Findividual%2Fn14187/track?counter=1&search_id=171945 which encounters problems.
  #The method below is responsible for generating the data-context-href attribute and is being overridden to return the local name (i.e. the last part)
  #of the URI since the actual URI is passed as a DocId parameter for the show view and is not used for anything else within the track action itself
  #with Apache routing. 
  ##
   # Attributes for a link that gives a URL we can use to track clicks for the current search session
   # @param [SolrDocument] document
   # @param [Integer] counter
   # @example
   #   session_tracking_params(SolrDocument.new(id: 123), 7)
   #   => { data: { :'tracker-href' => '/catalog/123/track?counter=7&search_id=999' } }
   def session_tracking_params document, counter
     if document.nil?
       return {}
     end
     track_path =   track_solr_document_path(document, per_page: params.fetch(:per_page, search_session['per_page']), counter: counter, search_id: current_search_session.try(:id))
     #get local name and replace the full encoded URI with the local name, i.e. catalog/localname/track, the actual URI is sent as an input from the form to the track page
     if(document["DocId"])
      local_name = get_uri_localname(document["DocId"])
      track_path = track_path.gsub(/(?<=\/catalog\/)(.*)(?=\/track.*)/,local_name)
     end
     { :data => {:'context-href' => track_path}}
   end
   protected :session_tracking_params
   
   def get_uri_localname(id)
     uri_sliced = id.split("/")
     local_name = uri_sliced.last
     return local_name
   end
   

  
end
end