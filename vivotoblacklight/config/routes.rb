Rails.application.routes.draw do
  # specific paths like this one were being mapped to catalog/id instead and trying to get a specific solr document
   # because we removed constraints on id? (see below)
   get 'catalog/facet/:id', to: 'catalog#facet'
 
   #allow any characters for id (since SOLR IDs are URIs)
   #this already exists - how to add constraints to preexisting route
   blacklight_for:catalog, :constraints => {:id => /|.*/}
end
