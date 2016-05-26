# @author Darcy Branchini, Huda Khan
# @company Mann Library, Cornell University
# Handle date time functions for VIVO profile information
#-- Functions for datetime formatting 
# This helper module is used to process information retrieved from VIVO for display within Blacklight.  
# Portions of this module will be packaged into a reusable gem for integrating VIVO information into Blacklight.
#     In this library, functions are used to format the datetime or interval
#     according to a format string and precision, returning a raw string.
#     Macros are used to generate the string with appropriate markup.
 
module Vivotoblacklight

#-- Convenience display functions -
module ProfileDatetimeHelper

def yearSpan(dateTime)
    year_span = ""
    if (dateTime != nil)
        xsd = xsdDateTimeToYear(dateTime)
        year_span = dateTimeSpan(xsd)
    end
    return year_span.html_safe
end

def yearIntervalSpan(startDateTime="", endDateTime="", endYearAsRange=true)
   display_year = ''
    yearInterval = yearInterval(startDateTime, endDateTime, endYearAsRange)
    if ( yearInterval != nil)
        display_year = dateTimeSpan(yearInterval)
    end  
    return display_year.html_safe
end

# Display the datetime value or interval in a classed span appropriate for 
#     a property statement list 

def dateTimeSpan (nested)
    return '<span class="listDateTime">' + nested + '</span>'
end

#-- FUNCTIONS --)

#-- Assign a year precision and generate the interval --)
def yearInterval (dateTimeStart="", dateTimeEnd="", endYearAsRange=true)
    precision = "yearPrecision"
    return  dateTimeIntervalShort(dateTimeStart, precision, dateTimeEnd, precision, endYearAsRange)
end

#-- Generate a datetime interval with dates displayed as "January 1, 2011" --)
def dateTimeIntervalLong (dateTimeStart="", precisionStart="", dateTimeEnd="", precisionEnd="", endAsRange=true)
    return  dateTimeInterval(dateTimeStart, precisionStart, dateTimeEnd, precisionEnd, "long", endAsRange) 
end

#-- Generate a datetime interval with dates displayed as "1/1/2011" --)
def dateTimeIntervalShort(dateTimeStart="", precisionStart="" ,dateTimeEnd="" ,precisionEnd="", endAsRange=true)
    return  dateTimeInterval(dateTimeStart, precisionStart, dateTimeEnd, precisionEnd, "short", endAsRange)
end

#-- Generate a datetime interval --)
def dateTimeInterval (dateTimeStart="", precisionStart="", dateTimeEnd="", precisionEnd="", formatType="short", endAsRange=true)

    start_date = nil
    end_date = nil
    if ( dateTimeStart != nil && !dateTimeStart.empty?)   
        start_date = formatXsdDateTime(dateTimeStart, precisionStart, formatType)
    end
    
    if ( dateTimeEnd != nil && !dateTimeEnd.empty?)
      end_date = formatXsdDateTime(dateTimeEnd, precisionEnd, formatType)
    end
    
    interval = ''
    if (start_date != nil && end_date != nil)
      if ( start_date == end_date)
          interval = start_date
      else 
          interval = start_date + '&nbsp;-&nbsp;'.html_safe + end_date
      end
    elsif ( start_date != nil)
          interval = start_date + ' - '
    elsif ( end_date != nil)
      if ( endAsRange) 
          interval = '-&nbsp;'.html_safe 
      end
     interval += end_date
    end
    
    return interval.strip.html_safe
end

#-- Functions for formatting and applying precision to a datetime

#     Currently these do more than format the datetime string, they select the precision as well. This should change in a future
#     implementation; see NIHVIVO-1567. We want the Java code to apply the precision to the datetime string to pass only the
#     meaningful data to the templates. The templates can format as they like, so these functions/macros would do display formatting
#     but not data extraction.
#     
#     On the other hand, this is so easy that it may not be worth re-implementing to gain a bit more MVC compliance.


