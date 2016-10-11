class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.column :first_name, :string
      t.column :last_name, :string
    end
  end

  def self.down
    drop_table :authors
  end
end
