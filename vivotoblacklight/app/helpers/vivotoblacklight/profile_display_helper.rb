# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
#Helper for viewing content from the VIVO Profile
# This helper module is used to process information retrieved from VIVO for display within Blacklight.  
# Portions of this module will be packaged into a reusable gem for integrating VIVO information into Blacklight.
module Vivotoblacklight

module ProfileDisplayHelper
  ##Return the default view for any property
  def get_default_property_view(property_info_object)
    if(property_info_object.has_key?("type"))
      type = property_info_object["type"]
      #if data property, output label with delimited list of statements
      if(type == "data")
        return get_inline_list_view
      end 
    end
    return "catalog/profile/property_block"
  end
  
  def get_no_label_view
    return "catalog/profile/property_no_label"
  end
  
  def get_inline_list_view
    return "catalog/profile/property_inline_list_w_label"
  end
  
  ##Property partials for properties
  ##This can be extended by the app using this gem
  PROPERTY_TO_VIEW_AND_PARAMS = {
    #Description uses the no label view
    "http://vivoweb.org/ontology/core#description" => {"view" => "catalog/profile/property_no_label"},
    "http://purl.org/ontology/bibo/numPages" => {"view" => "catalog/profile/property_no_label"},
    "http://purl.org/ontology/bibo/pageStart" => {"view" => "catalog/profile/property_no_label"},
    "http://purl.org/ontology/bibo/pageEnd" => {"view" => "catalog/profile/property_no_label"},
    #Authors, editors, publishers, service provided by display with the inline list (delimited) view
    "http://vivoweb.org/ontology/core#relatedBy-http://purl.obolibrary.org/obo/IAO_0000030-http://vivoweb.org/ontology/core#Authorship" => {"view" => "catalog/profile/property_inline_list_w_label", :property_display_name => "Authors"},
    "http://vivoweb.org/ontology/core#relatedBy-http://purl.obolibrary.org/obo/IAO_0000030-http://vivoweb.org/ontology/core#Editorship" => {"view" => "catalog/profile/property_inline_list_w_label", :property_display_name => "Editors"},
    "http://vivoweb.org/ontology/core#publisher" => {"view" => "catalog/profile/property_inline_list_w_label", :property_display_name => "Publisher"},
    "http://purl.obolibrary.org/obo/ERO_0000390" => {"view" => "catalog/profile/property_inline_list_w_label"},
      #More properties dipslay with inline list (delimited) view
    "http://vivoweb.org/ontology/core#hasPublicationVenue" => {"view" => "catalog/profile/property_inline_list_w_label", :property_display_name => "Published In"},
    "http://purl.obolibrary.org/obo/ERO_0000045" => {"view" => "catalog/profile/property_inline_list_w_label"},
    "http://purl.org/ontology/bibo/doi" => {"view" => "catalog/profile/property_inline_list_w_label"},
    "http://purl.org/ontology/bibo/status" => {"view" => "catalog/profile/property_inline_list_w_label", :property_display_name => "Status"},
    "http://vivoweb.org/ontology/core#hasSubjectArea" => {"view" => "catalog/profile/property_inline_list_w_label"}
  }
  
  ##Exclusion key array
  EXCLUDE_PROPERTY_KEYS = [
    "http://vitro.mannlib.cornell.edu/ns/vitro/public#mainImage",
    # web pages 
    "http://purl.obolibrary.org/obo/ARG_2000028-http://purl.obolibrary.org/obo/IAO_0000030-http://www.w3.org/2006/vcard/ns#URL",
    "http://purl.obolibrary.org/obo/ARG_2000028-http://vivoweb.org/ontology/core#EventSeries-http://www.w3.org/2006/vcard/ns#URL",
    "http://purl.obolibrary.org/obo/ARG_2000028-http://purl.org/NET/c4dm/event.owl#Event-http://www.w3.org/2006/vcard/ns#URL",
    "http://purl.obolibrary.org/obo/ARG_2000028-http://xmlns.com/foaf/0.1/Organization-http://www.w3.org/2006/vcard/ns#URL",
    "http://purl.obolibrary.org/obo/ARG_2000028-http://vivoweb.org/ontology/core#Project-http://www.w3.org/2006/vcard/ns#URL",
    "http://purl.obolibrary.org/obo/ARG_2000028-http://vivoweb.org/ontology/core#Facility-http://www.w3.org/2006/vcard/ns#URL",
    "http://purl.obolibrary.org/obo/ARG_2000028-http://xmlns.com/foaf/0.1/Person-http://www.w3.org/2006/vcard/ns#URL",
    "http://purl.obolibrary.org/obo/ARG_2000028-http://purl.obolibrary.org/obo/ERO_0000071-http://www.w3.org/2006/vcard/ns#URL",
    "http://vivoweb.org/ontology/core#dateTimeValue-http://purl.obolibrary.org/obo/IAO_0000030-http://vivoweb.org/ontology/core#DateTimeValue",
    "http://purl.org/dc/terms/format",
    "http://www.w3.org/2004/02/skos/core#inScheme", 
    "http://www.w3.org/2004/02/skos/core#narrower", 
    "http://www.w3.org/2004/02/skos/core#broader",
    "http://www.w3.org/2004/02/skos/core#related",
    "http://www.w3.org/2011/content#chars",
    Rails.application.config.VIVONamespace + "ontology/inHighlightsCollection"

    ]
  
  def get_property_view_options(property_info_object)
    property_options = {}
    #Check if property key is present in hash for custom options for passing to views
    property_key = property_info_object["property_key"]
    view_params = get_property_to_view_and_params()
    if (view_params.has_key?(property_key))
      property_options = view_params[property_key]
    else
      #Pass back the name for the property - this may  not be required for each partial but good to have this info passed back
      property_options[:property_display_name] = property_info_object["name"]
    end
    
  #If no view specified, pass back default view

    if(! property_options.has_key?("view"))
          property_options["view"] = get_default_property_view(property_info_object)
    end
    property_options[:property_info_object] = property_info_object
    #Rails.logger.debug("Property options are #{property_options.inspect}")
    
    return property_options
  end
  
  ##Properties to exclude on every page
  def get_default_exclude_property_keys
    puts "default gem exclude property keys called #{EXCLUDE_PROPERTY_KEYS.inspect}"
    Rails.logger.debug("Gem default exclude #{EXCLUDE_PROPERTY_KEYS.inspect}")
    return EXCLUDE_PROPERTY_KEYS
  end
  
  ##Property view options
  def get_property_to_view_and_params
    return PROPERTY_TO_VIEW_AND_PARAMS
  end
  
  ##Methods for parsing and displaying date time information from profile
  def get_date_time_for_display(date_time_value)
    formatted_date = ""
      if(date_time_value != nil)
           d = DateTime.parse(date_time_value)
           formatted_date = d.strftime("%Y")
       end
       return formatted_date
  end
  
  #Certain statement-level partials require listing information in sequence where certain
  #strings may or may not be empty
  
  def join_strings_reject_empty(display_array, separator = " ,")
    display_array = display_array.reject { |display| display.empty? }
    return display_array.join(separator).html_safe

  end
  
end
end