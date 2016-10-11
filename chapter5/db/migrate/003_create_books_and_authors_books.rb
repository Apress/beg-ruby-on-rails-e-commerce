class CreateBooksAndAuthorsBooks < ActiveRecord::Migration
  def self.up
    create_table :books do |table|
      table.column :title, :string, :limit => 255, :null => false
      table.column :publisher_id, :integer, :null => false
      table.column :published_at, :datetime
      table.column :isbn, :string, :limit => 13, :unique => true
      table.column :blurb, :text
      table.column :page_count, :integer
      table.column :price, :float
      table.column :created_at, :timestamp
      table.column :updated_at, :timestamp
    end

    create_table :authors_books, :id => false do |table|
      table.column :author_id, :integer, :null => false
      table.column :book_id, :integer, :null => false
    end

    say_with_time 'Adding foreign keys' do
      # Add foreign key reference to books_authors table
      execute 'ALTER TABLE authors_books ADD CONSTRAINT fk_bk_authors FOREIGN KEY ( author_id ) REFERENCES authors( id ) ON DELETE CASCADE'
      execute 'ALTER TABLE authors_books ADD CONSTRAINT fk_bk_books FOREIGN KEY ( book_id ) REFERENCES books( id ) ON DELETE CASCADE'
      # Add foreign key reference to publishers table
      execute 'ALTER TABLE books ADD CONSTRAINT fk_books_publishers FOREIGN KEY ( publisher_id ) REFERENCES publishers( id ) ON DELETE CASCADE'
    end
  end
  
  def self.down
    drop_table :authors_books
    drop_table :books
  end
end
