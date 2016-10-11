class Admin::BookController < ApplicationController
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @page_title = 'Listing books'
    sort_by = params[:sort_by]
    @book_pages, @books = paginate :books, :order => sort_by, :per_page => 10
  end

  def show
    @book = Book.find(params[:id])
    @page_title = "#{@book.title}"
  end

  def new
    load_data
    @book = Book.new
  end

  def create
    @book = Book.new(params[:book])
    if @book.save
      flash[:notice] = 'Book was successfully created.'
      redirect_to :action => 'list'
    else
      load_data
      render :action => 'new'
    end
  end

  def edit
    @page_title = 'Editing book'
    load_data
    @book = Book.find(params[:id])
  end

  def update
    @book = Book.find(params[:id])
    if @book.update_attributes(params[:book])
      flash[:notice] = 'Book was successfully updated.'
      redirect_to :action => 'show', :id => @book
    else
      render :action => 'edit'
    end
  end

  def destroy
    Book.find(params[:id]).destroy
    redirect_to :action => 'list'
  end
    
  private

    def load_data
      @authors = Author.find(:all)
      @publishers = Publisher.find(:all)
    end
end
