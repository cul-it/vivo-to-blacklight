# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
# -*- encoding : utf-8 -*-
##Store mappings between files or terms and resource URIs
##This allows for making collections of collections of Solr documents/Ids that can then be retrieved
module Vivotoblacklight


class ResourceMappings
  #Format should be similar to 
  # @@highlightMappings = {
  #"group_page" => {
  #  "query_id" => "highlights",
  #  "docidlist" => {"1","2"}}}
 
  @@highlightMappings = {

  }

  def get_query_id(key) 
    highlight_mappings = get_highlight_mappings()
    return highlight_mappings.values_at(key).first.values_at('query_id').first
  end

  def get_properties(key) 
    highlight_mappings = get_highlight_mappings()
    return highlight_mappings.values_at(key).first.values_at('vivo_collections').first
  end
  
  def get_highlight_mappings
    return @@highlightMappings
  end
 
end
end