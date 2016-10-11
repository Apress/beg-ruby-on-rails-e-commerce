class Publisher < ActiveRecord::Base
  has_many :books

  validates_length_of :name, :in => 2..255
  validates_uniqueness_of :name
end
