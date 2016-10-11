class TagController < ApplicationController
  def list 
   @page_title = 'Listing tags' 
   @tag_pages, @tags = paginate :tags, :order => :name, :per_page => 10 
  end 
  def show 
    tag = params[:id] 
    @page_title = "Books tagged with '#{tag}'" 
    @books = Book.find_tagged_with(:any => tag, :separator => ',') 
  end 
end
