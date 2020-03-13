require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  # ユーザーの新規登録前と後でユーザー数が変わらないかどうかをテスト
  # test "invalid signup information" do (7章)
  #   get signup_path
  #   # User.countでユーザー数が変わっていなければ（ユーザー生成失敗）true,変わっていればfalse
  #   assert_no_difference 'User.count' do

  #     # signup_pathからusers_pathに対してpostリクエスト送信(/usersへ)、
  #     # paramsでuserハッシュとその下のハッシュで値を受け取れるか確認
  #     post users_path, params: { user: { name:  "",
  #                                        email: "user@invalid",
  #                                        password:              "foo",
  #                                        password_confirmation: "bar" } }
  #   end
  #   assert_template 'users/new'

  # エラーメッセージをテストするためのテンプレート

  # divタグの中のid 「error_explanation」が描画されていれば成功
  #   assert_select 'div#error_explanation'
  # divタグの中のclass 「field_with_errors」が描画されていれば成功
  #   assert_select 'div.field_with_errors'
  # end


  # test "valid signup information" do
  #   get signup_path

  # User.countでユーザー数をカウント、1とし、
  # ユーザー数が変わったらtrue、変わってなければfalse
  #   assert_difference 'User.count', 1 do
  #     post users_path, params: { user: { name:  "Example User",
  #                                        email: "user@example.com",
  #                                        password:              "password",
  #                                        password_confirmation: "password" } }
  #   end
  #   follow_redirect!
  #   assert_template 'users/show'
  #   assert is_logged_in?
  # end


  # ユーザー登録のテストにアカウント有効化を追加
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
      end
    # 配信されたメッセージがきっかり1つであるかどうかを確認
    # 配列「deliveries」は変数なので、
    # setupメソッドでこれを初期化しておかないと、
    # 並行して行われる他のテストでメールが配信されたときにエラーが発生してしまいます
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # 有効化していない状態でログインしてみる
    log_in_as(user)
    assert_not is_logged_in?
    # 有効化トークンが不正な場合
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # トークンは正しいがメールアドレスが無効な場合
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # 有効化トークンが正しい場合
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
