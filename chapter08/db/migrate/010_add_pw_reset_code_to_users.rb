class AddPwResetCodeToUsers < ActiveRecord::Migration 
  def self.up 
    add_column :users, :pw_reset_code, :string, :limit => 40 
  end 
  def self.down 
    remove_column :users, :pw_reset_code 
  end 
end