class AddIndices < ActiveRecord::Migration 
  def self.up 
    add_index :authors_books, :author_id 
    add_index :authors_books, :book_id 
  end 
  def self.down 
    remove_index :authors_books, :author_id 
    remove_index :authors_books, :book_id 
  end 
end