class Admin::AuthorController < Admin::BaseController

  def new
    @author = Author.new
    @page_title = 'Create new author'
  end

  def create
    @author = Author.new(params[:author])
    if @author.save
      flash[:notice] = "Author #{@author.name} was successfully created."
      redirect_to :action => 'index'
    else
      @page_title = 'Create new author'
      render :action => 'new'
    end
  end

  def edit
    @author = Author.find(params[:id])
    @page_title = 'Edit author'
  end

  def update
    @author = Author.find(params[:id])
    if @author.update_attributes(params[:author])
      flash[:notice] = 'Author was successfully updated.'
      redirect_to :action => 'show', :id => @author
    else
      @page_title = 'Edit author'
      render :action => 'edit'
    end
  end

  def destroy
    @author = Author.find(params[:id])
    flash[:notice] = "Successfully deleted author #{@author.name}"
    @author.destroy
    redirect_to :action => 'index'
  end

  def show
    @author = Author.find(params[:id])
    @page_title = @author.name
  end

  def index
    @authors = Author.find(:all)
    @page_title = 'Listing authors'
  end
end
