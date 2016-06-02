module Vivotoblacklight::Catalog
  extend ActiveSupport::Concern
    extend Deprecation
  include Blacklight::Catalog
  ##Overriding these methods to enable using ids
  puts "VBL: Catalog Module in concerns"
  def show
      @response, @document = fetch params[:id]
      Rails.logger.debug("Default APP catalog controller params #{params.inspect}")

      respond_to do |format|
        format.html { setup_next_and_previous_documents }
        format.json { render json: { response: { document: @document } } }

        additional_export_formats(@document, format)
      end
      
    end

    # updates the search counter (allows the show view to paginate)
    def track
      search_session['counter'] = params[:counter]
      search_session['id'] = params[:search_id]
      search_session['per_page'] = params[:per_page]

      path = if params[:redirect] and (params[:redirect].starts_with?("/") or params[:redirect] =~ URI::regexp)
        if(params[:redirect].include?("?DocId="))

           #OR use CGI parse?
           urlhash=  CGI::parse("DocId=" + params[:redirect].partition("?DocId=").last)
            if(urlhash["DocId"].length > 0)
                URI.parse(params[:redirect]).path + "?DocId=" + urlhash["DocId"].first
            else
              URI.parse(params[:redirect]).path
            end

          else
            URI.parse(params[:redirect]).path
          end
      else
        { action: 'show' }
      end
      redirect_to path, :status => 303
    end
    
end