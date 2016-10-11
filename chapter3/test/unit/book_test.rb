require File.dirname(__FILE__) + '/../test_helper'

class BookTest < Test::Unit::TestCase

  fixtures :publishers, :authors, :books, :authors_books
  
  def test_create
    book = Book.new(
      :title => 'Ruby for Toddlers',
      :publisher_id => Publisher.find(1).id,
      :published_at => Time.now,
      :authors => Author.find(:all),
      :isbn => '123-123-123-1',
      :blurb => 'The best book since "Bodo Bär zu Hause"',
      :page_count => 12,
      :price => 40.4
    )
    assert book.save
  end

  def test_failing_create
    book = Book.new
    assert_equal false, book.save
    assert_equal 7, book.errors.size
    
    assert book.errors.on(:title)
    assert book.errors.on(:publisher)
    assert book.errors.on(:authors)
    assert book.errors.on(:published_at)
    assert book.errors.on(:isbn)
    assert book.errors.on(:page_count)
    assert book.errors.on(:price)
  end
  
  def test_has_many_and_belongs_to_mapping
    apress = Publisher.find_by_name("Apress")
    assert_equal 2, apress.books.size
    
    book = Book.new(
      :title => 'Rails E-Commerce 3nd Edition',
      :authors => [Author.find_by_first_name_and_last_name('Christian', 'Hellsten'),
                   Author.find_by_first_name_and_last_name('Jarkko', 'Laine')],
      :published_at => Time.now,
      :isbn => '123-123-123-x',
      :blurb => 'E-Commerce on Rails',
      :page_count => 300,
      :price => 30.5
    )
    
    apress.books << book
    
    apress.reload
    book.reload
    
    assert_equal 3, apress.books.size
    assert_equal 'Apress', book.publisher.name
  end
  
  def test_has_and_belongs_to_many_authors_mapping
    book = Book.new(
      :title => 'Rails E-Commerce 3nd Edition',
      :publisher => Publisher.find_by_name('Apress'),
      :authors => [Author.find_by_first_name_and_last_name('Christian', 'Hellsten'),
                   Author.find_by_first_name_and_last_name('Jarkko', 'Laine')],
      :published_at => Time.now,
      :isbn => '123-123-123-x',
      :blurb => 'E-Commerce on Rails',
      :page_count => 300,
      :price => 30.5
    )
    
    assert book.save
    
    book.reload
    
    assert_equal 2, book.authors.size
    assert_equal 2, Author.find_by_first_name_and_last_name('Christian', 'Hellsten').books.size
  end
end
