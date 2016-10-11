class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts, :options => 'default charset=utf8' do |t|
      # t.column :name, :string
    end
  end

  def self.down
    drop_table :carts
  end
end
