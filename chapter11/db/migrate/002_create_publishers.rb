class CreatePublishers < ActiveRecord::Migration
  def self.up
    create_table :publishers, :options => 'default charset=utf8' do |table|
      table.column :name, :string, :limit => 255, :null => false, :unique => true
    end
  end
  
  def self.down
    drop_table :publishers
  end
end
