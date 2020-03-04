require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    # get users_new_url ↓から変更 名前付きパスにしたから
    get signup_path
    assert_response :success
  end


end