#-- Generate a datetime with date formatted as "January 1, 2011" --)
def formatXsdDateTimeLong(dateTime, precision)
    return formatXsdDateTime(dateTime, precision, "long")
end

#-- Generate a datetime with date formatted as "1/1/2011" --)
def formatXsdDateTimeShort(dateTime, precision)
    return formatXsdDateTime(dateTime, precision, "short")
end

#-- Generate a datetime as a year --)
def xsdDateTimeToYear(dateTime)
    precision = "yearPrecision"
    return formatXsdDateTime(dateTime, precision)
end

#-- Apply a precision and format type to format a datetime --)
def formatXsdDateTime(dateTimeStr, precision="", formatType="short")

    #-- First convert the string to a format that Freemarker can interpret as a datetime.
    #For now, strip away time zone rather than displaying it. --)
  
    dateTimeStr = dateTimeStr.gsub("T", " ").gsub(/Z.*$/, "").strip

#    #-- If a non-standard datetime format (e.g, "2000-04" from
#         "2000-04"^^<http://www.w3.org/2001/XMLSchema#gYearMonth)), just
#         return the string without attempting to format. Possibly this should
#         be handled in Java by examining the xsd type and making an appropriate
#         conversion. --)
    if  dateTimeStr !~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/
        return  dateTimeStr
    end
    
    #-- Convert the string to a datetime object. --)
    #Create date time 'object' 
    dateTimeObj =  DateTime.strptime(dateTimeStr, "%Y-%m-%d %H:%M:%S")

#    #-- If no precision is specified, assign it from the datetime value.
#         Pass dateTimeStr rather than dateTimeObj, because dateTimeObj
#         replaces zeroes with default values, whereas we want to set 
#         precision based on whether the times values are all 0. --)
    if ( precision.nil? || precision.empty?)
        precision = getPrecision(dateTimeStr)
    end
    
    #-- Get the format string for the datetime output --)
    format = getFormat(formatType, precision)

    #Convert date time object to this format - string
    formattedDateTime = dateTimeObj.strftime(format)
    return formattedDateTime.html_safe
    
end


#returns string representing precision
def getPrecision (dateTime)

    #-- We know this will match because the format has already been checked --)
    match = /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/.match(dateTime)
    #Returns match element
    #Is there a default precision in case
    #Setting this for now
    precision = "yearMonthDayTimePrecision" 
    if(match != nil)
      hours = match[4].to_f
      minutes = match[5].to_f
      seconds = match[6].to_f
        if ( hours == 0 and minutes == 0 and seconds == 0)
            precision = "yearMonthDayPrecision"
        else 
          precision = "yearMonthDayTimePrecision"
        end
    end
    return precision
end

def getFormat(formatType, precision)
    #-- Use the precision to determine which portion to display, 
     #    and the format type to determine how to display it.  --)    
   format = ''
        if ( formatType == "long")
            if ( precision.ends_with?("yearPrecision")) 
              format = '%Y'
            elsif ( precision.ends_with?("yearMonthPrecision")) 
              format = "%B %Y"#"MMMM yyyy"
            elsif ( precision.ends_with?("monthPrecision")) 
              format = "%B"#'MMMM'
            elsif ( precision.ends_with?("yearMonthDayPrecision")) 
              format = "%B %e, %Y"#"MMMM d, yyyy"
            else 
              format = "%B %e, %Y %H:M %p"#"MMMM d, yyyy h:mm a"
            end
        else  #-- formatType == "short" --)
            if ( precision.ends_with?("yearPrecision")) 
              format ='%Y'
           elsif ( precision.ends_with?("yearMonthPrecision")) 
             format = "%-m/%Y"
            elsif ( precision.ends_with?("yearMonthDayPrecision")) 
              format = "%-m/%e/%Y"
            else format = "%-m/%e/%Y%k:%M %p" #%k hour of the day blank padded
            end
        end
    
    
    return format
end
  

end
end
