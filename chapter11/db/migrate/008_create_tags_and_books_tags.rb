class CreateTagsAndBooksTags < ActiveRecord::Migration 
  def self.up 
    create_table :tags, :options => 'default charset=utf8' do |table| 
      table.column :name, :string, :limit => 255, :null => false, :unique => true 
    end 
    create_table :books_tags, :id => false, :options => 'default charset=utf8' do |table| 
      table.column :tag_id, :integer, :null => false 
      table.column :book_id, :integer, :null => false 
    end 
    say_with_time 'Adding foreign keys' do 
      # Add foreign key reference to books_tags table 
      execute 'ALTER TABLE books_tags ADD CONSTRAINT fk_tb_tags FOREIGN KEY ( tag_id ) REFERENCES tags( id ) ON DELETE CASCADE' 
      execute 'ALTER TABLE books_tags ADD CONSTRAINT fk_tb_books FOREIGN KEY ( book_id ) 
REFERENCES books( id ) ON DELETE CASCADE' 
    end 
    say_with_time 'Adding default tags' do 
      execute(insert_tags_sql) 
    end 
  end 
  def self.down 
    drop_table :books_tags 
    drop_table :tags 
  end 
  def self.insert_tags_sql 
    <<-END_OF_DATA 
insert into tags values 
(1,"Romance"), 
(2,"Cooking"), 
(3,"Mystery"), 
(4,"History"), 
(5,"Politics"), 
(6,"Elvis"), 
(7,"Science Fiction") 
END_OF_DATA
  end 
end 
