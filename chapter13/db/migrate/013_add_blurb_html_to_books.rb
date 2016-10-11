class AddBlurbHtmlToBooks < ActiveRecord::Migration 
  def self.up 
    add_column :books, :blurb_html, :text 
  end 
  def self.down 
    remove_column :books, :blurb_html 
  end 
end