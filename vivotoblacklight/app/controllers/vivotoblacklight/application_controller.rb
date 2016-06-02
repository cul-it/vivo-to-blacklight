#module Vivotoblacklight
#  class ApplicationController < ActionController::Base
#    protect_from_forgery with: :exception
#  end
#end
#make all the helpers available
class Vivotoblacklight::ApplicationController < ApplicationController
  helper Vivotoblacklight::Engine.helpers
end