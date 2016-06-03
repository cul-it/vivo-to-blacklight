# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
# -*- encoding : utf-8 -*-

# Utilizing this model to retrieve particular information from a VIVO profile
# This model is tied to the information within VIVO and as such as will be packaged into
# a reusable gem for integrating VIVO information into Blacklight

module Vivotoblacklight

class VivoProfile
  include ActiveModel::Model
  require 'cgi'

  ##Originally in helper method, moved here instead
  #  @@highlightMappings = {
  #    "adaptation" => "http://www.nyclimatescience.org/individual/n65129",

  #  }
  ##These two should be set once we get the information back from the profile
  ##The model shouldn't be responsible for the actual HTML - we do include the partial name
  ##or logic for deciding which partial corresponds to which property
  ##but the HTML is not generated here
  @@parsedPropertyHash = {}
  @@parsedFauxPropertyHash = {}
  @@parsedListKey = "parsedList"
  @@parsedPropertyKey = "propertyHash"
  @@parsedFauxPropertyKey = "fauxPropertyHash"

  ##Template name to Ruby Partial mapping
  # pick partial
  #Not all freemarker templates are represented because there are certain classes, e.g. EducationalProcess, that are not added to the search index
  @@vivoTemplateToPartialMapping = {
    "propStatement-dataDefault.ftl" =>  "catalog/profile/data_default",
    "propStatement-authorInAuthorship.ftl" =>  "catalog/profile/author_in_authorship",
    "propStatement-fullName.ftl" => "catalog/profile/full_name",
    "propStatement-informationResourceInAuthorship.ftl" => "catalog/profile/resource_in_authorship",
    "propStatement-webpage.ftl" => "catalog/profile/webpage",
    "propStatement-editorship.ftl" =>  "catalog/profile/editorship",
    "propStatement-informationResourceInEditorship.ftl" => "catalog/profile/resource_in_editorship",
    "propStatement-dateTimeValue.ftl" => "catalog/profile/date_time_value",
    "propStatement-dateTimeInterval.ftl" => "catalog/profile/date_time_interval",
    "propStatement-hasAssociatedConcept.ftl" => "catalog/profile/has_associated_concept",
    "propStatement-adviseeIn.ftl" => "catalog/profile/advisee_in",
    "propStatement-advisorIn.ftl" => "catalog/profile/advisor_in",
    "propStatement-awardOrHonor.ftl" => "catalog/profile/award_or_honor",
    "propStatement-awardOrHonorGiven.ftl" => "catalog/profile/award_or_honor_given",
    "propStatement-doi.ftl" => "catalog/profile/doi",
    "propStatement-educationalTraining.ftl" => "catalog/profile/educational_training",
    "propStatement-emailAddress.ftl" => "catalog/profile/email_address",
    "propStatement-grantAdministeredBy.ftl" => "catalog/profile/grant_administered_by",
    "propStatement-hasAttendeeRole.ftl" => "catalog/profile/has_attendee_role",
    "propStatement-hasEditReviewRole.ftl" => "catalog/profile/has_edit_review_role",
    "propStatement-hasInvestigatorRole.ftl" => "catalog/profile/has_investigator_role",
    "propStatement-hasPresenterRole.ftl" => "catalog/profile/has_presenter_role",
    "propStatement-hasRole.ftl" => "catalog/profile/has_role",
    "propStatement-issuedCredential.ftl" => "catalog/profile/issued_credential",
    "propStatement-mailingAddress.ftl" => "catalog/profile/mailing_address",
#    "propStatement-orcidId.ftl" => "catalog/profile/orcid_id",
    "propStatement-organizationAdministersGrant.ftl" => "catalog/profile/organization_administers_grant",
    "propStatement-organizationAwardsGrant.ftl" => "catalog/profile/organization_awards_grant",
    "propStatement-organizationForPosition.ftl" => "catalog/profile/organization_for_position",
    "propStatement-personInPosition.ftl" => "catalog/profile/person_in_position",
    "propStatement-phoneFaxNumber.ftl" => "catalog/profile/phone_fax_number",
    "propStatement-preferredTitle.ftl" => "catalog/profile/preferred_title",
    "propStatement-publicationVenueFor.ftl" => "catalog/profile/publication_venue_for",
    "propStatement-publisherOf.ftl" => "catalog/profile/publisher_of",
    "propStatement-relatedRole.ftl" => "catalog/profile/related_role",
    "propStatement-researchAreaOf.ftl" => "catalog/profile/research_area_of",
    "propStatement-scopusId.ftl" => "catalog/profile/scopus_id"
  }
  # Default object property partial
  @@defaultObjectPropertyPartial = "catalog/profile/default_object_property"


  ##This needs to be called first to retrieve the information and populate the hashes above
  def initialize(document)
    #Get the URI
    thisURI = document["URI"] unless document["URI"].blank?
    Rails.logger.debug("initialize")
    if thisURI.present?
      #Get the profile back
      result = get_individual_profile_json(thisURI)
      #Set the hashes
      initialize_model_hashes(result)
      initialize_info()
    end
  end

  def initialize_model_hashes(result)
    if result.has_key?(@@parsedListKey)
      parsedList = result[@@parsedListKey]
      if parsedList.has_key?(@@parsedPropertyKey)
        @@parsedPropertyHash = parsedList[@@parsedPropertyKey]
      end
      if parsedList.has_key?(@@parsedFauxPropertyKey)
        @@parsedFauxPropertyHash = parsedList[@@parsedFauxPropertyKey]
      end
    end
  end
  
  ##Associate partial information within the hash
  def initialize_info()
    if(@@parsedPropertyHash != nil)
      #Go through all the values and add partial to the property information objects
      @@parsedPropertyHash.each do|key, val|
        updatePropertyWithPartial(val)
        #Saving for quick reference later, although this can be reassembled from the information included
        val["property_key"] = key
      end
    end
  end

  ##Retrieve the VIVO Profile - the complete JSON output
  def get_individual_profile_json thisURI
    #vivo_app = ENV["VIVO_APP_URL"]
    vivo_app = Vivotoblacklight.configuration.vivo_app_url
    #Throw an exception if the app url has not been set
   Rails.logger.debug("VIVO APP is #{vivo_app.inspect}")
    result= {}
    thisURI = CGI::escape(thisURI)
    url = URI.parse(vivo_app + "/individual?uri=" + thisURI  + "&action=defaultJSON")
    begin
      resp = Net::HTTP.get_response(url)
    rescue
      result = nil
    else
      data = resp.body
      result = JSON.parse(data)
    end
    return result
  end

  ###Methods for retrieving all the properties or properties with certain keys (list of keys)
  
  #Get all the properties
  #Right now uses hash but we can specify a specific order or the property list order instead
  #Return a list of property_info_objects
  def get_all_property_info_objects()
    return @@parsedPropertyHash.values
  end
  
  ##Get property info objects except for a certain list - i.e. URIs
  def get_property_info_objects_except_keys(exclude_property_keys)
    filtered_hash = @@parsedPropertyHash.except( *exclude_property_keys)
    return filtered_hash.values
  end
  
  ##Get property info objects excluding certain properties identified by name or label
  ##And not the URIs - Use the name property of property info
  ##Important to note that name is not unique so this will exclude all properties
  ##without that name
  def get_property_info_objects_except_names(exclude_property_names)
    filtered_hash = @@parsedPropertyHash.select {|key, val| exclude_property_names.exclude?(val.localName)}
    return filtered_hash.values
   end
   
   ##Get a specific LIST of property info objects based on list of property keys
   ##Returns array of property info objects
  def get_property_info_objects_for_key_list(key_list) 
    property_info_array = Array.new
    key_list.each do|key|
      property_info_array << getPropertyInfo(key)
    end
    return property_info_array
  end

  ##Methods that can be used to get property information for authors, publishers, or publications

  #Authors
  def getAuthors()
    property_key = get_authors_key()
    property_info =  getPropertyInfo(property_key)
    return property_info
  end

  #Publishers
  def getPublishers()
    property_key = get_publishers_key()
    property_info = getPropertyInfo(property_key)
    return property_info
  end

  def getPublications()
    property_key = "http://vivoweb.org/ontology/core#relatedBy-http://xmlns.com/foaf/0.1/Person-http://vivoweb.org/ontology/core#Authorship"
    property_info = getPropertyInfo(property_key)
    return property_info
  end
 

  #Data content type

  
  #Convenience methods - get keys for particular properties
  
  def get_authors_key()
    return "http://vivoweb.org/ontology/core#relatedBy-http://purl.obolibrary.org/obo/IAO_0000030-http://vivoweb.org/ontology/core#Authorship"
  end

  def get_editors_key()
    return "http://vivoweb.org/ontology/core#relatedBy-http://purl.obolibrary.org/obo/IAO_0000030-http://vivoweb.org/ontology/core#Editorship"
  end
  
  ##We may want additional parameters to decide which partial to employ, right now just based off template name coming
  ##back from VIVO
  def getPropertyPartial(property_template_name)
    partial_name = @@defaultObjectPropertyPartial
    if property_template_name != nil and @@vivoTemplateToPartialMapping.has_key?(property_template_name)
      partial_name = @@vivoTemplateToPartialMapping[property_template_name]
    end
    #puts "VIVO Profile: Partial name is #{partial_name.inspect}"
    return partial_name
  end

  def getPartialForProperty(property_info)
    #puts "VIVO Profile: GetPartialForProperty"
    partial_name = nil
    property_type = property_info["type"]
   #Anythiing can have a partial, not just object properties
      #if property_type == "object" 
      partial_name = getPropertyPartial(property_info["template"])
    #end
    #puts "partial name returned is #{partial_name.inspect}"
    return partial_name
  end

 
  
  #This takes the property info object and returns it
  #This should update the reference itself
def updatePropertyWithPartial(property_info)
   if property_info != nil
     partial_name = getPartialForProperty(property_info)
     if partial_name != nil
       property_info["partial_name"] = partial_name
     end
   end
 end


  ##Base method, get the property information given a property key
  def getPropertyInfo(property_key)
    if @@parsedPropertyHash.has_key?(property_key)
      return @@parsedPropertyHash[property_key]
    end
    return nil
  end

  def getFauxPropertyInfo(property_key)
    if @@parsedFauxPropertyHash.has_key?(property_key)
      return @@parsedFauxPropertyHash[property_key]
    end
    return nil
  end

  def isFauxProperty(property_key)
    return (@@parsedFauxPropertyHash.has_key?(property_key))
  end

end
end