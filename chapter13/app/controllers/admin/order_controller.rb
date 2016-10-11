class Admin::OrderController < ApplicationController

  def index 
    @status = params[:id] 
    if @status.blank? 
      @status = 'all' 
      conditions = nil 
    else 
      conditions = "status = '#{@status}'" 
    end 

    @page_title = "Listing #{@status} orders" 
    @order_pages, @orders = paginate :orders, :per_page => 10, :order => 'created_at desc', :conditions => conditions 
  end
  
  def show 
    @page_title = "Displaying order ##{params[:id]}" 
    @order = Order.find(params[:id]) 
  end

  def close 
    order = Order.find(params[:id]) 
    order.close 
    flash[:notice] = "Order #{order.id} has been closed" 
    redirect_to :action => 'index', :id => 'closed' 
  end
end
