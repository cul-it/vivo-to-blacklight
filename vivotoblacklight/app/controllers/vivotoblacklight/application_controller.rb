#module Vivotoblacklight
#  class ApplicationController < ActionController::Base
#    protect_from_forgery with: :exception
#  end
#end

class Vivotoblacklight::ApplicationController < ApplicationController
  helper Vivotoblacklight::Engine.helpers
end