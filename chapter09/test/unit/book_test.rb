require File.dirname(__FILE__) + '/../test_helper'

class BookTest < Test::Unit::TestCase
  fixtures :publishers, :authors, :books, :authors_books
  
  def test_tagging 
    book = Book.find(1) 
    book.tag 'Elvis,Thriller', :separator => ',' 
    book.reload 
    assert book.tagged_with?('Elvis') 
    assert book.tagged_with?('Thriller') 
    assert_equal 2, book.tags.size 
    assert_equal ['Elvis', 'Thriller'], book.tag_names 
    assert_equal 1, Book.find_tagged_with(:any => [ 'Elvis', 'Thriller' ]).size 
    assert_equal 1, Book.find_tagged_with(:all => [ 'Elvis', 'Thriller' ]).size 
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

  def test_ferret
    Book.rebuild_index

    assert Book.find_by_contents("Pride and Prejudice")

    assert_difference Book, :count do
      book = Book.new(:title => 'The Success of Open Source',
                :published_at => Time.now, :page_count => 500,
                :price => 59.99, :isbn => '0-674-01292-5')
      book.authors << Author.create(:first_name => "Steven", :last_name => "Weber")
      book.publisher = Publisher.find(1)
      assert book.valid?
      book.save

      assert_equal 1, Book.find_by_contents("Open Source").size
      assert_equal 1, Book.find_by_contents("Steven Weber").size
    end
  end
end
