class AddBookCoverColumn < ActiveRecord::Migration
  def self.up
    add_column :books, :cover_image, :string
  end

  def self.down
    remove_column :books, :cover_image
  end
end
