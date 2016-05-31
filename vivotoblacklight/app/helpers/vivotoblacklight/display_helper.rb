module Vivotoblacklight
  module DisplayHelper
    #Pass in array for representing display of statements
     def getStatementsDisplay(statements, property_info)
       statementDisplay = Array.new
       property_type = property_info["type"]
       partial_name = property_info["partial_name"]
       template_name = property_info["template"]
       collated_by_subclass = false
       if(property_info.has_key?("collatedBySubclass"))
         collated_by_subclass = property_info["collatedBySubclass"]
       end
       if (statements != nil and statements.length > 0)
             statements.each do|statement|
               #Rails.logger.debug("Statement is #{statement.inspect}")
               display_statement_values = getPropertyStatementDisplay(statement, property_info["uri"], property_info["domainUri"], property_info["rangeUri"], property_type, partial_name, template_name, collated_by_subclass)
               #Concatenate result of statements
               #Partial is executed per statement, and a property may have multiple statements
               statementDisplay << display_statement_values
             end #end loop through statements
           end
       return statementDisplay
     end
     
     #Use subclasses as a mechanism for breaking out the 
     def getPropertyDisplayWithCategories(property_info)
       subclassDisplay = Array.new
       subclasses = property_info["subclasses"]
       subclasses.each do|subclass|
         #Rails.logger.debug("Subclass exists #{subclass.inspect}")
         subclassname = subclass["name"]
         subclassDisplay << "<h4>" + subclassname + "</h4>"
         if(subclass.has_key?("statements"))
           #Rails.logger.debug("Subclass does have key statements")
           statements = subclass["statements"]
           statementDisplay = getStatementsDisplay(statements, property_info)
           subclassDisplay.push(*statementDisplay)
         else
           #Rails.logger.debug("Subclass does NOT have key statements")
         end
         #Rails.logger.debug("Statements after subclass is now #{statements.inspect}")
       end
       return subclassDisplay
     end
     
     
     ##Display for a single statement
     def getPropertyStatementDisplay(statement, property_uri, property_domain_uri, property_range_uri, property_type, partial_name, property_template_name, property_collated_by_subclass = false)
   
       display_statement_values = ""
       # Data property default
       if(statement.has_key?("value") and statement["value"] != nil and statement["value"].gsub(/\s+/, "") != "")
         
           Rails.logger.debug("Property #{property_uri.inspect} and data PROP and partial not nil #{partial_name.inspect}")
           display_statement_values= render(partial: partial_name, locals: {statement: statement,
                   property_uri: property_uri,
                   property_domain_uri: property_domain_uri,
                   property_range_uri: property_range_uri,
                   property_type: property_type, property_template_name: property_template_name})
        
        
        
         
       end #if statement.has_key
       # if object, we may be in for a different situation
       if(property_type == "object" and statement.has_key?("allData")) 
         # Print out all the data
         display_statement_values = render(partial: partial_name, locals: {statement: statement,
           property_uri: property_uri,
           property_domain_uri: property_domain_uri,
           property_range_uri: property_range_uri,
           property_type: property_type, property_template_name: property_template_name, property_collated_by_subclass: property_collated_by_subclass})
   
       end
   
       return display_statement_values
     end
     
  end
end
