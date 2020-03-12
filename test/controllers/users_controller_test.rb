require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    # もうひとり追加する→ユーザー情報は「fixture/users.yml」にある
    @other_user = users(:archer)
  end

  # indexアクションのリダイレクトをテスト
  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should get new" do
    # get users_new_url ↓から変更 名前付きパスにしたから
    get signup_path
    assert_response :success
  end

  # beforeフィルターは基本的にアクションごとに適用していく
  # Usersコントローラのテストもアクションごとに書いていく
  # →「edit」「update」アクションはget、patchメソッドを使っていく

  test "should redirect edit when not logged in" do
    # log_in_asメソッド(ログインユーザー)を使ってテストする
    # @other_userでログイン
    log_in_as(@other_user)
    # ログインユーザーの編集ページを取得
    get edit_user_path(@user)
    # flashが空でないならtrue
    # assert_not flash.empty?
    # ↓いつの間にか、assert に変更している…？なぜ
    # →10.24にていつの間にか変更…
    assert flash.empty?
    # ログインユーザーのidのURLへ飛べたらtrue
    # assert_redirected_to login_urlも
    # →10.24にていつの間にか変更なぜ…
    assert_redirected_to root_url
  end

  test "should redirect update when not logged in" do
    # log_in_asメソッド(ログインユーザー)を使ってテストする
    # @other_userでログイン
    log_in_as(@other_user)
    # ログインユーザーへ、保存ユーザーの名前とメルアドを引数に取り送信(更新)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    # flashが空でないならtrue
    # assert_not flash.empty?
    # ↓いつの間にか、assert に変更している…？なぜ
    # →10.24にていつの間にか変更…
    assert flash.empty?
    # ログインユーザーのidのURLへ飛べたらtrue
    # assert_redirected_to login_urlも
    # →10.24にていつの間にか変更なぜ…
    assert_redirected_to root_url
  end

  # Web経由でadmin属性を変更できないことを確認
  # →PATCHを直接ユーザーのURL(/users/:id)に送信するテスト
  # admin属性の変更が禁止されていることをテスト
  test "should not allow the admin attribute to be edited via the web" do
    # @other_userでログインする
    log_in_as(@other_user)
    # @toher_userが管理権限あれば(adminがtrueなら)falseを返す
    assert_not @other_user.admin?
    # /users/@other_user へparamsハッシュの中身を送る
    patch user_path(@other_user), params: {
           user: { password:               'password',
                   password_confirmation:  'password',
                   admin: true } }
    # @other_userを再読み込みし、admin論理値が変更されてないか検証(falseやnilならtrue)
    assert_not @other_user.reload.admin?
  end

  # 管理者権限の制御をアクションレベルでテスト
  # ログインしていないユーザーのテスト
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      # DELETEリクエストを発行してdestroyアクションを直接動作
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  # ログイン済みだが管理者権限のないユーザーのテスト
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    # ユーザー数が変化しないことを確認
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

  # 11.38 演習3
  # # /users と /users/:id の両方に対する統合テスト
  # test "should not allow the not activated attribute" do
  #   # 非有効化ユーザーでログイン
  #   log_in_as (@non_activated_user)
  #   # 有効化でないことを検証
  #   assert_not @non_activated_user.activated?
  #   # /usersを取得
  #   get users_path
  #   # 非有効化ユーザーが表示されていないことを確認
  #   assert_select "a[href=?]", user_path(@non_activated_user), count: 0
  #   # 非有効化ユーザーidのページを取得
  #   get user_path(@non_activated_user)
  #   # ルートurlにリダイレクトされればtrue
  #   assert_redirected_to root_url
  # end
end
