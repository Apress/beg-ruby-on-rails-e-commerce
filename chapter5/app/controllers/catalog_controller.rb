class CatalogController < ApplicationController

  before_filter :initialize_cart

  def index
    @page_title = "Book List"
    @book_pages, @books = paginate :books,
                            :per_page => 10,
                            :include => [:authors, :publisher],
                            :order => "books.id desc"
  end

  def show
    @book = Book.find(params[:id]) rescue nil
    return render(:text => "Not found", :status => 404) unless @book
    @page_title = @book.title
  end

  def search
    @page_title = "Search"
    if params[:commit] == "Search" || params[:q]
      @books = Book.find_by_contents(params[:q].to_s.upcase)
      unless @books.size > 0
        flash.now[:notice] = "No books found matching your criteria"
      end
    end
  end

  def latest
    @page_title = "Latest Books"
    @books = Book.latest
  end
  
  def rss
    latest
    render :layout => false
  end
end
