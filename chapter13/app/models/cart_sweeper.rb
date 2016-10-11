class CartSweeper < ActionController::Caching::Sweeper 
  observe Cart, CartItem 
  def after_save(record) 
    cart = record.is_a?(Cart) ? record : record.cart 
    expire_fragment(:controller => "cart", 
                    :action => "show", 
                    :id => @cart) 
  end 
end