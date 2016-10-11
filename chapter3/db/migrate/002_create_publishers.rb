class CreatePublishers < ActiveRecord::Migration
  def self.up
    create_table :publishers do |table|
      table.column :name, :string, :limit => 255, :null => false, :unique => true
    end
  end

  def self.down
    drop_table :publishers
  end
end
