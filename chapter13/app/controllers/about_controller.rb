class AboutController < ApplicationController
  caches_page :index
  
  def index
    @page_title = 'About Emporium'
  end
end
