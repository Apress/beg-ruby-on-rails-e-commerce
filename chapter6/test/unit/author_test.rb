require File.dirname(__FILE__) + '/../test_helper'

class AuthorTest < Test::Unit::TestCase
  fixtures :authors

  def test_name
    author = Author.create(:first_name => 'Joel', 
                           :last_name => 'Spolsky')
    assert_equal 'Joel Spolsky', author.name
  end
end
