# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
# This helper module is used to process information retrieved from VIVO for display within Blacklight.  
# This module will be packaged into a reusable gem for integrating VIVO information into Blacklight.
module Vivotoblacklight

module StatementPartialHelper
  def get_profile_url(uri_string)
    #Get local name of uri_string
    return "n1resource?DocId=" + CGI::escape("vitroIndividual:" + uri_string)
  end
end
  end