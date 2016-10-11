require File.dirname(__FILE__) + '/../../test_helper'
require 'admin/publisher_controller'

# Re-raise errors caught by the controller.
class Admin::PublisherController; def rescue_action(e) raise e end; end

class Admin::PublisherControllerTest < Test::Unit::TestCase
  fixtures :publishers

  def setup
    @controller = Admin::PublisherController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:publishers)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:publisher)
    assert assigns(:publisher).valid?
    
    assert_tag "h1", :content => Publisher.find(1).name
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:publisher)
  end

  def test_create
    num_publishers = Publisher.count

    post :create, :publisher => {:name => 'The Monopoly Publishing Company'}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_publishers + 1, Publisher.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:publisher)
    assert assigns(:publisher).valid?
  end

  def test_update
    post :update, :id => 1, :publisher => { :name => 'Apress.com' }
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
    assert_equal 'Apress.com', Publisher.find(1).name
  end

  def test_destroy
    assert_not_nil Publisher.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Publisher.find(1)
    }
  end
end
